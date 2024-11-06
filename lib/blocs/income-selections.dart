import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SelectedOption { None, Is, Burs, Emekli }

// Events
abstract class IncomeSelectionsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadSelectedOption extends IncomeSelectionsEvent {
  final SelectedOption option;

  LoadSelectedOption(this.option);

  @override
  List<Object?> get props => [option];
}

class SetOptionAndValue extends IncomeSelectionsEvent {
  final SelectedOption option;
  final String value;

  SetOptionAndValue(this.option, this.value);

  @override
  List<Object?> get props => [option, value];
}

// States
abstract class IncomeSelectionsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class IncomeSelectionsInitial extends IncomeSelectionsState {}

class IncomeSelectionsLoaded extends IncomeSelectionsState {
  final SelectedOption selectedOption;
  final String incomeValue;
  final String selectedTitle;

  IncomeSelectionsLoaded(this.selectedOption, this.incomeValue, this.selectedTitle);

  @override
  List<Object?> get props => [selectedOption, incomeValue, selectedTitle];
}


// Bloc
class IncomeSelectionsBloc extends Bloc<IncomeSelectionsEvent, IncomeSelectionsState> {
  IncomeSelectionsBloc() : super(IncomeSelectionsInitial()) {
    on<SetOptionAndValue>(_onSetOptionAndValue);
    on<LoadSelectedOption>(_onLoadSelectedOption);
  }

  Future<void> _onSetOptionAndValue(SetOptionAndValue event, Emitter<IncomeSelectionsState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selected_option', event.option.index);
    await prefs.setString('income_value', event.value);

    // Set selectedTitle based on selectedOption
    String selectedTitle;
    switch (event.option) {
      case SelectedOption.Is:
        selectedTitle = 'İş gelirinizi yazın';
        break;
      case SelectedOption.Burs:
        selectedTitle = 'Burs gelirinizi yazın';
        break;
      case SelectedOption.Emekli:
        selectedTitle = 'Emekli gelirinizi yazın';
        break;
      default:
        selectedTitle = '';
        break;
    }

    print("Combined event: selectedOption:${event.option}, incomeValue:${event.value}");
    emit(IncomeSelectionsLoaded(event.option, event.value, selectedTitle));
  }


  Future<void> _onLoadSelectedOption(LoadSelectedOption event, Emitter<IncomeSelectionsState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    final incomeValue = prefs.getString('income_value') ?? '';

    // Set selectedTitle based on the loaded option
    String selectedTitle;
    switch (event.option) {
      case SelectedOption.Is:
        selectedTitle = 'İş gelirinizi yazın';
        break;
      case SelectedOption.Burs:
        selectedTitle = 'Burs gelirinizi yazın';
        break;
      case SelectedOption.Emekli:
        selectedTitle = 'Emekli gelirinizi yazın';
        break;
      default:
        selectedTitle = '';
        break;
    }

    emit(IncomeSelectionsLoaded(event.option, incomeValue, selectedTitle));
  }

}
