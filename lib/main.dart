import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:marquee/marquee.dart';
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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          flexibleSpace: const TextField(
            decoration: InputDecoration(
              hintText: 'Search',
              prefixIcon: Icon(Icons.search),
              border: InputBorder.none,
            ),
          ),
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
                            onPressed: () {}, icon: const Icon(Icons.settings)),
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

  SuperListView trackList() {
    return SuperListView(
      padding: const EdgeInsets.only(top: 10),
      primary: true,
      scrollDirection: Axis.vertical,
      children: [
        ...List.generate(
            2000,
            (index) => ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                    child: const Image(
                      image: NetworkImage(
                          "https://f4.bcbits.com/img/a3247117645_10.jpg"),
                      filterQuality: FilterQuality.medium,
                    ),
                  ),
                  title: Text('HUG AND KILL'),
                  subtitle: Text(
                    'Kobaryo',
                  ),
                  dense: true,
                  trailing: Text('03:37'),
                  onTap: () {},
                )),
      ],
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
