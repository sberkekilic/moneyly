import 'package:bloc/bloc.dart';
import 'package:dynamic_multi_step_form/dynamic_multi_step_form.dart';

class SelectedIndexCubit extends Cubit<int> {
  final PageController pageController;
  SelectedIndexCubit(this.pageController) : super(0);

  void updateIndex(int index){
    emit(index);
    pageController.jumpToPage(index);
  }
}