import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_vimeo/src/constants.dart';
import 'package:flutter_vimeo/src/flutter_vimeo_player_mixin.dart';

/// Callback function triggered when the video duration is modified
typedef DurationCallBack =
    void Function(double? totalDuration, double? currentDuration);

/// Vimeo video player with customizable controls
///  and event callbacks using the [InAppWebView]
class FlutterVimeoPlayer extends StatefulWidget {
  /// Initializes the VimeoVideoPlayer widget
  const FlutterVimeoPlayer({
    required this.videoId,
    super.key,
    this.isAutoPlay = false,
    this.isLooping = false,
    this.isMuted = false,
    this.showTitle = false,
    this.showByline = false,
    this.showControls = true,
    this.enableDNT = true,
    this.startTime = 0.0,
    this.backgroundColor = Colors.black,
    this.showLog = false,
    this.onReady,
    this.onPlay,
    this.onPause,
    this.onFinish,
    this.onSeek,
    this.onTimeUpdate,
    this.onInAppWebViewCreated,
    this.onInAppWebViewLoadStart,
    this.onInAppWebViewLoadStop,
    this.onInAppWebViewReceivedError,
    this.onEnterFullscreen,
    this.onExitFullscreen,
    this.mediaPlaybackRequiresUserGesture = false,
    this.allowsInlineMediaPlayback = true,
    this.initialScale,
    this.quality = '720p'
  });

  /// Used to enable or disable logging
  ///  for debugging purposes
  final bool showLog;

  /// Defines the vimeo video ID to be played
  ///
  /// [videoId] is required and cannot be empty
  final String videoId;

  /// Used to auto-play the video once initialized
  ///
  /// Default value: false
  final bool isAutoPlay;

  /// Used to play the video in a loop after it ends
  ///
  /// Default value: false
  final bool isLooping;

  /// Used to play the video with the sound muted
  ///
  /// Default value: false
  final bool isMuted;

  /// Used to display the video title
  ///
  /// Default value: false
  final bool showTitle;

  /// Used to display the video byline/author
  ///
  /// Default value: false
  final bool showByline;

  /// Used to display the video playback controls
  ///
  /// Default value: true
  final bool showControls;

  /// Used to enable Do Not Track (DNT) mode
  /// When enabled, the player will not track any viewing information
  ///
  /// Default value: true
  final bool enableDNT;

  /// Defines the background color of the InAppWebView
  ///
  /// Default Value: [Colors.black]
  final Color backgroundColor;

  /// Defines a callback function triggered
  ///
  ///  when the player is ready to play the video
  final DurationCallBack? onReady;

  /// Defines a callback function triggered when the video begins playing
  final DurationCallBack? onPlay;

  /// Defines a callback function triggered when the video is paused
  final DurationCallBack? onPause;

  /// Defines a callback function triggered when the video playback finishes
  final DurationCallBack? onFinish;

  /// Defines a callback function triggered
  ///  when the video playback position is modified
  final DurationCallBack? onSeek;

  /// Defines a callback function triggered
  ///  when the video playback position is updated
  final DurationCallBack? onTimeUpdate;

  /// Defines a callback function triggered when the WebView is created
  final void Function(InAppWebViewController controller)? onInAppWebViewCreated;

  /// Defines a callback function triggered
  ///  when the WebView enters fullscreen mode
  final void Function(InAppWebViewController controller)? onEnterFullscreen;

  /// Defines a callback function triggered
  ///  when the WebView exits fullscreen mode
  final void Function(InAppWebViewController controller)? onExitFullscreen;

  /// Defines a callback function triggered
  ///  when the WebView starts to load an url
  final void Function(InAppWebViewController controller, WebUri? url)?
  onInAppWebViewLoadStart;

  /// Defines a callback function triggered
  ///  when the WebView finishes loading an url
  final void Function(InAppWebViewController controller, WebUri? url)?
  onInAppWebViewLoadStop;

  /// Defines a callback function triggered
  ///  when the WebView encounters an error loading a request
  final void Function(
    InAppWebViewController controller,
    WebResourceRequest request,
    WebResourceError error,
  )?
  onInAppWebViewReceivedError;

  /// Defines the start time of the video in seconds
  final double startTime;

  /// Set to true to prevent HTML5 audio or video from autoplaying
  final bool mediaPlaybackRequiresUserGesture;

  /// Set to true to allow inline media playback
  final bool allowsInlineMediaPlayback;

  final int? initialScale;

  //
  final String quality;

  @override
  State<FlutterVimeoPlayer> createState() => _FlutterVimeoPlayerState();
}

class _FlutterVimeoPlayerState extends State<FlutterVimeoPlayer>
    with FlutterVimeoPlayerMixin {
  @override
  Widget build(BuildContext context) {
    return InAppWebView(
      initialSettings: InAppWebViewSettings(
        transparentBackground: true,
        initialScale: widget.initialScale,
        mediaPlaybackRequiresUserGesture:
            widget.mediaPlaybackRequiresUserGesture,
        allowsInlineMediaPlayback: widget.allowsInlineMediaPlayback,
      ),
      onEnterFullscreen: widget.onEnterFullscreen,
      onExitFullscreen: widget.onExitFullscreen,
      initialData: InAppWebViewInitialData(
        data: buildHtmlContent(),
        baseUrl: WebUri(Constants.webUri),
      ),
      onConsoleMessage: onConsoleMessage,
      onWebViewCreated: widget.onInAppWebViewCreated,
      onLoadStart: widget.onInAppWebViewLoadStart,
      onLoadStop: widget.onInAppWebViewLoadStop,
      onReceivedError: widget.onInAppWebViewReceivedError,
    );
  }
}
