import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mixmax/Globals.dart';
import 'package:shared_preferences/shared_preferences.dart';

final player = AudioPlayer();

class drivelist extends StatefulWidget {
  const drivelist({super.key});

  @override
  State<drivelist> createState() => _drivelistState();
}

class _drivelistState extends State<drivelist> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () => {Navigator.pop(context)},
            icon: const Icon(
              CupertinoIcons.back,
              color: Colors.black,
            )),
        title: const Text(
          "Curated Playlist",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontFamily: 'sfpro',
            fontSize: 22.0,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              //await player.setAudioSource(playlistdrive,
              //    initialIndex: 0, initialPosition: Duration.zero);
              //player.play();
              //await player.setLoopMode(LoopMode.all);
              saveStringList(myStrings, "items");
            },
            icon:
                Icon(CupertinoIcons.play_arrow_solid, color: Color(0xFF059DC0)),
          ),
          IconButton(
            onPressed: () async{
              SharedPreferences prefs = await SharedPreferences.getInstance();
              print(prefs.getStringList('items'));
              showModalBottomSheet<void>(
                isScrollControlled: true,
                showDragHandle: true,
                context: context,
                builder: (BuildContext context) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                    child: SizedBox(
                      width: double.infinity,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          const Text(
                            'Upload Song Link..',
                            style: TextStyle(
                              color: Colors.black,
                              fontFamily: 'sfpro',
                              fontSize: 18.0,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: TextField(
                              autofocus: true,
                              onChanged: (value) {
                                link = value;
                              },
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                filled: true,
                                hintStyle: TextStyle(
                                  color: Colors.grey,
                                  fontFamily: 'sfpro',
                                ),
                                hintText: "Paste Your Link",
                                fillColor: Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 10, right: 10, top: 10),
                              child: ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStatePropertyAll<Color>(
                                          Color(0xFF059DC0)),
                                  shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  )),
                                ),
                                child: const Text(
                                  'Upload',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: 'sfpro',
                                    fontSize: 16.0,
                                  ),
                                ),
                                onPressed: () async {
                                  if (link != "") {
                                    await playlist.add(
                                      AudioSource.uri(Uri.parse(link)),
                                    );
                                  }
                                  link = "";
                                  //print(playlist.length);
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 10, right: 10, bottom: 10),
                              child: ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStatePropertyAll<Color>(
                                          Color(0xFF059DC0)),
                                  shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  )),
                                ),
                                child: const Text(
                                  'Done',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: 'sfpro',
                                    fontSize: 16.0,
                                  ),
                                ),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            icon: Icon(CupertinoIcons.share, color: Color(0xFF059DC0)),
          )
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
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
          Row(
            children: [
              Spacer(),
              IconButton(
                onPressed: () {
                  player.seekToPrevious();
                },
                icon: Icon(
                  CupertinoIcons.arrow_left_to_line,
                  size: 30,
                  color: Colors.black,
                ),
              ),
              Spacer(),
              IconButton(
                onPressed: () {
                  player.play();
                },
                icon: Icon(
                  CupertinoIcons.play_arrow_solid,
                  size: 50,
                  color: Color(0xFF059DC0),
                ),
              ),
              Spacer(),
              IconButton(
                onPressed: () {
                  player.pause();
                },
                icon: Icon(
                  CupertinoIcons.pause,
                  size: 50,
                  color: Color(0xFF059DC0),
                ),
              ),
              Spacer(),
              IconButton(
                onPressed: () {
                  player.seekToNext();
                },
                icon: Icon(
                  CupertinoIcons.arrow_right_to_line,
                  size: 30,
                  color: Colors.black,
                ),
              ),
              Spacer(),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 23, bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                Flexible(
                  child: Text(
                    "Now Playing:",
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
              padding: const EdgeInsets.only(
                  top: 8, left: 18, right: 18, bottom: 10),
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
                    StreamBuilder(
                      stream: Stream.periodic(const Duration(seconds: 1)),
                      builder: (context, snapshot) {
                        return Text(
                          "Playing All...${playlistdrive.length} Songs",
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'sfpro',
                            fontSize: 18.0,
                          ),
                        );
                      },
                    ),
                    Icon(CupertinoIcons.hourglass),
                    Spacer(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
