import 'package:flutter/material.dart';
import 'package:music_app/data/collection.dart';
import 'package:music_app/ui/screens/all_music.dart';

class AlbumsScreen extends StatelessWidget {
  const AlbumsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      children: Collection.folders
          .map((e) => Container(
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MusicList(
                                  heading: "${e.name}",
                                  songs: e.songs,
                                )));
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                          flex: 3,
                          child: Container(
                              height: 100,
                              width: 100,
                              child: Image.asset("assets/music-album.png"))),
                      Flexible(
                          flex: 1,
                          child: Container(
                            height: 80.0,
                            child: Column(
                              children: [
                                Flexible(
                                    flex: 1,
                                    child: Text(
                                      e.name,
                                      style: TextStyle(fontSize: 13.0),
                                    )),
                                Flexible(
                                    flex: 1,
                                    child: Text("${e.songs.length} items",
                                        maxLines: 1,
                                        style: TextStyle(fontSize: 13.0)))
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
              ))
          .toList(),
    );
  }
}
