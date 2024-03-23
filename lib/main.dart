import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';
import 'package:ncudio/src/rust/api/simple.dart';
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

class _MyAppState extends State<MyApp> {
  late Future<List<TrackDTO>> trackListFuture = getAllTracks();
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

    trackListFuture = getAllTracks();
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
        return Scaffold(
          appBar: AppBar(
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
              volumeToggleButton(),
              volumeSlider(),
              IconButton(
                icon: Icon(
                  themeMode == ThemeMode.light
                      ? Icons.light_mode
                      : Icons.dark_mode,
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
                        trackListFuture = getAllTracks();
                      }));
                },
              ),
            ],
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: trackList(),
              ),
              Container(
                height: 20,
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
                              var duration =
                                  durationSnapshot.data ?? Duration.zero;
                              var position =
                                  positionSnapshot.data ?? Duration.zero;
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
                                  player.seek(
                                      Duration(milliseconds: value.toInt()));
                                },
                              );
                            });
                      }),
                ),
              ),
              Container(
                height: 96,
                color: Theme.of(context).scaffoldBackgroundColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: buttomBar(),
              )
            ],
          ),
        );
      }),
    );
  }

  Row buttomBar() {
    var lhs = player.audioSource != null
        ? Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(4)),
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
              SizedBox(
                width: 8,
              ),
              Flexible(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SelectableText(currentTrack?.title ?? '',
                          maxLines: 1,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            overflow: TextOverflow.fade,
                          )),
                      SelectableText(currentTrack?.artist ?? '',
                          maxLines: 1,
                          style: const TextStyle(
                              fontWeight: FontWeight.normal,
                              overflow: TextOverflow.fade,
                              fontSize: 12)),
                      SelectableText(currentTrack?.album ?? '',
                          maxLines: 1,
                          style: const TextStyle(
                            fontWeight: FontWeight.normal,
                            overflow: TextOverflow.fade,
                            fontSize: 12,
                          )),
                      StreamBuilder<Duration?>(
                          stream: player.durationStream,
                          builder: (context, durationSnapshot) {
                            return StreamBuilder<Duration>(
                                stream: player.positionStream,
                                builder: (context, positionSnapshot) {
                                  var position =
                                      positionSnapshot.data ?? Duration.zero;
                                  final positionText = position.inHours > 0
                                      ? '${position.inHours}:${position.inMinutes.remainder(60).toString().padLeft(2, '0')}:${position.inSeconds.remainder(60).toString().padLeft(2, '0')}'
                                      : '${position.inMinutes}:${position.inSeconds.remainder(60).toString().padLeft(2, '0')}';

                                  if (durationSnapshot.data == null) {
                                    return Text(positionText);
                                  }

                                  var duration = durationSnapshot.data!;
                                  final durationText = duration.inHours > 0
                                      ? '${duration.inHours}:${duration.inMinutes.remainder(60).toString().padLeft(2, '0')}:${duration.inSeconds.remainder(60).toString().padLeft(2, '0')}'
                                      : '${duration.inMinutes}:${duration.inSeconds.remainder(60).toString().padLeft(2, '0')}';

                                  return Text('$positionText / $durationText');
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
                      padding: EdgeInsets.all(0.0),
                      iconSize: 16,
                      onPressed: () {},
                    ),
                  ),
                  SizedBox(
                    height: 24,
                    child: IconButton(
                      icon: const Icon(Icons.more_vert),
                      padding: EdgeInsets.all(0.0),
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
          icon: Icon(
            player.playing ? Icons.pause : Icons.play_arrow,
          ),
          onPressed: () {
            setState(() {
              if (player.playing) {
                player.pause();
              } else {
                player.play();
              }
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
                          trackListFuture = getAllTracks();
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
      future: trackListFuture,
      builder: (BuildContext context, AsyncSnapshot<List<TrackDTO>> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.data == null) {
            return const Center(child: Text('The tracks are in the void'));
          }

          if (snapshot.data!.isEmpty) {
            return const Center(child: Text('No tracks found'));
          }

          final tracks = snapshot.data!.where((track) {
            return (track.title?.toLowerCase().contains(searchQuery) ??
                    false) ||
                (track.artist?.toLowerCase().contains(searchQuery) ?? false) ||
                (track.album?.toLowerCase().contains(searchQuery) ?? false);
          }).toList();

          return SuperListView.builder(
            itemCount: tracks.length,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                dense: true,
                leading: AspectRatio(
                  aspectRatio: 1,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(4)),
                    child: tracks[index].pictureId != null
                        ? Image.file(
                            File(
                                "${getCachePath()}/${tracks[index].pictureId!}.jpg"),
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
                  tracks[index].title ?? 'Unknown Track',
                ),
                subtitle: Text(tracks[index].artist ?? 'Unknown Artist'),
                onTap: () {
                  setState(() {
                    currentTrack = tracks[index];
                    player.setFilePath(tracks[index].location);
                  });
                },
              );
            },
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
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
}
