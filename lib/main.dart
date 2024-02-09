import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mixmax/drivelist.dart';
import 'package:mixmax/firebasemusic.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:path/path.dart';
import 'package:rxdart/rxdart.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FlutterPlay Songs',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFF059DC0),
        ),
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'FlutterPlay Songs'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //define on audio plugin
  final OnAudioQuery _audioQuery = OnAudioQuery();

  // Indicate if application has permission to the library.
  bool _hasPermission = false;

  //today
  //player
  final AudioPlayer _player = AudioPlayer();

  //more variables
  List<SongModel> songs = [];
  String currentSongTitle = '';
  int currentIndex = 0;

  bool isPlayerViewVisible = false;

  //define a method to set the player view visibility
  void _changePlayerViewVisibility() {
    setState(() {
      isPlayerViewVisible = !isPlayerViewVisible;
    });
  }

  //duration state stream
  Stream<DurationState> get _durationStateStream =>
      Rx.combineLatest2<Duration, Duration?, DurationState>(
          _player.positionStream,
          _player.durationStream,
          (position, duration) => DurationState(
              position: position, total: duration ?? Duration.zero));

  checkAndRequestPermissions({bool retry = false}) async {
    // The param 'retryRequest' is false, by default.
    _hasPermission = await _audioQuery.checkAndRequest(
      retryRequest: retry,
    );

    // Only call update the UI if application has all required permissions.
    _hasPermission ? setState(() {}) : null;
  }

  //request permission from initStateMethod
  @override
  void initState() {
    super.initState();
    // Check and request for permission.
    checkAndRequestPermissions();

    //update the current playing song index listener
    _player.currentIndexStream.listen((index) {
      if (index != null) {
        _updateCurrentPlayingSongDetails(index);
      }
    });
  }

  //dispose the player when done
  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isPlayerViewVisible) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
              onPressed: _changePlayerViewVisibility,
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
          actions: [
            IconButton(
                onPressed: () {
                  _changePlayerViewVisibility();
                },
                icon: const Icon(
                  CupertinoIcons.music_note_list,
                  color: Colors.black,
                )),
          ],
        ),
        body: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 30.0, right: 15.0, left: 15.0),
            child: Column(
              children: <Widget>[
                //artwork container
                Container(
                  width: 308,
                  height: 406,
                  margin: const EdgeInsets.only(bottom: 30),
                  child: QueryArtworkWidget(
                    id: songs[currentIndex].id,
                    type: ArtworkType.AUDIO,
                    artworkBorder: BorderRadius.circular(12.0),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Flexible(
                        child: Text(
                          currentSongTitle,
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
                //slider , position and duration widgets
                Column(
                  children: [
                    //slider bar container
                    Container(
                      padding: EdgeInsets.only(top: 10, left: 8, right: 8),
                      margin: const EdgeInsets.only(bottom: 4.0),

                      //slider bar duration state stream
                      child: StreamBuilder<DurationState>(
                        stream: _durationStateStream,
                        builder: (context, snapshot) {
                          final durationState = snapshot.data;
                          final progress =
                              durationState?.position ?? Duration.zero;
                          final total = durationState?.total ?? Duration.zero;

                          return ProgressBar(
                            progress: progress,
                            total: total,
                            barHeight: 5.0,
                            baseBarColor: Color(0x14059DC0),
                            progressBarColor: Color(0xFF059DC0),
                            thumbColor: Color(0xFF059DC0),
                            timeLabelTextStyle: const TextStyle(
                              fontSize: 0,
                            ),
                            onSeek: (duration) {
                              _player.seek(duration);
                            },
                          );
                        },
                      ),
                    ),

                    //position /progress and total text
                    StreamBuilder<DurationState>(
                      stream: _durationStateStream,
                      builder: (context, snapshot) {
                        final durationState = snapshot.data;
                        final progress =
                            durationState?.position ?? Duration.zero;
                        final total = durationState?.total ?? Duration.zero;

                        return Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Flexible(
                                child: Text(
                                  progress.toString().split(".")[0],
                                  style: const TextStyle(
                                    fontFamily: 'sfpro',
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              Flexible(
                                child: Text(
                                  total.toString().split(".")[0],
                                  style: const TextStyle(
                                    fontFamily: 'sfpro',
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),

                //prev, play/pause & seek next control buttons
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        _player.setShuffleModeEnabled(true);
                        toast(context, "Shuffling enabled");
                      },
                      icon: const Icon(CupertinoIcons.shuffle),
                    ),
                    Spacer(),
                    IconButton(
                      onPressed: () {
                        if (_player.hasPrevious) {
                          _player.seekToPrevious();
                        }
                      },
                      icon: const Icon(
                        CupertinoIcons.backward_fill,
                      ),
                    ),

                    //play pause
                    Flexible(
                      child: InkWell(
                        onTap: () {
                          if (_player.playing) {
                            _player.pause();
                          } else {
                            if (_player.currentIndex != null) {
                              _player.play();
                            }
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(20.0),
                          child: StreamBuilder<bool>(
                            stream: _player.playingStream,
                            builder: (context, snapshot) {
                              bool? playingState = snapshot.data;
                              if (playingState != null && playingState) {
                                return const Icon(
                                  CupertinoIcons.pause,
                                  size: 50,
                                  color: Color(0xFF059DC0),
                                );
                              }
                              return const Icon(
                                CupertinoIcons.play_fill,
                                size: 50,
                                color: Color(0xFF059DC0),
                              );
                            },
                          ),
                        ),
                      ),
                    ),

                    //skip to next
                    IconButton(
                      onPressed: () {
                        if (_player.hasNext) {
                          _player.seekToNext();
                        }
                      },
                      icon: const Icon(CupertinoIcons.forward_fill),
                    ),
                    //repeat mode
                    Spacer(),
                    Flexible(
                      child: InkWell(
                        onTap: () {
                          _player.loopMode == LoopMode.one
                              ? _player.setLoopMode(LoopMode.all)
                              : _player.setLoopMode(LoopMode.one);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(20.0),
                          child: StreamBuilder<LoopMode>(
                            stream: _player.loopModeStream,
                            builder: (context, snapshot) {
                              final loopMode = snapshot.data;
                              if (LoopMode.one == loopMode) {
                                return const Icon(CupertinoIcons.repeat_1);
                              }
                              return const Icon(CupertinoIcons.repeat);
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {},
            icon: const Icon(
              CupertinoIcons.settings_solid,
              color: Colors.black,
            )),
        title: const Text(
          "Music App",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontFamily: 'sfpro',
            fontSize: 22.0,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: !_hasPermission
          ? noAccessToLibraryWidget()
          : FutureBuilder<List<SongModel>>(
              //default values
              future: _audioQuery.querySongs(
                orderType: OrderType.ASC_OR_SMALLER,
                uriType: UriType.EXTERNAL,
                ignoreCase: true,
              ),
              builder: (context, item) {
                //loading content indicator
                if (item.data == null) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                //no songs found
                if (item.data!.isEmpty) {
                  return const Center(
                    child: Text("No Songs Found"),
                  );
                }

                // You can use [item.data!] direct or you can create a list of songs as
                // List<SongModel> songs = item.data!;
                //showing the songs

                //add songs to the song list
                songs.clear();
                songs = item.data!;
                return Column(
                  children: [
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 30, left: 40, right: 40),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () async {
                              const url = 'https://open.spotify.com/';
                              if (await canLaunchUrlString(url)) {
                                await launchUrlString(url,mode: LaunchMode.inAppWebView);
                              } else {
                                throw 'Could not launch $url';
                              }
                            },
                            child: SvgPicture.asset(
                              'assets/spotify.svg',
                            ),
                          ),
                          Spacer(),
                          GestureDetector(
                            onTap: () async {
                              const url = 'https://www.youtube.com/';
                              if (await canLaunchUrlString(url)) {
                                await launchUrlString(url,mode: LaunchMode.inAppWebView);
                              } else {
                                throw 'Could not launch $url';
                              }
                            },
                            child: SvgPicture.asset(
                              'assets/youtube.svg',
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 20, left: 40, right: 40, bottom: 10),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => firebasemusic()),
                              );
                            },
                            child: SvgPicture.asset(
                              'assets/playlist.svg',
                            ),
                          ),
                          Spacer(),
                          GestureDetector(
                            onTap: () {
                              //Navigator.push(
                              //  context,
                              //  MaterialPageRoute(
                              //      builder: (context) => drivelist()),
                              //);
                            },
                            child: SvgPicture.asset(
                              'assets/gcd.svg',
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 15, top: 15, right: 15, bottom: 15),
                          child: const Text(
                            "Device Files",
                            style: TextStyle(
                              fontFamily: 'sfpro',
                              fontSize: 18.0,
                            ),
                          ),
                        ),
                        Spacer(),
                      ],
                    ),
                    Expanded(
                      child: ListView.builder(
                          itemCount: item.data!.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                  left: 10, right: 10, bottom: 10),
                              child: Material(
                                child: ListTile(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15)),
                                  tileColor: Color(0x14059DC0),
                                  title: Text(
                                    item.data![index].title,
                                    style: TextStyle(
                                      fontFamily: 'sfpro',
                                    ),
                                  ),
                                  subtitle: Text(
                                    item.data![index].artist ?? "No Artist",
                                    style: TextStyle(
                                      fontFamily: 'sfpro',
                                    ),
                                  ),
                                  trailing: const Icon(
                                    CupertinoIcons.play_fill,
                                    color: Color(0xFF059DC0),
                                  ),
                                  // This Widget will query/load image.
                                  // You can use/create your own widget/method using [queryArtwork].
                                  leading: QueryArtworkWidget(
                                    controller: _audioQuery,
                                    id: item.data![index].id,
                                    type: ArtworkType.AUDIO,
                                  ),
                                  onTap: () async {
                                    //show the player view
                                    _changePlayerViewVisibility();

                                    toast(context,
                                        "Playing:  " + item.data![index].title);
                                    // Try to load audio from a source and catch any errors.
                                    //  String? uri = item.data![index].uri;
                                    // await _player.setAudioSource(AudioSource.uri(Uri.parse(uri!)));
                                    await _player.setAudioSource(
                                        createPlaylist(item.data!),
                                        initialIndex: index);
                                    await _player.play();
                                  },
                                ),
                              ),
                            );
                          }),
                    ),
                  ],
                );
              },
            ),
    );
  }

  //define a toast method
  void toast(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(text),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.0)),
    ));
  }

  //create playlist
  ConcatenatingAudioSource createPlaylist(List<SongModel> songs) {
    List<AudioSource> sources = [];
    for (var song in songs) {
      sources.add(AudioSource.uri(Uri.parse(song.uri!)));
    }
    return ConcatenatingAudioSource(children: sources);
  }

  //update playing song details
  void _updateCurrentPlayingSongDetails(int index) {
    setState(() {
      if (songs.isNotEmpty) {
        currentSongTitle = songs[index].title;
        currentIndex = index;
      }
    });
  }

  BoxDecoration getDecoration(
      BoxShape shape, Offset offset, double blurRadius, double spreadRadius) {
    return BoxDecoration(
      shape: shape,
      boxShadow: [
        BoxShadow(
          offset: -offset,
          color: Colors.white24,
          blurRadius: blurRadius,
          spreadRadius: spreadRadius,
        ),
        BoxShadow(
          offset: offset,
          color: Colors.black,
          blurRadius: blurRadius,
          spreadRadius: spreadRadius,
        )
      ],
    );
  }

  BoxDecoration getRectDecoration(BorderRadius borderRadius, Offset offset,
      double blurRadius, double spreadRadius) {
    return BoxDecoration(
      borderRadius: borderRadius,
      boxShadow: [
        BoxShadow(
          offset: -offset,
          color: Colors.white24,
          blurRadius: blurRadius,
          spreadRadius: spreadRadius,
        ),
        BoxShadow(
          offset: offset,
          color: Colors.black,
          blurRadius: blurRadius,
          spreadRadius: spreadRadius,
        )
      ],
    );
  }

  Widget noAccessToLibraryWidget() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.redAccent.withOpacity(0.5),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Application doesn't have access to the library"),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () => checkAndRequestPermissions(retry: true),
            child: const Text("Allow"),
          ),
        ],
      ),
    );
  }
}

//duration class
class DurationState {
  DurationState({this.position = Duration.zero, this.total = Duration.zero});
  Duration position, total;
}
