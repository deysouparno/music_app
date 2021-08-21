import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'music_state_state.dart';

class MusicStateCubit extends Cubit<MusicState> {
  MusicStateCubit() : super(MusicStopped());

  void emitMusicPlayingState() => emit(MusicPlaying());

  void emitMusicPausedState() => emit(MusicPaused());
  void emitMusicStoppedState() => emit(MusicStopped());
}

class CurrentSongCubit extends Cubit<CurrentSongState> {
  CurrentSongCubit() : super(CurrentSongState());
  void emitSongChange() => emit(CurrentSongState());
}
