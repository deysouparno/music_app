import 'dart:io';

import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_app/cubit/albumart_cubit.dart';
import 'package:music_app/cubit/music_state_cubit.dart';
import 'package:music_app/data/music_player_class.dart';
import 'package:music_app/ui/screens/music_screen.dart';

class MusicList extends StatefulWidget {
  final String? heading;
  final List<SongInfo> songs;
  const MusicList({
    Key? key,
    this.heading,
    required this.songs,
  }) : super(key: key);

  @override
  _MusicListState createState() => _MusicListState();
}

class _MusicListState extends State<MusicList> {
  MetadataRetriever retriever = MetadataRetriever();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.heading == null
          ? null
          : AppBar(
              title: Text("All music"),
            ),
      body: ListView.separated(
          itemBuilder: (context, index) {
            SongInfo song = widget.songs[index];
            double size = int.parse(song.fileSize) / 1000;

            if (size > 1000) {
              size = size / 1000;
            }
            return ListTile(
              title: Text(
                song.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text("${size.toStringAsFixed(2)} kb"),
              // leading: FutureBuilder(
              //   future: retriever.setFile(File(song.filePath)),
              //   builder: (context, snapshot) {
              //     if (snapshot.connectionState == ConnectionState.done) {
              //       return retriever.albumArt == null
              //           ? Icon(Icons.music_note)
              //           : Image.memory(retriever.albumArt!);
              //     } else {
              //       return Icon(Icons.music_note);
              //     }
              //   },
              // ),
              leading: song.albumArtwork == null
                  ? Icon(
                      Icons.music_note,
                      color: Colors.blueAccent,
                    )
                  : Image(
                      image: FileImage(File(song
                          .albumArtwork!))), //Image.file(File(song.albumArtwork!)),
              onTap: () {
                MusicPlayer.loadSong(widget.songs[index]);
                MusicPlayer.playlist = widget.songs;
                MusicPlayer.index = index;
                BlocProvider.of<CurrentSongCubit>(context).emitSongChange();
                BlocProvider.of<AlbumArtCubit>(context)
                    .emitAlbumArtChanged(MusicPlayer.song!);

                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => CurrentSong(
                              flag: true,
                            )));
              },
            );
          },
          separatorBuilder: (_, index) {
            return Divider(
              thickness: 2.0,
            );
          },
          itemCount: widget.songs.length),
    );
  }
}
