import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoWidget extends StatefulWidget {
  final String url;

  const VideoWidget({
    super.key,
    required this.url,
  });

  @override
  State<VideoWidget> createState() =>
      _VideoWidgetState();
}

class _VideoWidgetState
    extends State<VideoWidget> {

  late VideoPlayerController controller;

  bool initialized = false;

  bool showControls = false;

  double volume = 1.0;

  Timer? hideTimer;

  @override
  void initState() {
    super.initState();

    controller =
        VideoPlayerController.networkUrl(
      Uri.parse(widget.url),
    );

    controller.initialize().then((_) {

      if (!mounted) return;

      controller.setVolume(volume);

      setState(() {
        initialized = true;
      });
    });

    controller.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    hideTimer?.cancel();
    controller.dispose();
    super.dispose();
  }

  void showOverlay() {

    setState(() {
      showControls = true;
    });

    hideTimer?.cancel();

    hideTimer = Timer(
      const Duration(seconds: 3),
      () {

        if (!mounted) return;

        setState(() {
          showControls = false;
        });
      },
    );
  }

  String formatDuration(
    Duration duration,
  ) {

    String two(int n) =>
        n.toString().padLeft(2, "0");

    return "${two(duration.inMinutes.remainder(60))}:${two(duration.inSeconds.remainder(60))}";
  }

  @override
  Widget build(BuildContext context) {

    if (!initialized) {
      return const SizedBox(
        height: 200,
        child: Center(
          child:
              CircularProgressIndicator(),
        ),
      );
    }

    return MouseRegion(
      onEnter: (_) => showOverlay(),
      child: GestureDetector(
        onTap: showOverlay,
        child: Stack(
          alignment: Alignment.center,
          children: [

            AspectRatio(
              aspectRatio:
                  controller
                      .value
                      .aspectRatio,
              child: ClipRRect(
                borderRadius:
                    BorderRadius.circular(
                  12,
                ),
                child: VideoPlayer(
                  controller,
                ),
              ),
            ),

            if (showControls)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color:
                        Colors.black38,
                    borderRadius:
                        BorderRadius
                            .circular(
                      12,
                    ),
                  ),
                ),
              ),

            if (showControls)

              Row(
                mainAxisAlignment:
                    MainAxisAlignment
                        .center,
                children: [

                  IconButton(
                    icon: const Icon(
                      Icons.replay_10,
                      color:
                          Colors.white,
                      size: 32,
                    ),
                    onPressed: () {

                      final current =
                          controller
                              .value
                              .position;

                      controller.seekTo(
                        current -
                        const Duration(
                          seconds: 10,
                        ),
                      );

                      showOverlay();
                    },
                  ),

                  const SizedBox(
                    width: 24,
                  ),

                  IconButton(
                    iconSize: 60,
                    icon: Icon(
                      controller
                              .value
                              .isPlaying
                          ? Icons.pause_circle
                          : Icons
                              .play_circle,
                      color:
                          Colors.white,
                    ),
                    onPressed: () {

                      if (controller
                          .value
                          .isPlaying) {

                        controller
                            .pause();
                      } else {

                        controller
                            .play();
                      }

                      showOverlay();
                    },
                  ),

                  const SizedBox(
                    width: 24,
                  ),

                  IconButton(
                    icon: const Icon(
                      Icons.forward_10,
                      color:
                          Colors.white,
                      size: 32,
                    ),
                    onPressed: () {

                      final current =
                          controller
                              .value
                              .position;

                      controller.seekTo(
                        current +
                        const Duration(
                          seconds: 10,
                        ),
                      );

                      showOverlay();
                    },
                  ),
                ],
              ),

            if (showControls)

              Positioned(
                left: 8,
                right: 8,
                bottom: 0,
                child: Column(
                  children: [

                    VideoProgressIndicator(
                      controller,
                      allowScrubbing:
                          true,
                      colors:
                          VideoProgressColors(
                        playedColor:
                            Colors.red,
                        bufferedColor:
                            Colors.white24,
                        backgroundColor:
                            Colors.white10,
                      ),
                    ),

                    const SizedBox(
                      height: 4,
                    ),

                    Row(
                      children: [

                        Text(
                          formatDuration(
                            controller
                                .value
                                .position,
                          ),
                          style:
                              const TextStyle(
                            color:
                                Colors.white,
                          ),
                        ),

                        const Spacer(),

                        Text(
                          formatDuration(
                            controller
                                .value
                                .duration,
                          ),
                          style:
                              const TextStyle(
                            color:
                                Colors.white,
                          ),
                        ),
                      ],
                    ),

                    Row(
                      children: [

                        IconButton(
                          icon: Icon(
                            volume == 0
                                ? Icons
                                    .volume_off
                                : Icons
                                    .volume_up,
                            color:
                                Colors.white,
                          ),
                          onPressed:
                              () {

                            setState(
                              () {

                                volume =
                                    volume ==
                                            0
                                        ? 1.0
                                        : 0.0;
                              },
                            );

                            controller
                                .setVolume(
                              volume,
                            );
                          },
                        ),

                        Expanded(
                          child: Slider(
                            value: volume,
                            min: 0,
                            max: 1,
                            activeColor:
                                Colors.red,
                            onChanged:
                                (
                              value,
                            ) {

                              setState(
                                () {
                                  volume =
                                      value;
                                },
                              );

                              controller
                                  .setVolume(
                                value,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}