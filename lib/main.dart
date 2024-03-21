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
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: SuperListView(
                  padding: const EdgeInsets.only(top: 10),
                  primary: true,
                  scrollDirection: Axis.vertical,
                  children: [
                    ...List.generate(
                        2000,
                        (index) => ListTile(
                              leading: const Image(
                                image: NetworkImage(
                                    "https://f4.bcbits.com/img/a3247117645_10.jpg"),
                                filterQuality: FilterQuality.medium,
                              ),
                              title: Text('HUG AND KILL'),
                              subtitle: Text('Kobaryo'),
                              dense: true,
                              trailing: Text('03:37'),
                              onTap: () {},
                            )),
                  ],
                ),
              ),
              SizedBox(
                height: 96,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Flexible(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.network(
                            "https://f4.bcbits.com/img/a3247117645_10.jpg",
                            fit: BoxFit.cover,
                            isAntiAlias: true,
                            filterQuality: FilterQuality.medium,
                          ),
                          const SizedBox(width: 10),
                          Flexible(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Flexible(
                                  child: Container(
                                    constraints:
                                        const BoxConstraints(maxHeight: 24),
                                    child: LayoutBuilder(
                                      builder: (context, constraints) {
                                        TextSpan text = const TextSpan(
                                            text:
                                                "HUG AND KILLsaojdoiajdoiwjdaslkdj",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16));
                                        TextPainter textPainter = TextPainter(
                                            text: text,
                                            maxLines: 1,
                                            textDirection: TextDirection.ltr);

                                        textPainter.layout(
                                            maxWidth: constraints.maxWidth);

                                        return textPainter.didExceedMaxLines
                                            ? Marquee(
                                                text:
                                                    "HUG AND KILLsaojdoiajdoiwjdaslkdj",
                                                style: const TextStyle(
                                                    overflow: TextOverflow.fade,
                                                    fontSize: 16),
                                                textDirection:
                                                    TextDirection.ltr,
                                                scrollAxis: Axis.horizontal,
                                                velocity: 25,
                                                blankSpace: 20,
                                                onDone: () {
                                                  print("DONE");
                                                },
                                                pauseAfterRound: const Duration(
                                                    milliseconds: 1500),
                                              )
                                            : const Text(
                                                "HUG AND KILLsaojdoiajdoiwjdaslkdj",
                                                maxLines: 1,
                                                softWrap: false,
                                                overflow: TextOverflow.fade,
                                                textDirection:
                                                    TextDirection.ltr,
                                                style: TextStyle(fontSize: 16));
                                      },
                                    ),
                                  ),
                                ),
                                Text("Kobaryo",
                                    maxLines: 1,
                                    overflow: TextOverflow.fade,
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 12)),
                              ],
                            ),
                          ),
                          Center(
                            child: IconButton(
                              iconSize: 10,
                              icon: const Icon(Icons.favorite_border, size: 20),
                              onPressed: () {},
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.shuffle),
                                  iconSize: 20,
                                  onPressed: () {},
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                IconButton(
                                  icon: Icon(Icons.skip_previous),
                                  iconSize: 20,
                                  onPressed: () {},
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                ElevatedButton(
                                  onPressed: () {},
                                  child: Icon(Icons.play_arrow),
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                IconButton(
                                  icon: Icon(Icons.skip_next),
                                  iconSize: 20,
                                  onPressed: () {},
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                IconButton(
                                  icon: Icon(Icons.repeat),
                                  iconSize: 20,
                                  onPressed: () {},
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 600),
                              child: Row(
                                children: [
                                  const Text("00:00",
                                      textAlign: TextAlign.end,
                                      style: TextStyle(fontSize: 12)),
                                  Expanded(
                                    child: SliderTheme(
                                      data: SliderTheme.of(context).copyWith(
                                        overlayShape:
                                            const RoundSliderOverlayShape(
                                                overlayRadius: 10),
                                        trackShape:
                                            const RoundedRectSliderTrackShape(),
                                        trackHeight: 2,
                                        thumbShape: const RoundSliderThumbShape(
                                            enabledThumbRadius: 2),
                                      ),
                                      child: Slider.adaptive(
                                        value: 0.5,
                                        max: const Duration(
                                                minutes: 3, seconds: 37)
                                            .inMilliseconds
                                            .toDouble(),
                                        min: 0,
                                        divisions: const Duration(
                                                minutes: 3, seconds: 37)
                                            .inMilliseconds,
                                        onChanged: (double value) {},
                                      ),
                                    ),
                                  ),
                                  const Text("03:37",
                                      textAlign: TextAlign.start,
                                      style: TextStyle(fontSize: 12)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(Icons.volume_up),
                            onPressed: () {},
                          ),
                          Container(
                            constraints: const BoxConstraints(maxWidth: 100),
                            child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                overlayShape: const RoundSliderOverlayShape(
                                    overlayRadius: 10),
                                trackShape: const RoundedRectSliderTrackShape(),
                                trackHeight: 2,
                                thumbShape: const RoundSliderThumbShape(
                                    enabledThumbRadius: 2),
                              ),
                              child: Slider.adaptive(
                                value: 50,
                                max: 100,
                                min: 0,
                                divisions: 100,
                                onChanged: (double value) {},
                              ),
                            ),
                          ),
                          ButtonBar(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.queue_music),
                                onPressed: () {},
                              ),
                              IconButton(
                                icon: const Icon(Icons.playlist_play),
                                onPressed: () {},
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
