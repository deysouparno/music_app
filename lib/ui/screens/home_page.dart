import 'dart:io';

// ignore: import_of_legacy_library_into_null_safe
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:marquee/marquee.dart';
import 'package:music_app/cubit/albumart_cubit.dart';
import 'package:music_app/cubit/music_state_cubit.dart';
import 'package:music_app/cubit/slider_cubit.dart';
import 'package:music_app/data/collection.dart';
import 'package:music_app/data/music_player_class.dart';

import 'album_screen.dart';
import 'all_music.dart';
import 'music_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

// MetadataRetriever retriever = MetadataRetriever();

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    stream = player.createPositionStream();
    subscription = stream!.listen((event) {
      if (event.inMilliseconds.toDouble() >= MusicPlayer.max) {
        BlocProvider.of<MusicStateCubit>(context).emitMusicStoppedState();
      } else {
        BlocProvider.of<SliderCubit>(context)
            .update(event.inMilliseconds.toDouble());
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MusicPlayer.song == null) {
      MusicPlayer.loadSong(Collection.allsongs[0]);
      BlocProvider.of<AlbumArtCubit>(context)
          .emitAlbumArtChanged(MusicPlayer.song!);
    }
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          body: Column(
            children: [
              Container(
                height: MediaQuery.of(context).size.height - 80,
                child: Scaffold(
                  appBar: AppBar(
                    title: Text("Music App"),
                    bottom: TabBar(
                      tabs: [
                        Tab(
                          text: "Albums",
                          icon: Icon(
                            Icons.folder,
                            color: Colors.blueAccent,
                          ),
                        ),
                        Tab(
                          text: "All Songs",
                          icon: Icon(
                            Icons.music_note,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                  body: TabBarView(
                    children: [
                      AlbumsScreen(),
                      MusicList(
                        songs: Collection.allsongs,
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                color: Colors.black12,
                padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                height: 80,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CurrentSong(
                                  flag: false,
                                )));
                  },
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Hero(
                            tag: "image",
                            child: BlocBuilder<AlbumArtCubit, AlbumArtState>(
                                builder: (context, state) {
                              return state.albumArt == null
                                  ? Image.asset("assets/music-note.png")
                                  : Image.memory(state.albumArt!);
                            })),
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Flexible(
                              fit: FlexFit.loose,
                              flex: 1,
                              child: BlocBuilder<CurrentSongCubit,
                                  CurrentSongState>(
                                builder: (context, state) {
                                  String text = MusicPlayer.song!.title == null
                                      ? MusicPlayer.song!.displayName
                                      : MusicPlayer.song!.title;
                                  return AutoSizeText(
                                    text,
                                    overflowReplacement: Marquee(
                                      text: text,
                                      velocity: 10.0,
                                      style: TextStyle(fontSize: 18),
                                      scrollAxis: Axis.horizontal,
                                    ),
                                  );
                                },
                              ),
                            ),
                            Flexible(
                              child: BlocBuilder<CurrentSongCubit,
                                  CurrentSongState>(
                                builder: (context, state) {
                                  String text =
                                      MusicPlayer.song!.artist == "<unknown>"
                                          ? "unknown artist"
                                          : MusicPlayer.song!.artist;
                                  return AutoSizeText(
                                    text,
                                    overflowReplacement: Marquee(
                                      text: text,
                                      velocity: 10.0,
                                      style: TextStyle(fontSize: 18),
                                      scrollAxis: Axis.horizontal,
                                    ),
                                  );
                                },
                              ),
                            ),
                            Flexible(
                                child: BlocBuilder<SliderCubit, SliderState>(
                              builder: (context, state) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0),
                                  child: Slider(
                                    value: state.val,
                                    onChanged: (v) {
                                      player.seek(
                                          Duration(milliseconds: v.toInt()));
                                    },
                                    min: 0,
                                    max: MusicPlayer.max,
                                  ),
                                );
                              },
                            ))
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: BlocBuilder<MusicStateCubit, MusicState>(
                          builder: (context, state) {
                            if (state is MusicPlaying) {
                              return InkWell(
                                child: Icon(Icons.pause),
                                onTap: () {
                                  MusicPlayer.getPlayer().pause();
                                  BlocProvider.of<MusicStateCubit>(context)
                                      .emitMusicPausedState();
                                },
                              );
                            } else
                              return InkWell(
                                child: Icon(Icons.play_arrow),
                                onTap: () {
                                  MusicPlayer.getPlayer().play();
                                  BlocProvider.of<MusicStateCubit>(context)
                                      .emitMusicPlayingState();
                                },
                              );
                          },
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ));
  }
}
