import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:ncudio/src/rust/api/simple.dart';
import 'package:ncudio/src/rust/frb_generated.dart';
import 'package:ncudio/src/rust/model.dart';
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

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int msSliderValue = 0;
  int volumeSliderValue = 50;
  late Future<List<TrackDTO>> trackListFuture = getAllTracks();
  String searchQuery = '';

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

  ThemeData lightThemeData = ThemeData(
    primarySwatch: Colors.blue,
    brightness: Brightness.light,
  );

  ThemeData darkThemeData = ThemeData(
    primarySwatch: Colors.blue,
    brightness: Brightness.dark,
  );

  @override
  void initState() {
    super.initState();

    initialzeApp();
    initializeDb();

    trackListFuture = getAllTracks();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: themeMode,
      theme: lightThemeData,
      darkTheme: darkThemeData,
      home: Scaffold(
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
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: IconButton(
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
            ),
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
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SliderTheme(
                data: nakedSliderThemeData(),
                child: Slider(
                  min: 0,
                  max: Duration(minutes: 3, seconds: 37)
                      .inMilliseconds
                      .toDouble(),
                  value: msSliderValue.toDouble(),
                  divisions: Duration(minutes: 3, seconds: 37).inMilliseconds,
                  onChanged: (value) {
                    setState(() {
                      msSliderValue = value.toInt();
                    });
                  },
                ),
              ),
            ),
            Container(
              height: 96,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                      child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                        child: Image(
                          image: NetworkImage(
                              "https://f4.bcbits.com/img/a3247117645_10.jpg"),
                          filterQuality: FilterQuality.medium,
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
                            Text(
                                'HUG AND KIashdiuasdiouhajsoiudhasoidhoaijhdoiwLL',
                                maxLines: 1,
                                overflow: TextOverflow.fade,
                                softWrap: false,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            Text('Kobaryo',
                                maxLines: 1,
                                overflow: TextOverflow.fade,
                                softWrap: false,
                                style: const TextStyle(
                                    fontWeight: FontWeight.normal)),
                            Text(
                                "${Duration(milliseconds: msSliderValue).inMinutes}:${Duration(milliseconds: msSliderValue).inSeconds.remainder(60).toString().padLeft(2, '0')}/${Duration(minutes: 3, seconds: 37).inMinutes}:${Duration(minutes: 3, seconds: 37).inSeconds.remainder(60).toString().padLeft(2, '0')}",
                                overflow: TextOverflow.fade,
                                softWrap: false,
                                style: const TextStyle(
                                    fontWeight: FontWeight.normal)),
                          ],
                        ),
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
                  )),
                  Flexible(
                    child: ButtonBar(
                      alignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.skip_previous),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(Icons.play_circle_fill),
                          iconSize: 48,
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(Icons.skip_next),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.volume_up)),
                        SizedBox(
                          width: 4,
                        ),
                        SliderTheme(
                          data: nakedSliderThemeData(),
                          child: Slider(
                            min: 0,
                            max: 100,
                            divisions: 100,
                            value: volumeSliderValue.toDouble(),
                            onChanged: (value) {
                              setState(() {
                                volumeSliderValue = value.toInt();
                              });
                            },
                          ),
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        IconButton(
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
                            icon: const Icon(Icons.folder)),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
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
                leading: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                  child: tracks![index].pictureId != null
                      ? Image.file(
                          File(
                              "${getCachePath()}/${tracks[index].pictureId!}.jpg"),
                          filterQuality: FilterQuality.medium,
                          fit: BoxFit.cover)
                      : AspectRatio(
                          aspectRatio: 1,
                          child: Container(
                            color: Colors.grey,
                            child: const Icon(Icons.music_note),
                          )),
                ),
                title: Text(
                  tracks[index].title ?? 'Unknown Track',
                ),
                subtitle: Text(tracks[index].artist ?? 'Unknown Artist'),
                onTap: () {
                  print(tracks[index].location);
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
