import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
        title: const Text(
          "Firebase Playlist",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontFamily: 'sfpro',
            fontSize: 22.0,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      //upload song fab button
      floatingActionButton: FloatingActionButton(
        isExtended: true,
        onPressed: () {},
        backgroundColor: Color(0xFF059DC0),
        child: const Icon(CupertinoIcons.share_up),
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
