import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_vimeo/flutter_vimeo.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Vimeo Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _videoIdController = TextEditingController();
  bool _isAutoPlay = false;
  bool _isLooping = false;
  bool _isMuted = false;
  bool _showTitle = false;
  bool _showByline = false;
  bool _showControls = true;
  bool _enableDNT = true;

  FlutterVimeoController? flutterVimeoController;

  @override
  void dispose() {
    _videoIdController.dispose();
    flutterVimeoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter Vimeo Example')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _videoIdController,
              decoration: const InputDecoration(
                labelText: 'Vimeo Video ID',
                hintText: 'Enter Vimeo video ID',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            _buildToggleButtons(),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_videoIdController.text.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VimeoPlayerPage(
                        videoId: _videoIdController.text,
                        isAutoPlay: _isAutoPlay,
                        isLooping: _isLooping,
                        isMuted: _isMuted,
                        showTitle: _showTitle,
                        showByline: _showByline,
                        showControls: _showControls,
                        enableDNT: _enableDNT,
                        onInAppWebViewCreated: (controller) {
                          flutterVimeoController = FlutterVimeoController(
                              inAppWebViewController: controller)
                            ..onVideoStateChanged.listen(
                              (state) {
                                log('Video State Changed: $state');
                              },
                            );
                        },
                      ),
                    ),
                  );
                }
              },
              child: const Text('Play Video'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleButtons() {
    return Column(
      children: [
        _buildToggleButton(
          'Auto Play',
          _isAutoPlay,
          (value) => setState(() => _isAutoPlay = value),
        ),
        _buildToggleButton(
          'Loop',
          _isLooping,
          (value) => setState(() => _isLooping = value),
        ),
        _buildToggleButton(
          'Muted',
          _isMuted,
          (value) => setState(() => _isMuted = value),
        ),
        _buildToggleButton(
          'Show Title',
          _showTitle,
          (value) => setState(() => _showTitle = value),
        ),
        _buildToggleButton(
          'Show Byline',
          _showByline,
          (value) => setState(() => _showByline = value),
        ),
        _buildToggleButton(
          'Show Controls',
          _showControls,
          (value) => setState(() => _showControls = value),
        ),
        _buildToggleButton(
          'Enable DNT',
          _enableDNT,
          (value) => setState(() => _enableDNT = value),
        ),
      ],
    );
  }

  Widget _buildToggleButton(
    String label,
    bool value,
    void Function(bool) onChanged,
  ) {
    return SwitchListTile(
      title: Text(label),
      value: value,
      onChanged: onChanged,
    );
  }
}

class VimeoPlayerPage extends StatelessWidget {
  const VimeoPlayerPage({
    super.key,
    required this.videoId,
    required this.isAutoPlay,
    required this.isLooping,
    required this.isMuted,
    required this.showTitle,
    required this.showByline,
    required this.showControls,
    required this.enableDNT,
    required this.onInAppWebViewCreated,
  });

  final String videoId;
  final bool isAutoPlay;
  final bool isLooping;
  final bool isMuted;
  final bool showTitle;
  final bool showByline;
  final bool showControls;
  final bool enableDNT;
  final Function(dynamic controller)? onInAppWebViewCreated;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vimeo Player')),
      body: FlutterVimeoPlayer(
        videoId: videoId,
        isAutoPlay: isAutoPlay,
        isLooping: isLooping,
        isMuted: isMuted,
        showTitle: showTitle,
        showByline: showByline,
        showControls: showControls,
        enableDNT: enableDNT,
        onInAppWebViewCreated: onInAppWebViewCreated,
        onReady: (totalDuration, currentDuration) {
          debugPrint('Video ready: Total duration: $totalDuration');
        },
        onPlay: (totalDuration, currentDuration) {
          debugPrint('Video playing: Current duration: $currentDuration');
        },
        onPause: (totalDuration, currentDuration) {
          debugPrint('Video paused: Current duration: $currentDuration');
        },
        onFinish: (totalDuration, currentDuration) {
          debugPrint('Video finished');
        },
        onSeek: (totalDuration, currentDuration) {
          debugPrint('Video seeked to: $currentDuration');
        },
        onTimeUpdate: (totalDuration, currentDuration) {
          debugPrint('Time updated: $currentDuration');
        },
      ),
    );
  }
}
