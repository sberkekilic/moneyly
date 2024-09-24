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

class SetSelectedOption extends IncomeSelectionsEvent {
  final SelectedOption option;

  SetSelectedOption(this.option);

  @override
  List<Object?> get props => [option];
}

class SetIncomeValue extends IncomeSelectionsEvent {
  final String value;

  SetIncomeValue(this.value);

  @override
  List<Object?> get props => [value];
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

  IncomeSelectionsLoaded(this.selectedOption, this.incomeValue);

  @override
  List<Object?> get props => [selectedOption, incomeValue];
}

// Bloc
class IncomeSelectionsBloc extends Bloc<IncomeSelectionsEvent, IncomeSelectionsState> {
  IncomeSelectionsBloc() : super(IncomeSelectionsInitial()) {
    on<SetSelectedOption>(_onSetSelectedOption);
    on<SetIncomeValue>(_onSetIncomeValue);
    on<LoadSelectedOption>(_onLoadSelectedOption);
  }

  Future<void> _onSetSelectedOption(SetSelectedOption event, Emitter<IncomeSelectionsState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selected_option', event.option.index); // Store the selected option as an index
    final incomeValue = prefs.getString('income_value') ?? '';
    print("ÇALIŞTIM - ONSETSELECTEDOPTION ve incomeValue:${incomeValue} ve index:${event.option.index}");
    emit(IncomeSelectionsLoaded(event.option, incomeValue)); // Emit the new state
  }

  Future<void> _onSetIncomeValue(SetIncomeValue event, Emitter<IncomeSelectionsState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('income_value', event.value);
    final index = prefs.getInt('selected_option') ?? SelectedOption.None.index; // Retrieve the selected option index
    final selectedOption = SelectedOption.values[index]; // Get the enum value from the index
    print("ÇALIŞTIM - ONSETINCOMEVALUE ve selectedOption:${selectedOption}");
    emit(IncomeSelectionsLoaded(selectedOption, event.value)); // Emit the new state
  }

  Future<void> _onLoadSelectedOption(LoadSelectedOption event, Emitter<IncomeSelectionsState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    final incomeValue = prefs.getString('income_value') ?? '';
    emit(IncomeSelectionsLoaded(event.option, incomeValue));
  }
}

