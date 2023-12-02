import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mixmax/firebasemusic.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends StatelessWidget {
  const VideoPlayerScreen({
    super.key,
    required Future<void> initializeVideoPlayerFuture,
    required VideoPlayerController controller,
  })  : _initializeVideoPlayerFuture = initializeVideoPlayerFuture,
        _controller = controller;

  final Future<void> _initializeVideoPlayerFuture;
  final VideoPlayerController _controller;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          // If the VideoPlayerController has finished initialization, use
          // the data it provides to limit the aspect ratio of the video.
          return VideoPlayer(_controller);
        } else {
          // If the VideoPlayerController is still initializing, show a
          // loading spinner.
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}

class MusicScreen extends StatefulWidget {
  const MusicScreen(this.songName, this.songUrl, {super.key});
  final String songName;
  final String songUrl;
  @override
  State<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;

  final audioPlayer = AudioPlayer();
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    setAudio();
    audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        isPlaying = state == PlayerState.playing;
      });
    });
    audioPlayer.onDurationChanged.listen((d) {
      setState(() {
        duration = d;
      });
    });
    audioPlayer.onPositionChanged.listen((p) {
      setState(() {
        position = p;
      });
    });
    // Create and store the VideoPlayerController. The VideoPlayerController
    // offers several different constructors to play videos from assets, files,
    // or the internet.
    _controller = VideoPlayerController.asset(
      'assets/demo.mp4',
    );
    _controller.setLooping(true);
    _initializeVideoPlayerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    // Ensure disposing of the VideoPlayerController to free up resources.
    _controller.dispose();

    super.dispose();
  }

  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    @override
    String url = widget.songUrl;

    List<bool> selected = <bool>[];
    selected.add(false);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () => {
                  audioPlayer.dispose(),
                  //Navigator.push(
                  //  context,
                  //  MaterialPageRoute(builder: (context) => firebasemusic()),
                  //)
                  Navigator.pop(context),
                },
            icon: const Icon(
              CupertinoIcons.back,
              color: Colors.black,
            )),
        title: const Text(
          "Now Playing",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontFamily: 'sfpro',
            fontSize: 22.0,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(children: [
        SizedBox(
          height: 20,
        ),
        Center(
          child: Icon(
            CupertinoIcons.music_note_2,
            size: 200,
            color: Color(0xFF059DC0),
          ),
        ),
        SizedBox(
          height: 20,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 23, bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: [
              Flexible(
                child: Text(
                  widget.songName,
                  style: TextStyle(
                    color: Colors.black,
                    fontFamily: 'sfpro',
                    fontSize: 18.0,
                  ),
                ),
                flex: 5,
              ),
            ],
          ),
        ),
        //music slider
        Builder(builder: (context) {
          return SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 30,
            child: Slider(
              value: position.inSeconds.toDouble(),
              min: 0,
              max: duration.inSeconds.toDouble(),
              thumbColor: Color(0xFF059DC0),
              activeColor: Color(0xFF059DC0),
              inactiveColor: Color(0x14059DC0),
              onChanged: (value) async {
                final position = Duration(seconds: value.toInt());
                await audioPlayer.seek(position);
                await audioPlayer.resume();
                // setState(() {
                //   audioPlayer.seek(Duration(seconds: value.toInt()));
                // });
              },
            ),
          );
        }),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 23),
              child: Text(
                formatTime(position),
                style: const TextStyle(
                  fontFamily: 'sfpro',
                  color: Colors.black,
                  fontSize: 15,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 23),
              child: Text(
                formatTime(duration),
                style: const TextStyle(
                  fontFamily: 'sfpro',
                  color: Colors.black,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationY(pi),
              child: IconButton(
                padding: const EdgeInsets.all(0),
                onPressed: () async {
                  final position = Duration(seconds: 0);
                  await audioPlayer.seek(position);
                  await audioPlayer.resume();
                },
                icon: const Icon(
                  CupertinoIcons.refresh,
                  color: Colors.black,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: IconButton(
                splashColor: Color(0xFF059DC0),
                splashRadius: 30,
                alignment: Alignment.center,
                padding: const EdgeInsets.all(0),
                onPressed: () async {
                  if (isPlaying) {
                    await audioPlayer.pause();
                  } else {
                    await audioPlayer.resume();
                  }
                  setState(() {
                    if (_controller.value.isPlaying) {
                      _controller.pause();
                    } else {
                      _controller.pause();
                    }
                  });
                },
                icon: isPlaying
                    ? const Icon(
                        CupertinoIcons.pause,
                        size: 50,
                        color: Color(0xFF059DC0),
                      )
                    : const Icon(
                        CupertinoIcons.play_fill,
                        size: 50,
                        color: Color(0xFF059DC0),
                      ),
              ),
            ),
            IconButton(
                padding: const EdgeInsets.all(0),
                onPressed: () async {
                  setState(() {
                    selected[0] = !selected[0];
                    selected[0]
                        ? audioPlayer.setReleaseMode(ReleaseMode.loop)
                        : audioPlayer.setReleaseMode(ReleaseMode.release);
                  });
                },
                icon: Icon(
                  selected[0] ? CupertinoIcons.repeat_1 : CupertinoIcons.repeat,
                )),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 23, bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: [
              Flexible(
                child: Text(
                  "Lyrics:",
                  style: TextStyle(
                    color: Colors.black,
                    fontFamily: 'sfpro',
                    fontSize: 18.0,
                  ),
                ),
                flex: 5,
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding:
                const EdgeInsets.only(top: 8, left: 18, right: 18, bottom: 10),
            child: Container(
              decoration: BoxDecoration(
                  color: Color(0xFF059DC0),
                  border: Border.all(
                    color: Color(0xFF059DC0),
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(20))),
              child: Row(
                children: [
                  Spacer(),
                  Text(
                    "Loading...",
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'sfpro',
                      fontSize: 18.0,
                    ),
                  ),
                  Icon(CupertinoIcons.hourglass),
                  Spacer(),
                ],
              ),
            ),
          ),
        ),
      ]),
    );
  }

  String formatTime(Duration duration) {
    String twoDigits(int n) {
      if (n >= 10) return "$n";
      return "0$n";
    }

    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  Future setAudio() async {
    String url = widget.songUrl;
    await audioPlayer.setSourceUrl(url);
  }
}
