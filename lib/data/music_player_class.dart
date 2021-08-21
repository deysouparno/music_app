// ignore: import_of_legacy_library_into_null_safe
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_audio_query/flutter_audio_query.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_app/data/collection.dart';

class MusicPlayer {
  static AudioPlayer? player;
  static SongInfo? song;
  static Uint8List? albumart;
  static double max = 1.0;
  static int index = 0;
  static List<SongInfo> playlist = Collection.allsongs;

  static AudioPlayer getPlayer() {
    if (player == null) {
      player = AudioPlayer();
    }
    return player!;
  }

  static void loadSong(SongInfo s) {
    if (player == null) {
      player = getPlayer();
    }
    if (player!.playing) {
      player!.stop();
    }
    // await player!.dispose();

    player!.setFilePath(s.filePath);
    max = double.parse(s.duration);
    MusicPlayer.song = s;
  }
}
