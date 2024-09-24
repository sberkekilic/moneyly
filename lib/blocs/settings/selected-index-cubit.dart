import 'package:bloc/bloc.dart';

class SelectedIndexCubit extends Cubit<int> {
  SelectedIndexCubit() : super(0);

  void setIndex(int index) {
    emit(index);
  }
}
