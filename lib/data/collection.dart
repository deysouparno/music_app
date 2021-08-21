// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_audio_query/flutter_audio_query.dart';

class Collection {
  static List<SongInfo> allsongs = [];
  static List<SongFolder> folders = [];

  static Future<void> getSongs() async {
    allsongs = await FlutterAudioQuery().getSongs();

    Map<String, List<SongInfo>> map = {};

    allsongs.forEach((element) {
      String folderName = element.filePath.split("/")[4];
      if (map.containsKey(folderName)) {
        map[folderName]!.add(element);
      } else {
        map[folderName] = [element];
      }
    });

    folders = map.keys.map((e) => SongFolder(name: e, songs: map[e]!)).toList();
  }
}

class SongFolder {
  String name;
  List<SongInfo> songs;
  SongFolder({required this.name, required this.songs});
}
