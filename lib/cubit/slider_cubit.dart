import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'slider_state.dart';

class SliderCubit extends Cubit<SliderState> {
  SliderCubit() : super(SliderState(val: 0));

  void update(double value) => emit(SliderState(val: value));
}
