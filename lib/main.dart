import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:super_context_menu/super_context_menu.dart';
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
  late TrackSortBy trackSortBy = TrackSortBy.album;
  late TrackSortOrder trackSortOrder = TrackSortOrder.ascending;

  late TextEditingController searchController;

  final FocusNode searchTextFieldFocusNode = FocusNode();
  final FocusNode progressSliderFocusNode = FocusNode();

  final player = AudioPlayer();
  final ValueNotifier<ConcatenatingAudioSource> playlist =
      ValueNotifier(ConcatenatingAudioSource(children: []));

  final _listController = ListController();
  final _scrollController = ScrollController();

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

    initializeApp();
    initializeDb();

    searchController = TextEditingController();
    searchController.addListener(() {
      setState(() {});
    });

    lastVolume = player.volume;

    player.setAudioSource(playlist.value);

    refreshTrackList();
  }

  @override
  void dispose() {
    player.dispose();

    searchController.dispose();

    searchTextFieldFocusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: lightThemeData,
      darkTheme: darkThemeData,
      home: Shortcuts(
        shortcuts: {
          LogicalKeySet(LogicalKeyboardKey.arrowDown): const DownArrowIntent(),
          LogicalKeySet(LogicalKeyboardKey.arrowUp): const UpArrowIntent(),
          LogicalKeySet(LogicalKeyboardKey.mediaPlayPause):
              const PlayPauseIntent(),
          LogicalKeySet(LogicalKeyboardKey.mediaSkip):
              const SkipBackwardIntent(),
          LogicalKeySet(LogicalKeyboardKey.mediaSkipBackward):
              const SkipForwardIntent(),
          LogicalKeySet(LogicalKeyboardKey.slash): const FocusSearchIntent(),
          LogicalKeySet(LogicalKeyboardKey.enter): const EnterIntent(),
          LogicalKeySet(LogicalKeyboardKey.escape): const EscapeIntent(),
        },
        child: Actions(
          actions: {
            PlayPauseIntent: PlayPauseAction(player),
            SkipBackwardIntent: SkipBackwardAction(player),
            SkipForwardIntent: SkipForwardAction(player),
            FocusSearchIntent: FocusSearchAction(searchTextFieldFocusNode),
          },
          child: FocusScope(
            autofocus: true,
            child: Builder(builder: (context) {
              return homePage(context);
            }),
          ),
        ),
      ),
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
          child: progressSlider(),
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

  SliderTheme progressSlider() {
    return SliderTheme(
      data: nakedSliderThemeData(),
      child: StreamBuilder<Duration?>(
          stream: player.durationStream,
          builder: (context, durationSnapshot) {
            var duration = durationSnapshot.data ?? Duration.zero;
            return StreamBuilder<Duration>(
                stream: player.positionStream,
                builder: (context, positionSnapshot) {
                  var position = positionSnapshot.data ?? Duration.zero;

                  if (position < Duration.zero) {
                    position = Duration.zero;
                  }

                  if (position > duration) {
                    position = duration;
                  }
                  return Actions(
                    actions: {
                      PlayPauseIntent: PlayPauseAction(player),
                      DownArrowIntent: DoNothingAction(),
                    },
                    child: Slider(
                      focusNode: progressSliderFocusNode,
                      min: 0,
                      max: duration.inMilliseconds.toDouble(),
                      value: position < Duration.zero
                          ? 0
                          : position.inMilliseconds.toDouble(),
                      onChanged: (value) {
                        player.seek(Duration(milliseconds: value.toInt()));
                      },
                    ),
                  );
                });
          }),
    );
  }

  AppBar appBar() {
    return AppBar(
      flexibleSpace: Actions(
        actions: {
          FocusSearchIntent: DoNothingAction(),
        },
        child: TextField(
          focusNode: searchTextFieldFocusNode,
          controller: searchController,
          decoration: const InputDecoration(
            hintText: 'Search',
            prefixIcon: Icon(Icons.search),
            border: InputBorder.none,
          ),
        ),
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
                  refreshTrackList();
                }));
          },
        ),
      ],
    );
  }

  void refreshTrackList() {
    futureTrackList = getAllTracks();
    futureTrackIdsSortedByTitle = getAllTrackIdsSortedByTitle();
    futureTrackIdsSortedByArtist = getAllTrackIdsSortedByArtist();
    futureTrackIdsSortedByAlbum = getAllTrackIdsSortedByAlbum();
    futureTrackIdsSortedByDuration = getAllTrackIdsSortedByDuration();
  }

  Row bottomBarInner() {
    var lhs = StreamBuilder<SequenceState?>(
        stream: player.sequenceStateStream,
        builder: (context, snapshot) {
          if (snapshot.data == null) {
            return const Center();
          }

          var sequenceState = snapshot.data!;

          if (sequenceState.currentSource == null) {
            return const Center();
          }

          final currentTrack = playlist
              .value.sequence[sequenceState.currentIndex].tag as TrackDTO;

          return Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(4)),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: currentTrack.pictureId != null
                      ? Image(
                          image: FileImage(File(
                              "${getCachePath()}/${currentTrack.pictureId!}.jpg")),
                          filterQuality: FilterQuality.medium,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) {
                              return child;
                            }
                            return const SizedBox();
                          },
                          frameBuilder:
                              (context, child, frame, wasSynchronouslyLoaded) {
                            if (wasSynchronouslyLoaded) {
                              return child;
                            }
                            return AnimatedOpacity(
                              opacity: frame == null ? 0 : 1,
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeOut,
                              child: child,
                            );
                          },
                        )
                      : Container(
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
                      SelectableText(currentTrack.title ?? '',
                          maxLines: 1,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            overflow: TextOverflow.fade,
                          )),
                      SelectableText(currentTrack.artist?.name ?? '',
                          maxLines: 1,
                          style: const TextStyle(
                              fontWeight: FontWeight.normal,
                              overflow: TextOverflow.fade,
                              fontSize: 11)),
                      SelectableText(currentTrack.album?.name ?? '',
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
          );
        });
    var mid = ButtonBar(
      alignment: MainAxisAlignment.center,
      children: [
        StreamBuilder<LoopMode>(
            stream: player.loopModeStream,
            builder: (context, snapshot) {
              return IconButton(
                icon: Icon(
                  snapshot.data == LoopMode.off
                      ? Icons.repeat
                      : snapshot.data == LoopMode.one
                          ? Icons.repeat_one
                          : Icons.repeat,
                  color: snapshot.data == LoopMode.off
                      ? Theme.of(context).iconTheme.color?.withOpacity(0.3)
                      : Theme.of(context).iconTheme.color,
                ),
                onPressed: () {
                  if (snapshot.data == null) {
                    return;
                  }

                  player.setLoopMode(snapshot.data == LoopMode.off
                      ? LoopMode.all
                      : snapshot.data == LoopMode.all
                          ? LoopMode.one
                          : LoopMode.off);
                },
              );
            }),
        StreamBuilder<bool>(
            stream: player.shuffleModeEnabledStream,
            builder: (context, snapshot) {
              return IconButton(
                icon: Icon(
                  snapshot.data != null && snapshot.data!
                      ? Icons.shuffle
                      : Icons.shuffle_outlined,
                  color: snapshot.data != null && snapshot.data!
                      ? Theme.of(context).iconTheme.color
                      : Theme.of(context).iconTheme.color?.withOpacity(0.3),
                ),
                onPressed: () {
                  player.setShuffleModeEnabled(
                      snapshot.data != null ? !snapshot.data! : true);
                },
              );
            }),
        IconButton(
          icon: const Icon(Icons.skip_previous),
          onPressed: () {
            player.seekToPrevious();
          },
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
            togglePlayPause();
          },
        ),
        IconButton(
          icon: const Icon(Icons.skip_next),
          onPressed: () {
            player.seekToNext().then((value) {
              printPlayerInfo();
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
        if (player.volume > 0) {
          lastVolume = player.volume;
          player.setVolume(0);
        } else {
          player.setVolume(lastVolume);
        }
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
                          refreshTrackList();
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
                          query: searchController.text, track: track))
                      .toList();

                  if (trackSortOrder == TrackSortOrder.descending) {
                    tracks = tracks.reversed.toList();
                  }

                  if (tracks.isEmpty) {
                    return const Center(child: Text('No tracks found'));
                  }

                  return ValueListenableBuilder(
                      valueListenable: searchController,
                      builder: (context, _, __) {
                        return SuperListView.builder(
                          listController: _listController,
                          controller: _scrollController,
                          itemCount: tracks.length,
                          itemBuilder: (BuildContext context, int index) {
                            return trackListTile(
                              tracks[index],
                            );
                          },
                        );
                      });
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

  Widget trackListTile(TrackDTO track, {FocusNode? focusNode}) {
    return ContextMenuWidget(
      menuProvider: (MenuRequest request) {
        return Menu(children: () {
          var actions = <MenuElement>[
            MenuAction(
                callback: () {
                  setTrack(track);
                  play();
                },
                title: "Play",
                image: MenuImage.icon(Icons.play_arrow)),
            MenuAction(
                title: "Add to Queue",
                callback: () {
                  AddToQueueAction(track, player, playlist.value).invoke(null);
                },
                image: MenuImage.icon(Icons.queue)),
          ];

          if (track.album != null) {
            actions.add(MenuAction(
                title: "Add Album to Queue",
                callback: () {
                  findTrackByAlbum(albumId: track.album!.id).then((tracks) {
                    AddManyToQueueAction(tracks, player, playlist.value)
                        .invoke(null);
                  });
                },
                image: MenuImage.icon(Icons.queue_music)));
          }

          if (track.album != null || track.artist != null) {
            var searchMenu = Menu(
              children: [],
              title: "Search",
            );
            if (track.album != null) {
              searchMenu.children.add(MenuAction(
                title: track.album!.name,
                callback: () {
                  searchController.text = track.album!.name;
                },
                image: MenuImage.icon(Icons.album),
              ));
            }
            if (track.artist != null) {
              searchMenu.children.add(MenuAction(
                title: track.artist!.name,
                callback: () {
                  searchController.text = track.artist!.name;
                },
                image: MenuImage.icon(Icons.people),
              ));
            }
            actions.add(searchMenu);
          }
          return actions;
        }());
      },
      child: ListTile(
        focusNode: focusNode,
        dense: true,
        leading: AspectRatio(
          aspectRatio: 1,
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(4)),
            child: track.pictureId != null
                ? Image.file(
                    File("${getCachePath()}/${track.pictureId!}.jpg"),
                    filterQuality: FilterQuality.medium,
                    cacheHeight: 48,
                    fit: BoxFit.cover,
                    frameBuilder:
                        (context, child, frame, wasSynchronouslyLoaded) {
                      if (wasSynchronouslyLoaded) {
                        return child;
                      }
                      return AnimatedOpacity(
                        opacity: frame == null ? 0 : 1,
                        duration: const Duration(milliseconds: 1000),
                        curve: Curves.easeOut,
                        child: child,
                      );
                    },
                  )
                : Container(
                    color: Colors.grey,
                    child: const Icon(Icons.music_note),
                  ),
          ),
        ),
        title: Text(
          track.title ?? 'Unknown Track',
        ),
        subtitle: () {
          if (track.artist != null && track.album != null) {
            return Text('${track.artist!.name} - ${track.album!.name}');
          } else if (track.artist != null) {
            return Text(track.artist!.name);
          } else if (track.album != null) {
            return Text(track.album!.name);
          }
          return const Text('');
        }(),
        trailing: Text(
          durationToString(duration: Duration(milliseconds: track.durationMs)),
        ),
        onTap: () {
          if (HardwareKeyboard.instance.isShiftPressed) {
            AddToQueueAction(track, player, playlist.value).invoke(null);
          } else {
            setTrack(track);
            play();
          }
        },
      ),
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
    final source = AudioSource.uri(Uri.file(track.location), tag: track);
    playlist.value.add(source);
    player.setAudioSource(playlist.value,
        initialIndex: playlist.value.length - 1);
  }

  // void addTrackNext(TrackDTO track) {
  //   final source = AudioSource.uri(Uri.file(track.location), tag: track);
  //   if (player.currentIndex == null) {
  //     playlist.value.add(source);
  //     return;
  //   }

  //   playlist.value.insert(player.currentIndex! + 1, source);
  // }

  void play() {
    player.play();
  }

  void togglePlayPause() {
    if (player.playing) {
      player.pause();
    } else {
      player.play();
    }
  }

  void stopAndClear() {
    player.stop();
  }

  void stop() {
    player.stop();
  }

  void printPlayerInfo() {
    print('Player Info:');
    print('Playing: ${player.playing}');
    print('LoopMode: ${player.loopMode}');
    print('ShuffleMode: ${player.shuffleModeEnabled}');
    print('Volume: ${player.volume}');
    print('Position: ${player.position}');
    print('Duration: ${player.duration}');
    print('CurrentIndex: ${player.currentIndex}');
    print('Sequence: ${player.sequence}');
  }
}

class PlayPauseIntent extends Intent {
  const PlayPauseIntent();
}

class PlayPauseAction extends Action<PlayPauseIntent> {
  final AudioPlayer player;

  PlayPauseAction(this.player);

  @override
  Object? invoke(PlayPauseIntent intent) {
    if (player.playing) {
      player.pause();
    } else {
      player.play();
    }
    return null;
  }
}

class PlaybackIntent extends Intent {
  const PlaybackIntent();
}

class SkipBackwardIntent extends Intent {
  const SkipBackwardIntent();
}

class SkipBackwardAction extends Action<SkipBackwardIntent> {
  final AudioPlayer player;

  SkipBackwardAction(this.player);

  @override
  Object? invoke(SkipBackwardIntent intent) {
    player.seekToPrevious();
    return null;
  }
}

class SkipForwardIntent extends Intent {
  const SkipForwardIntent();
}

class SkipForwardAction extends Action<SkipForwardIntent> {
  final AudioPlayer player;

  SkipForwardAction(this.player);

  @override
  Object? invoke(SkipForwardIntent intent) {
    player.seekToNext();
    return null;
  }
}

class LoggingShortcutManager extends ShortcutManager {
  @override
  KeyEventResult handleKeypress(BuildContext context, KeyEvent event) {
    final KeyEventResult result = super.handleKeypress(context, event);
    if (result == KeyEventResult.handled) {
      print('Handled shortcut $event in $context');
    }
    return result;
  }
}

/// An ActionDispatcher that logs all the actions that it invokes.
class LoggingActionDispatcher extends ActionDispatcher {
  @override
  Object? invokeAction(
    covariant Action<Intent> action,
    covariant Intent intent, [
    BuildContext? context,
  ]) {
    print('Action invoked: $action($intent) from $context');
    super.invokeAction(action, intent, context);

    return null;
  }
}

class FocusSearchIntent extends Intent {
  const FocusSearchIntent();
}

class FocusSearchAction extends Action<FocusSearchIntent> {
  final FocusNode focusNode;

  FocusSearchAction(this.focusNode);

  @override
  Object? invoke(FocusSearchIntent intent) {
    focusNode.requestFocus();
    return null;
  }
}

class EnterIntent extends Intent {
  const EnterIntent();
}

class EscapeIntent extends Intent {
  const EscapeIntent();
}

class UpArrowIntent extends Intent {
  const UpArrowIntent();
}

class DownArrowIntent extends Intent {
  const DownArrowIntent();
}

class FocusOrNullAction extends Action<Intent> {
  final FocusNode? focusNode;

  FocusOrNullAction(this.focusNode);

  @override
  Object? invoke(Intent intent) {
    if (focusNode == null) {
      return null;
    }

    focusNode!.requestFocus();
    return null;
  }
}

class DoNothingAction extends Action<Intent> {
  @override
  Object? invoke(Intent intent) {
    return null;
  }
}

class AddToQueueAction extends Action<Intent> {
  final TrackDTO track;
  final AudioPlayer player;
  final ConcatenatingAudioSource playlist;

  AddToQueueAction(this.track, this.player, this.playlist);

  @override
  Object? invoke(Intent? intent) {
    playlist.add(AudioSource.uri(Uri.file(track.location), tag: track));

    if (player.sequenceState?.currentSource == null) {
      player.setAudioSource(playlist, initialIndex: playlist.length - 1);
      return null;
    }

    if (player.currentIndex != null &&
        !player.playing &&
        player.duration != null &&
        player.position.inSeconds == player.duration!.inSeconds) {
      player.setAudioSource(playlist, initialIndex: player.currentIndex! + 1);
    }
    return null;
  }
}

class AddManyToQueueAction extends Action<Intent> {
  final List<TrackDTO> tracks;
  final AudioPlayer player;
  final ConcatenatingAudioSource playlist;

  AddManyToQueueAction(this.tracks, this.player, this.playlist);

  @override
  Object? invoke(Intent? intent) {
    for (var track in tracks) {
      playlist.add(AudioSource.uri(Uri.file(track.location), tag: track));
    }

    if (player.sequenceState?.currentSource == null) {
      player.setAudioSource(playlist, initialIndex: playlist.length - 1);
      return null;
    }

    if (player.currentIndex != null &&
        !player.playing &&
        player.duration != null &&
        player.position.inSeconds == player.duration!.inSeconds) {
      player.setAudioSource(playlist, initialIndex: player.currentIndex! + 1);
    }
    return null;
  }
}
