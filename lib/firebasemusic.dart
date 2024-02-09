import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mixmax/Globals.dart';
import 'package:mixmax/drivelist.dart';
import 'package:mixmax/firebasemusicscreen.dart';

class firebasemusic extends StatefulWidget {
  const firebasemusic({super.key});

  @override
  State<firebasemusic> createState() => _firebasemusicState();
}

class _firebasemusicState extends State<firebasemusic> {
  Future getData() async {
    QuerySnapshot qn =
        await FirebaseFirestore.instance.collection("songs").get();
    return qn.docs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              CupertinoIcons.music_note_list,
              color: Colors.black,
            )),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
              onPressed: () async {
                showModalBottomSheet<void>(
                  context: context,
                  builder: (BuildContext context) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                );
                // call firebase update playlist
                var collection = FirebaseFirestore.instance.collection('songs');
                var querySnapshot = await collection.get();
                for (var queryDocumentSnapshot in querySnapshot.docs) {
                  Map<String, dynamic> data = queryDocumentSnapshot.data();
                  //print(data['song']);
                  await playlist.add(
                    AudioSource.uri(Uri.parse(data["song"])),
                  );
                }
                await player.setAudioSource(playlist,
                    initialIndex: 0, initialPosition: Duration.zero);
                player.play();
                await player.setLoopMode(LoopMode.all);
                if (player.playing == true) {
                  Navigator.pop(context);
                }
              },
              icon: Icon(
                CupertinoIcons.refresh_thick,
                color: Colors.black,
              )),
          IconButton(
            onPressed: () {
              player.play();
            },
            icon: Icon(
              CupertinoIcons.play_fill,
              color: Colors.black,
            ),
          ),
          IconButton(
            onPressed: () {
              player.pause();
            },
            icon: Icon(
              CupertinoIcons.pause,
              color: Colors.black,
            ),
          ),
          IconButton(
            onPressed: () async{
              await player.seekToPrevious();
            },
            icon: Icon(
              CupertinoIcons.arrow_left_to_line,
              color: Colors.black,
            ),
          ),
          IconButton(
            onPressed: () async{
              await player.seekToNext();
            },
            icon: Icon(
              CupertinoIcons.arrow_right_to_line,
              color: Colors.black,
            ),
          ),
          IconButton(
            onPressed: () async {
              await playlist.clear();
            },
            icon: Icon(
              CupertinoIcons.delete,
              color: Colors.black,
            ),
          ),
        ],
      ),
      body: FutureBuilder(
          future: getData(),
          builder: (context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (snapshot.hasError) {
              return Center(
                  child: const Text(
                'Something went wrong',
                style: TextStyle(
                  fontFamily: 'sfpro',
                ),
              ));
            } else {
              return ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MusicScreen(
                                  snapshot.data[index].data()['song_name'],
                                  snapshot.data[index].data()['song'])),
                        );
                      },
                      child: listSong(snapshot.data[index].data()['song_name'],
                          snapshot.data[index].data()['artist']),
                    );
                  });
            }
          }),
    );
  }

  Widget listSong(String songName, String artistName) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
      child: Material(
        child: ListTile(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          tileColor: Color(0x14059DC0),
          leading: const CircleAvatar(
              backgroundColor: Color(0xffD9D9D9),
              child: Icon(CupertinoIcons.music_note,
                  size: 25, color: Color(0xFF059DC0))),
          title: Text(
            songName,
            style: TextStyle(
              fontFamily: 'sfpro',
            ),
          ),
          subtitle: Text(
            artistName,
            style: TextStyle(
              fontFamily: 'sfpro',
            ),
          ),
          trailing: Icon(
            CupertinoIcons.play_fill,
            color: Color(0xFF059DC0),
          ),
        ),
      ),
    );
  }
}
