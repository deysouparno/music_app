import 'dart:async';

// ignore: import_of_legacy_library_into_null_safe
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_bloc/flutter_bloc.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:just_audio/just_audio.dart';
import 'package:marquee/marquee.dart';
import 'package:music_app/cubit/albumart_cubit.dart';
import 'package:music_app/cubit/music_state_cubit.dart';
import 'package:music_app/cubit/slider_cubit.dart';
import 'package:music_app/data/music_player_class.dart';

class CurrentSong extends StatefulWidget {
  final bool flag;
  const CurrentSong({
    Key? key,
    required this.flag,
    // required this.song,
  }) : super(key: key);

  @override
  _CurrentSongState createState() => _CurrentSongState();
}

AudioPlayer player = MusicPlayer.getPlayer();
Stream<Duration>? stream;
StreamSubscription? subscription;

class _CurrentSongState extends State<CurrentSong> {
  loadSong() async {
    if (widget.flag) {
      player.play();
      BlocProvider.of<MusicStateCubit>(context).emitMusicPlayingState();
    }
    adjust();
  }

  void adjust() {
    stream = player.createPositionStream();
    subscription = stream!.listen((event) {
      if (event.inMilliseconds.toDouble() >= MusicPlayer.max) {
        BlocProvider.of<MusicStateCubit>(context).emitMusicStoppedState();
      } else {
        BlocProvider.of<SliderCubit>(context)
            .update(event.inMilliseconds.toDouble());
      }
    });
  }

  // void changeMusic(SongInfo s) async {
  //   MusicPlayer.loadSong(s);

  //   setState(() {
  //     BlocProvider.of<MusicStateCubit>(context).emitMusicPlayingState();
  //   });
  // }

  @override
  void initState() {
    loadSong();
    super.initState();
  }

  void dispose() {
    super.dispose();
    subscription?.cancel();
  }

  void emitStoppedState() {
    BlocProvider.of<MusicStateCubit>(context).emitMusicPlayingState();
  }

  playSong() {
    player.play();
    BlocProvider.of<MusicStateCubit>(context).emitMusicPlayingState();
  }

  pauseSong() {
    player.pause();
    BlocProvider.of<MusicStateCubit>(context).emitMusicPausedState();
  }

  String getState(ConnectionState state) {
    switch (state) {
      case ConnectionState.done:
        return "done";
      case ConnectionState.none:
        return "none";

      case ConnectionState.waiting:
        return "waiting";

      default:
        return "active";
    }
  }

  String getDuration(double value) {
    Duration duration = Duration(milliseconds: value.round());

    return [duration.inMinutes, duration.inSeconds]
        .map((element) => element.remainder(60).toString().padLeft(2, '0'))
        .join(':');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Music App"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          children: [
            Flexible(
                flex: 3,
                child: Container(
                    padding: EdgeInsets.all(10.0),
                    constraints: BoxConstraints.expand(),
                    child: Hero(
                      tag: "image",
                      child: BlocBuilder<AlbumArtCubit, AlbumArtState>(
                          builder: (context, state) {
                        return state.albumArt == null
                            ? Image.asset("assets/music-note.png")
                            : Image.memory(state.albumArt!);
                      }),
                    ))),
            Flexible(
                flex: 1,
                child: Container(
                  height: 30,
                  // color: Colors.blueAccent,
                  padding: EdgeInsets.symmetric(horizontal: 10.0),

                  child: BlocBuilder<CurrentSongCubit, CurrentSongState>(
                    builder: (context, state) {
                      return AutoSizeText(
                        MusicPlayer.song!.title == null
                            ? MusicPlayer.song!.displayName
                            : MusicPlayer.song!.title,
                        overflowReplacement: Marquee(
                          text: MusicPlayer.song!.title == null
                              ? MusicPlayer.song!.displayName
                              : MusicPlayer.song!.title,
                          velocity: 10.0,
                          style: TextStyle(fontSize: 18),
                          scrollAxis: Axis.horizontal,
                          blankSpace: 10.0,
                          pauseAfterRound: Duration(seconds: 1),
                        ),
                        minFontSize: 12.0,
                      );
                    },
                  ),
                )),
            Flexible(
                flex: 1,
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                        fit: FlexFit.loose,
                        child: BlocBuilder<SliderCubit, SliderState>(
                          builder: (context, state) {
                            return Row(
                              children: [
                                Text("${getDuration(state.val)}"),
                                Expanded(
                                  child: Slider(
                                    value: state.val,
                                    onChanged: (v) {
                                      player.seek(
                                          Duration(milliseconds: v.toInt()));
                                    },
                                    min: 0,
                                    max: MusicPlayer.max,
                                  ),
                                ),
                                Text("${getDuration(MusicPlayer.max)}"),
                              ],
                            );
                          },
                        )),
                    Flexible(
                      fit: FlexFit.loose,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Flexible(
                              flex: 1,
                              child: InkWell(
                                child: Icon(
                                  Icons.skip_previous,
                                  size: 40,
                                ),
                                onTap: () {
                                  if (MusicPlayer.index > 0) {
                                    // player.stop();
                                    // BlocProvider.of<MusicStateCubit>(context)
                                    //     .emitMusicPausedState();
                                    MusicPlayer.index--;
                                    MusicPlayer.loadSong(MusicPlayer
                                        .playlist[MusicPlayer.index]);
                                    BlocProvider.of<AlbumArtCubit>(context)
                                        .emitAlbumArtChanged(MusicPlayer
                                            .playlist[MusicPlayer.index]);
                                    BlocProvider.of<CurrentSongCubit>(context)
                                        .emitSongChange();
                                    // setState(() {
                                    //   player.play();
                                    //   BlocProvider.of<MusicStateCubit>(context)
                                    //       .emitMusicPlayingState();
                                    // });
                                  }
                                },
                              )),
                          Flexible(
                            flex: 1,
                            child: InkWell(
                                child: Icon(
                                  Icons.replay_10,
                                  size: 40,
                                ),
                                onTap: () {
                                  var pos =
                                      BlocProvider.of<SliderCubit>(context)
                                          .state
                                          .val
                                          .toInt();
                                  if (pos > 10000) {
                                    pos = pos - 10000;
                                  } else {
                                    pos = 0;
                                  }
                                  player.seek(Duration(milliseconds: pos));
                                }),
                          ),
                          Flexible(
                              flex: 1,
                              child: BlocBuilder<MusicStateCubit, MusicState>(
                                builder: (context, state) {
                                  return state is MusicPlaying
                                      ? InkWell(
                                          child: Icon(
                                            Icons.pause_circle_filled_rounded,
                                            size: 60,
                                          ),
                                          onTap: () {
                                            pauseSong();
                                          },
                                        )
                                      : InkWell(
                                          child: Icon(
                                            Icons.play_circle_fill_rounded,
                                            size: 60,
                                          ),
                                          onTap: () {
                                            if (state is MusicStopped) {
                                              MusicPlayer.loadSong(
                                                  MusicPlayer.song!);
                                              player.play();
                                              BlocProvider.of<MusicStateCubit>(
                                                      context)
                                                  .emitMusicPlayingState();
                                            }
                                            if (state is MusicPaused) {
                                              playSong();
                                            }
                                          },
                                        );
                                },
                              )),
                          Flexible(
                              flex: 1,
                              child: InkWell(
                                child: Icon(
                                  Icons.forward_10,
                                  size: 40,
                                ),
                                onTap: () {
                                  var pos =
                                      BlocProvider.of<SliderCubit>(context)
                                          .state
                                          .val
                                          .toInt();
                                  if (pos + 10000 >= MusicPlayer.max) {
                                    pos = MusicPlayer.max.toInt();
                                  } else {
                                    pos = pos + 10000;
                                  }
                                  player.seek(Duration(milliseconds: pos));
                                },
                              )),
                          Flexible(
                              flex: 1,
                              child: InkWell(
                                child: Icon(
                                  Icons.skip_next,
                                  size: 40,
                                ),
                                onTap: () {
                                  if (MusicPlayer.index <
                                      MusicPlayer.playlist.length - 1) {
                                    MusicPlayer.index++;
                                    MusicPlayer.loadSong(MusicPlayer
                                        .playlist[MusicPlayer.index]);
                                    BlocProvider.of<AlbumArtCubit>(context)
                                        .emitAlbumArtChanged(MusicPlayer
                                            .playlist[MusicPlayer.index]);
                                    BlocProvider.of<CurrentSongCubit>(context)
                                        .emitSongChange();
                                  }
                                },
                              ))
                        ],
                      ),
                    ),
                  ],
                )),
          ],
        ),
      ),
    );
  }
}

IconData getIcons(String name) {
  IconData icon;
  switch (name) {
    case "pause":
      icon = Icons.pause_circle_filled_rounded;
      break;

    case "previous":
      icon = Icons.skip_previous;
      break;

    case "next":
      icon = Icons.skip_next;
      break;

    case "forward":
      icon = Icons.forward_10;
      break;

    case "replay":
      icon = Icons.replay_10;
      break;

    default:
      icon = Icons.play_circle_fill_rounded;
  }

  return icon;
}
