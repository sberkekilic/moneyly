import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

/// Events for the PageView navigation
abstract class PageEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class ChangePage extends PageEvent {
  final int index;

  ChangePage(this.index);

  @override
  List<Object> get props => [index];
}

/// States for the PageView navigation
abstract class PageState extends Equatable {
  @override
  List<Object> get props => [];
}

class PageInitial extends PageState {}

class PageIndexChanged extends PageState {
  final int pageIndex;

  PageIndexChanged(this.pageIndex);

  @override
  List<Object> get props => [pageIndex];
}

/// BLoC for managing PageView navigation
class PageBloc extends Bloc<PageEvent, PageState> {
  PageBloc() : super(PageInitial()) {
    on<ChangePage>((event, emit) {
      emit(PageIndexChanged(event.index));  // Use 'event.index' instead of 'event.pageIndex'
    });
  }
}
