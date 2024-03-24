import 'dart:io';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';
import 'package:ncudio/src/rust/api/simple.dart';
import 'package:ncudio/src/rust/api/utils.dart';
import 'package:ncudio/src/rust/frb_generated.dart';
import 'package:super_sliver_list/super_sliver_list.dart';
import 'package:window_manager/window_manager.dart';

Future<void> main() async {
  await RustLib.init();

  WidgetsFlutterBinding.ensureInitialized();

  await windowManager.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux) {
    windowManager.setMinimumSize(const Size(800, 600));
    windowManager.setSize(const Size(800, 600));
  }

  JustAudioMediaKit.ensureInitialized();
  JustAudioMediaKit.title = 'ncudio';
  JustAudioMediaKit.protocolWhitelist = const ['file'];

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

enum TrackSortBy {
  title,
  artist,
  album,
  duration,
}

enum TrackSortOrder {
  ascending,
  descending,
}

class _MyAppState extends State<MyApp> {
  late Future<List<TrackDTO>> futureTrackList;
  late Future<List<int>> futureTrackIdsSortedByTitle;
  late Future<List<int>> futureTrackIdsSortedByArtist;
  late Future<List<int>> futureTrackIdsSortedByAlbum;
  late Future<List<int>> futureTrackIdsSortedByDuration;
  late TrackSortBy trackSortBy = TrackSortBy.title;
  late TrackSortOrder trackSortOrder = TrackSortOrder.ascending;

  String searchQuery = '';
  final player = AudioPlayer();
  TrackDTO? currentTrack;

  late double lastVolume;

  ThemeMode themeMode = ThemeMode.system;
  bool get useLightMode {
    switch (themeMode) {
      case ThemeMode.system:
        return View.of(context).platformDispatcher.platformBrightness ==
            Brightness.light;
      case ThemeMode.light:
        return true;
      case ThemeMode.dark:
        return false;
    }
  }

  static ThemeData lightThemeData = ThemeData();

  static ThemeData darkThemeData = ThemeData.dark();

  @override
  void initState() {
    super.initState();

    initialzeApp();
    initializeDb();

    lastVolume = player.volume;

    futureTrackList = getAllTracks();
    futureTrackIdsSortedByTitle = getAllTrackIdsSortedByTitle();
    futureTrackIdsSortedByArtist = getAllTrackIdsSortedByArtist();
    futureTrackIdsSortedByAlbum = getAllTrackIdsSortedByAlbum();
    futureTrackIdsSortedByDuration = getAllTrackIdsSortedByDuration();
  }

  @override
  void dispose() {
    player.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: lightThemeData,
      darkTheme: darkThemeData,
      home: Builder(builder: (context) {
        return homePage(context);
      }),
    );
  }

  Scaffold homePage(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: homeBody(context),
      bottomNavigationBar: bottomBar(context),
    );
  }

  Column homeBody(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: trackList(),
        ),
      ],
    );
  }

  Column bottomBar(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 15,
          color: Theme.of(context).scaffoldBackgroundColor,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SliderTheme(
            data: nakedSliderThemeData(),
            child: StreamBuilder<Duration>(
                stream: player.positionStream,
                builder: (context, positionSnapshot) {
                  return StreamBuilder<Duration?>(
                      stream: player.durationStream,
                      builder: (context, durationSnapshot) {
                        var duration = durationSnapshot.data ?? Duration.zero;
                        var position = positionSnapshot.data ?? Duration.zero;
                        if (position > duration) {
                          position = duration;
                        }
                        return Slider(
                          min: 0,
                          max: duration.inMilliseconds.toDouble(),
                          value: position < Duration.zero
                              ? 0
                              : position.inMilliseconds.toDouble(),
                          onChanged: (value) {
                            player.seek(Duration(milliseconds: value.toInt()));
                          },
                        );
                      });
                }),
          ),
        ),
        Container(
          height: 96,
          color: Theme.of(context).scaffoldBackgroundColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: bottomBarInner(),
        ),
      ],
    );
  }

  AppBar appBar() {
    return AppBar(
      flexibleSpace: TextField(
        decoration: const InputDecoration(
          hintText: 'Search',
          prefixIcon: Icon(Icons.search),
          border: InputBorder.none,
        ),
        onChanged: (value) {
          setState(() {
            searchQuery = value.toLowerCase();
          });
        },
      ),
      actions: [
        IconButton(
          icon: Icon(
            trackSortBy == TrackSortBy.title
                ? Icons.sort_by_alpha
                : trackSortBy == TrackSortBy.artist
                    ? Icons.people
                    : trackSortBy == TrackSortBy.album
                        ? Icons.album
                        : Icons.timelapse,
          ),
          onPressed: () {
            setState(() {
              trackSortBy = trackSortBy == TrackSortBy.title
                  ? TrackSortBy.artist
                  : trackSortBy == TrackSortBy.artist
                      ? TrackSortBy.album
                      : trackSortBy == TrackSortBy.album
                          ? TrackSortBy.duration
                          : TrackSortBy.title;
            });
          },
        ),
        IconButton(
          icon: Icon(
            trackSortOrder == TrackSortOrder.ascending
                ? Icons.arrow_upward
                : Icons.arrow_downward,
          ),
          onPressed: () {
            setState(() {
              trackSortOrder = trackSortOrder == TrackSortOrder.ascending
                  ? TrackSortOrder.descending
                  : TrackSortOrder.ascending;
            });
          },
        ),
        volumeToggleButton(),
        volumeSlider(),
        IconButton(
          icon: Icon(
            themeMode == ThemeMode.light ? Icons.light_mode : Icons.dark_mode,
          ),
          onPressed: () {
            setState(() {
              themeMode = themeMode == ThemeMode.light
                  ? ThemeMode.system
                  : ThemeMode.light;
            });
          },
        ),
        pickDirectoryButton(),
        IconButton(
          icon: const Icon(Icons.delete_forever),
          onPressed: () {
            deleteAllTracks().whenComplete(() => setState(() {
                  stopAndClear();
                  futureTrackList = getAllTracks();
                }));
          },
        ),
      ],
    );
  }

  Row bottomBarInner() {
    var lhs = currentTrack != null && player.audioSource != null
        ? Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(4)),
                child: currentTrack?.pictureId != null
                    ? Image.file(
                        File(
                            "${getCachePath()}/${currentTrack!.pictureId!}.jpg"),
                        cacheHeight: 200,
                        filterQuality: FilterQuality.medium,
                        fit: BoxFit.cover)
                    : AspectRatio(
                        aspectRatio: 1,
                        child: Container(
                          color: Colors.grey,
                          child: const Icon(Icons.music_note),
                        ),
                      ),
              ),
              const SizedBox(
                width: 8,
              ),
              Flexible(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SelectableText(currentTrack?.title ?? '',
                          maxLines: 1,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            overflow: TextOverflow.fade,
                          )),
                      SelectableText(currentTrack?.artist ?? '',
                          maxLines: 1,
                          style: const TextStyle(
                              fontWeight: FontWeight.normal,
                              overflow: TextOverflow.fade,
                              fontSize: 11)),
                      SelectableText(currentTrack?.album ?? '',
                          maxLines: 1,
                          style: const TextStyle(
                            fontWeight: FontWeight.normal,
                            overflow: TextOverflow.fade,
                            fontSize: 11,
                          )),
                      StreamBuilder<Duration?>(
                          stream: player.durationStream,
                          builder: (context, durationSnapshot) {
                            return StreamBuilder<Duration>(
                                stream: player.positionStream,
                                builder: (context, positionSnapshot) {
                                  var position =
                                      positionSnapshot.data ?? Duration.zero;

                                  if (durationSnapshot.data == null) {
                                    return Text(
                                        durationToString(duration: position),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.normal,
                                            overflow: TextOverflow.fade,
                                            fontSize: 11));
                                  }

                                  var duration = durationSnapshot.data!;
                                  return Text(
                                      '${durationToString(duration: position)} / ${durationToString(duration: duration)}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.normal,
                                          overflow: TextOverflow.fade,
                                          fontSize: 11));
                                });
                          }),
                    ]),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 24,
                    child: IconButton(
                      icon: const Icon(Icons.favorite_border),
                      padding: const EdgeInsets.all(0.0),
                      iconSize: 16,
                      onPressed: () {},
                    ),
                  ),
                  SizedBox(
                    height: 24,
                    child: IconButton(
                      icon: const Icon(Icons.more_vert),
                      padding: const EdgeInsets.all(0.0),
                      iconSize: 16,
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ],
          )
        : Container();
    var mid = ButtonBar(
      alignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.skip_previous),
          onPressed: () {},
        ),
        IconButton(
          icon: StreamBuilder<bool>(
              stream: player.playingStream,
              builder: (context, snapshot) {
                return Icon(snapshot.data != null && snapshot.data!
                    ? Icons.pause
                    : Icons.play_arrow);
              }),
          onPressed: () {
            setState(() {
              togglePlayPause();
            });
          },
        ),
        IconButton(
          icon: const Icon(Icons.skip_next),
          onPressed: () {
            setState(() {
              player.seekToNext();
            });
          },
        ),
      ],
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [Expanded(child: lhs), mid],
    );
  }

  IconButton volumeToggleButton() {
    return IconButton(
      icon: StreamBuilder<double>(
          stream: player.volumeStream,
          builder: (context, snapshot) {
            return Icon(snapshot.data != null && snapshot.data! > 0
                ? Icons.volume_up
                : Icons.volume_off);
          }),
      onPressed: () {
        setState(() {
          if (player.volume > 0) {
            lastVolume = player.volume;
            player.setVolume(0);
          } else {
            player.setVolume(lastVolume);
          }
        });
      },
    );
  }

  IconButton pickDirectoryButton() {
    return IconButton(
        onPressed: () {
          pickDirectory().then(
            (value) {
              if (value != null) {
                syncDirectory(mountPoint: value)
                    .whenComplete(() => setState(() {
                          futureTrackList = getAllTracks();
                        }));
              }
            },
          );
        },
        icon: const Icon(Icons.folder));
  }

  SliderTheme volumeSlider() {
    return SliderTheme(
      data: nakedSliderThemeData(),
      child: StreamBuilder<double>(
          stream: player.volumeStream,
          builder: (context, snapshot) {
            return Slider(
              min: 0,
              max: 1,
              value: snapshot.data ?? 1,
              onChanged: (value) {
                player.setVolume(value);
              },
              onChangeEnd: (value) {
                setState(() {});
              },
            );
          }),
    );
  }

  FutureBuilder<List<TrackDTO>> trackList() {
    return FutureBuilder(
      future: futureTrackList,
      builder:
          (BuildContext context, AsyncSnapshot<List<TrackDTO>> tracksSnapshot) {
        if (tracksSnapshot.connectionState == ConnectionState.done) {
          if (tracksSnapshot.hasError) {
            return Text('Error: ${tracksSnapshot.error}');
          }

          if (tracksSnapshot.data == null) {
            return const Center(child: Text('The tracks are in the void'));
          }

          if (tracksSnapshot.data!.isEmpty) {
            return const Center(child: Text('No tracks found'));
          }

          return FutureBuilder(
              future: trackSortBy == TrackSortBy.title
                  ? futureTrackIdsSortedByTitle
                  : trackSortBy == TrackSortBy.artist
                      ? futureTrackIdsSortedByArtist
                      : trackSortBy == TrackSortBy.album
                          ? futureTrackIdsSortedByAlbum
                          : futureTrackIdsSortedByDuration,
              builder: (context, sortedTrackIdsSnapshot) {
                if (sortedTrackIdsSnapshot.connectionState ==
                    ConnectionState.done) {
                  if (sortedTrackIdsSnapshot.hasError) {
                    return Text('Error: ${sortedTrackIdsSnapshot.error}');
                  }

                  if (sortedTrackIdsSnapshot.data == null) {
                    return const Center(
                        child: Text('The tracks are in the void'));
                  }

                  List<TrackDTO> tracks = sortedTrackIdsSnapshot.data!
                      .map((id) => tracksSnapshot.data!
                          .firstWhere((track) => track.id == id))
                      .toList();

                  tracks = tracks
                      .where((track) => trackQueryFilterCondition(
                          query: searchQuery, track: track))
                      .toList();

                  if (trackSortOrder == TrackSortOrder.descending) {
                    tracks = tracks.reversed.toList();
                  }

                  if (tracks.isEmpty) {
                    return const Center(child: Text('No tracks found'));
                  }

                  return SuperListView.builder(
                    itemCount: tracks.length,
                    itemBuilder: (BuildContext context, int index) {
                      return trackListTile(tracks[index]);
                    },
                  );
                } else {
                  return const Center();
                }
              });
        } else {
          return const Center();
        }
      },
    );
  }

  ListTile trackListTile(TrackDTO track) {
    return ListTile(
      dense: true,
      leading: AspectRatio(
        aspectRatio: 1,
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(4)),
          child: track.pictureId != null
              ? Image.file(File("${getCachePath()}/${track.pictureId!}.jpg"),
                  filterQuality: FilterQuality.medium,
                  cacheHeight: 48,
                  fit: BoxFit.cover)
              : Container(
                  color: Colors.grey,
                  child: const Icon(Icons.music_note),
                ),
        ),
      ),
      title: Text(
        track.title ?? 'Unknown Track',
      ),
      subtitle: Text(track.artist ?? 'Unknown Artist'),
      trailing: Text(
        durationToString(duration: Duration(milliseconds: track.durationMs)),
      ),
      onTap: () {
        setState(() {
          setTrack(track);
          play();
        });
      },
    );
  }

  SliderThemeData nakedSliderThemeData() {
    return const SliderThemeData(
      trackHeight: 2,
      thumbShape:
          RoundSliderThumbShape(enabledThumbRadius: 2, pressedElevation: 0),
      overlayShape: RoundSliderOverlayShape(overlayRadius: 0),
    );
  }

  void setTrack(TrackDTO track) {
    player.setFilePath(track.location);
    currentTrack = track;
  }

  void play() {
    if (currentTrack == null) {
      return;
    }

    player.play();
  }

  void togglePlayPause() {
    if (currentTrack == null) {
      return;
    }

    if (player.playing) {
      player.pause();
    } else {
      player.play();
    }
  }

  void stopAndClear() {
    player.stop();
    currentTrack = null;
  }

  void stop() {
    player.stop();
  }
}
