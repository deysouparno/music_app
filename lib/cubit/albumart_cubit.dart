import 'dart:io';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:meta/meta.dart';

part 'albumart_state.dart';

class AlbumArtCubit extends Cubit<AlbumArtState> {
  AlbumArtCubit() : super(AlbumArtState(albumArt: null));

  void emitAlbumArtChanged(SongInfo s) async {
    MetadataRetriever r = MetadataRetriever();
    await r.setFile(File(s.filePath));
    emit(AlbumArtState(albumArt: r.albumArt));
  }
}
