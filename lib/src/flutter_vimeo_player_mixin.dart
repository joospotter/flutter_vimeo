import 'dart:developer' as dev;
import 'package:flutter/widgets.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_vimeo/src/flutter_vimeo_player.dart';

/// A mixin that provides common functionality for the FlutterVimeoPlayer widget
/// This mixin can be used to add common functionality
///  to the FlutterVimeoPlayer widget.
/// It is used to manage the state of the player, handle events, and provide
mixin FlutterVimeoPlayerMixin on State<FlutterVimeoPlayer> {
  /// Converts Color to a hexadecimal string
  String colorToHex(Color color) {
    final a = (color.a * 255)
        .toInt()
        .toRadixString(16)
        .padLeft(2, '0'); // Alpha
    final r = (color.r * 255).toInt().toRadixString(16).padLeft(2, '0'); // Red
    final g = (color.g * 255)
        .toInt()
        .toRadixString(16)
        .padLeft(2, '0'); // Green
    final b = (color.b * 255).toInt().toRadixString(16).padLeft(2, '0'); // Blue

    return '#$r$g$b$a'; // Return hex color
  }

  /// Builds the iframe URL
  String buildIframeUrl() {
    return 'https://player.vimeo.com/video/${widget.videoId}?'
        'autoplay=${widget.isAutoPlay}'
        '&loop=${widget.isLooping}'
        '&muted=${widget.isMuted}'
        '&title=${widget.showTitle}'
        '&byline=${widget.showByline}'
        '&controls=${widget.showControls}'
        '&dnt=${widget.enableDNT}'
        '&quality=${widget.quality}';
  }

  /// Handles the console messages from the WebView
  void onConsoleMessage(
    InAppWebViewController controller,
    ConsoleMessage consoleMessage,
  ) {
    final message = consoleMessage.message;
    if (widget.showLog) {
      dev.log('onConsoleMessage :: $message');
    }

    // Match the format: eventType: (totalDuration, currentDuration) {}
    final regex = RegExp(r'(\w+): \((\d+\.?\d*), (\d+\.?\d*)\) \{\}');
    final match = regex.firstMatch(message);

    if (match != null) {
      final event = match.group(1); // Event type
      final totalDuration = double.tryParse(
        match.group(2) ?? '0',
      ); // Total duration
      final currentDuration = double.tryParse(
        match.group(3) ?? '0',
      ); // Current duration

      switch (event) {
        case 'onReady':
          widget.onReady?.call(totalDuration, currentDuration);

          if (widget.showLog) {
            dev.log('onReady: Total Duration: $totalDuration seconds');
          }
        case 'onPlay':
          widget.onReady?.call(totalDuration, currentDuration);

          if (widget.showLog) {
            dev.log(
              'onPlay: Total Duration: $totalDuration seconds, Current Duration: $currentDuration seconds',
            );
          }
          widget.onPlay?.call(totalDuration, currentDuration);

        case 'onPause':
          widget.onPause?.call(totalDuration, currentDuration);

          if (widget.showLog) {
            dev.log(
              'onPause: Total Duration: $totalDuration seconds, Current Duration: $currentDuration seconds',
            );
          }
        case 'onFinish':
          widget.onFinish?.call(totalDuration, currentDuration);

          if (widget.showLog) {
            dev.log('onFinish: Total Duration: $totalDuration seconds');
          }
        case 'onSeek':
          widget.onSeek?.call(totalDuration, currentDuration);

          if (widget.showLog) {
            dev.log('onSeek: Current Duration: $currentDuration seconds');
          }
        case 'onTimeUpdate':
          widget.onTimeUpdate?.call(totalDuration, currentDuration);

          if (widget.showLog) {
            dev.log('onTimeUpdate: Current Duration: $currentDuration seconds');
          }
        default:
          if (widget.showLog) {
            dev.log('Unknown event type: $event');
          }
      }
    }
  }

  /// Builds the HTML content for the InAppWebView
  String buildHtmlContent() {
    return '''
  <!DOCTYPE html>
  <html>
    <head>
      <style>
        body {
          margin: 0;
          padding: 0;
          background-color: ${colorToHex(widget.backgroundColor)};
        }
        .video-container {
          position: relative;
          width: 100%;
          height: 100vh;
        }
        iframe {
          position: absolute;
          top: 0;
          left: 0;
          width: 100%;
          height: 100%;
        }
      </style>
      <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
      <script src="https://player.vimeo.com/api/player.js"></script>
    </head>
    <body>
      <div class="video-container">
        <iframe 
          id="player"
          src="${buildIframeUrl()}"
          frameborder="0"
          allow="autoplay; fullscreen; picture-in-picture"
          allowfullscreen 
          webkitallowfullscreen 
          mozallowfullscreen>
        </iframe>
      </div>
      <script>
        const player = new Vimeo.Player('player');

        // Event listeners
        player.ready().then(() => {
            // Seek to the desired start time when the player is ready
            player.setCurrentTime(${widget.startTime});
            logEventWithDurations('onReady');
          });
          
        player.on('play', () => {
          window.flutter_inappwebview.callHandler('vimeoState', 'playing');
        });
        player.on('pause', () => {
          window.flutter_inappwebview.callHandler('vimeoState', 'paused');
        });
        player.on('ended', () => {
          window.flutter_inappwebview.callHandler('vimeoState', 'ended');
        });

        player.on('seeked', () => logEventWithDurations('onSeek'));
        player.on('timeupdate', () => logEventWithDurations('onTimeUpdate'));

        // Log events with current and total durations
        function logEventWithDurations(eventType) {
          player.getDuration().then(totalDuration => {
            player.getCurrentTime().then(currentDuration => {
              console.log(`\${eventType}: (\${totalDuration}, \${currentDuration}) {}`);
            });
          });
        }
      </script>
    </body>
  </html>
  ''';
  }
}
