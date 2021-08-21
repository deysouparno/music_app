part of 'music_state_cubit.dart';

@immutable
abstract class MusicState {}

class MusicPlaying extends MusicState {}

class MusicPaused extends MusicState {}

class MusicStopped extends MusicState {}

class MusicChangedState extends MusicState {}

class CurrentSongState {}
