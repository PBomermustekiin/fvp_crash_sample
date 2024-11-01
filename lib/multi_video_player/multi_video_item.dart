import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'multi_video_model.dart';

/// Stateful widget to fetch and then display video content.
/// ignore: must_be_immutable
class MultiVideoItem extends StatefulWidget {
  dynamic videoSource;
  int index;
  Function(VideoPlayerController controller) onInit;
  Function(int index) onDispose;
  VideoPlayerOptions? videoPlayerOptions;
  VideoSource sourceType;
  Future<ClosedCaptionFile>? closedCaptionFile;
  Map<String, String>? httpHeaders;
  VideoFormat? formatHint;
  String? package;
  bool showControlsOverlay;
  bool showVideoProgressIndicator;
  bool show = true;
  bool playPauseWithTap;
  bool? showIndicatorPlayPauseButton;

  MultiVideoItem({
    super.key,
    required this.videoSource,
    required this.index,
    required this.onInit,
    required this.onDispose,
    this.videoPlayerOptions,
    this.closedCaptionFile,
    this.httpHeaders,
    this.formatHint,
    this.package,
    this.showIndicatorPlayPauseButton,
    this.playPauseWithTap = false,
    this.showControlsOverlay = true,
    this.showVideoProgressIndicator = true,
    required this.sourceType,
  });

  @override
  State<MultiVideoItem> createState() => _MultiVideoItemState();
}

class _MultiVideoItemState extends State<MultiVideoItem> {
  late VideoPlayerController _controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  /// initializes videos
  void _initializeVideo() {
    if (widget.sourceType == VideoSource.network) {
      _controller = VideoPlayerController.networkUrl(
        widget.videoSource,
        videoPlayerOptions: widget.videoPlayerOptions,
        closedCaptionFile: widget.closedCaptionFile,
        httpHeaders: widget.httpHeaders ?? {},
        formatHint: widget.formatHint,
      );
    } else if (widget.sourceType == VideoSource.asset) {
      _controller = VideoPlayerController.asset(
        widget.videoSource,
        videoPlayerOptions: widget.videoPlayerOptions,
        closedCaptionFile: widget.closedCaptionFile,
        package: widget.package,
      );
    } else if (widget.sourceType == VideoSource.file) {
      _controller = VideoPlayerController.file(
        widget.videoSource,
        videoPlayerOptions: widget.videoPlayerOptions,
        closedCaptionFile: widget.closedCaptionFile,
        httpHeaders: widget.httpHeaders ?? {},
      );
    }
    _controller.initialize().then((_) {
      widget.onInit.call(_controller);
      if (widget.index == MultiVideo.currentIndex) {
        _controller.play();
      }
      _controller.addListener(() => _videoListener());
      if (mounted) {
        setState(() => isLoading = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _controller.value.isInitialized
              ? _controller.value.aspectRatio > 1.0
                  ? Stack(
                      children: [
                        Center(
                          child: AspectRatio(
                            aspectRatio: _controller.value.aspectRatio,
                            child: Stack(
                              alignment: Alignment.bottomCenter,
                              children: <Widget>[
                                FittedBox(
                                  fit: BoxFit
                                      .cover, // Make the video cover the entire container
                                  child: SizedBox(
                                    width: _controller.value.size.width,
                                    height: _controller.value.size.height,
                                    child: VideoPlayer(_controller),
                                  ),
                                ),
                                widget.showControlsOverlay
                                    ? _ControlsOverlay(
                                        controller: _controller,
                                        playPauseWithTap:
                                            widget.playPauseWithTap,
                                      )
                                    : const SizedBox.shrink(),

                                //     // widget.showVideoProgressIndicator
                                //     //     ? VideoProgressIndicator(_controller,
                                //     //         allowScrubbing: true)
                                //     : const SizedBox.shrink(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : Center(
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: <Widget>[
                          FittedBox(
                            fit: BoxFit
                                .cover, // Make the video cover the entire container
                            child: SizedBox(
                              width: _controller.value.size.width,
                              height: _controller.value.size.height,
                              child: VideoPlayer(_controller),
                            ),
                          ),
                          widget.showControlsOverlay
                              ? _ControlsOverlay(
                                  controller: _controller,
                                  playPauseWithTap: widget.playPauseWithTap,
                                )
                              : const SizedBox.shrink(),
                          // widget.showVideoProgressIndicator
                          //     ? VideoProgressIndicator(_controller,
                          //         allowScrubbing: true)
                          //     : const SizedBox.shrink(),
                        ],
                      ),
                    )
              : const SizedBox.shrink(),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    widget.onDispose.call(widget.index);
  }

  _videoListener() {
    if (widget.index != MultiVideo.currentIndex) {
      if (_controller.value.isInitialized) {
        if (_controller.value.isPlaying) {
          _controller.pause();
        }
      }
    }
    if (mounted) {
      setState(() {});
    }
  }
}

class _ControlsOverlay extends StatefulWidget {
  const _ControlsOverlay(
      {required this.controller, this.playPauseWithTap = false});

  final VideoPlayerController controller;
  final bool playPauseWithTap;

  @override
  State<_ControlsOverlay> createState() => _ControlsOverlayState();
}

class _ControlsOverlayState extends State<_ControlsOverlay> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 50),
          reverseDuration: const Duration(milliseconds: 200),
          child: widget.controller.value.isPlaying
              ? const SizedBox.shrink()
              : const Center(
                  child: SizedBox(),
                ),
        ),
      ],
    );
  }
}
