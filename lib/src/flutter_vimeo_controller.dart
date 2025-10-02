import 'dart:async';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_vimeo/src/flutter_vimeo_video_state.dart';

///? A controller for the [FlutterVimeoPlayer] widget.
///? It allows you to control the player and listen to events.
///? This controller is used internally by the [FlutterVimeoPlayer] widget.
class FlutterVimeoController {
  ///? Creates a [FlutterVimeoController] with the given [InAppWebViewController].
  ///? The [InAppWebViewController] is used to control the web view.
  FlutterVimeoController({required this.inAppWebViewController}) {
    _attachHandlers();
  }

  ///? The [InAppWebViewController] used to control the web view.
  ///? This is the controller that is used to control the web view.
  final InAppWebViewController? inAppWebViewController;

  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;

  bool _isPaused = false;
  bool get isPaused => _isPaused;

  bool _isEnded = false;
  bool get isEnded => _isEnded;

  final StreamController<FlutterVimeoVideoState> _stateController =
      StreamController<FlutterVimeoVideoState>.broadcast();

  /// Stream to listen video state changes
  Stream<FlutterVimeoVideoState> get onVideoStateChanged =>
      _stateController.stream;

  void _attachHandlers() {
    inAppWebViewController?.addJavaScriptHandler(
      handlerName: 'vimeoState',
      callback: (args) {
        final state = args.first;
        if (state == 'playing') {
          _emitState(FlutterVimeoVideoState.playing);
          _isPlaying = true;
          _isPaused = false;
          _isEnded = false;
        } else if (state == 'paused') {
          _emitState(FlutterVimeoVideoState.paused);
          _isPlaying = false;
          _isPaused = true;
          _isEnded = false;
        } else if (state == 'ended') {
          _emitState(FlutterVimeoVideoState.ended);
          _isPlaying = false;
          _isPaused = false;
          _isEnded = true;
        }
      },
    );
  }

  ///? Emits the current video state to the stream
  void _emitState(FlutterVimeoVideoState state) {
    _stateController.add(state);
  }

  ///? The [videoId] is the ID of the video to be loaded.
  ///? The [videoId] is required and cannot be empty.
  void nextVideoWithJS(String nextVideoId) {
    final jsCode = "player.loadVideo($nextVideoId);";
    inAppWebViewController?.evaluateJavascript(source: jsCode);
    _isPlaying = false;
    _isPaused = false;
    _isEnded = false;
  }

  ///? Plays the video.
  Future<void> playVideo() async {
    await inAppWebViewController?.evaluateJavascript(source: "player.play();");
  }

  ///? Pauses the video.
  Future<void> pauseVideo() async {
    await inAppWebViewController?.evaluateJavascript(source: "player.pause();");
  }

  ///? Disposes the controller and closes the stream.
  void dispose() {
    _stateController.close();
    inAppWebViewController?.removeJavaScriptHandler(handlerName: 'vimeoState');
    inAppWebViewController?.stopLoading();
  }
}
