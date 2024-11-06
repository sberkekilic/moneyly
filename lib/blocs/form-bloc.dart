import 'package:bloc/bloc.dart';
import 'package:moneyly/models/form-data.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class FormEvent {}

class AddTvTitle extends FormEvent {
  final String title;

  AddTvTitle(this.title);
}

class RemoveTVTitleValue extends FormEvent {
  final List<String> updatedList;

  RemoveTVTitleValue(this.updatedList);
}

class AddTVPrice extends FormEvent {
  final String price;

  AddTVPrice(this.price);
}

class RemoveTVPriceValue extends FormEvent {
  final List<String> updatedList;

  RemoveTVPriceValue(this.updatedList);
}

class CalculateTVSum extends FormEvent {
  final List<String> prices;

  CalculateTVSum(this.prices);
}

class AddGameTitle extends FormEvent {
  final String title;

  AddGameTitle(this.title);
}

class AddGamePrice extends FormEvent {
  final String price;

  AddGamePrice(this.price);
}

class CalculateGameSum extends FormEvent {
  final List<String> prices;

  CalculateGameSum(this.prices);
}

class AddMusicTitle extends FormEvent {
  final String title;

  AddMusicTitle(this.title);
}

class AddMusicPrice extends FormEvent {
  final String price;

  AddMusicPrice(this.price);
}

class CalculateMusicSum extends FormEvent {
  final List<String> prices;

  CalculateMusicSum(this.prices);
}

class AddInternetTitle extends FormEvent {
  final String title;

  AddInternetTitle(this.title);
}

class AddInternetPrice extends FormEvent {
  final String price;

  AddInternetPrice(this.price);
}

class CalculateInternetSum extends FormEvent {
  final List<String> prices;

  CalculateInternetSum(this.prices);
}

class AddRentTitle extends FormEvent {
  final String title;

  AddRentTitle(this.title);
}

class AddRentPrice extends FormEvent {
  final String price;

  AddRentPrice(this.price);
}

class CalculateRentSum extends FormEvent {
  final List<String> prices;

  CalculateRentSum(this.prices);
}

class FormStateCustom {
  final FormData formData;

  FormStateCustom({required this.formData});
}

class FormBloc extends Bloc<FormEvent, FormStateCustom> {
  FormBloc() : super(FormStateCustom(formData: FormData())) {

    on<AddTvTitle>((event, emit) async {
      final prefs = await SharedPreferences.getInstance();
      final updatedList = [...state.formData.tvTitleList, event.title];
      await prefs.setStringList('tvTitleList2', updatedList);
      emit(FormStateCustom(formData: state.formData..tvTitleList = updatedList));
    });

    on<RemoveTVTitleValue>((event, emit) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('tvTitleList2', event.updatedList);
      emit(FormStateCustom(formData: state.formData..tvTitleList = event.updatedList));
    });

    on<AddTVPrice>((event, emit) async {
      final prefs = await SharedPreferences.getInstance();
      final updatedList = [...state.formData.tvPriceList, event.price];
      await prefs.setStringList('tvPriceList2', updatedList);
      emit(FormStateCustom(formData: state.formData..tvPriceList = updatedList));
    });

    on<RemoveTVPriceValue>((event, emit) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('tvPriceList2', event.updatedList);
      emit(FormStateCustom(formData: state.formData..tvPriceList = event.updatedList));
    });

    on<CalculateTVSum>((event, emit) async {
      final prefs = await SharedPreferences.getInstance();
      double sum = 0.0;
      for (String price in event.prices) {
        sum += double.tryParse(price) ?? 0.0;
      }
      await prefs.setDouble('sumOfTV2', sum);
      emit(FormStateCustom(formData: state.formData..sumOfTV = sum));
    });

    on<AddGameTitle>((event, emit) async {
      final prefs = await SharedPreferences.getInstance();
      final updatedList = [...state.formData.gameTitleList, event.title];
      await prefs.setStringList('gameTitleList2', updatedList);
      emit(FormStateCustom(formData: state.formData..gameTitleList = updatedList));
    });

    on<AddGamePrice>((event, emit) async {
      final prefs = await SharedPreferences.getInstance();
      final updatedList = [...state.formData.gamePriceList, event.price];
      await prefs.setStringList('gamePriceList2', updatedList);
      emit(FormStateCustom(formData: state.formData..gamePriceList = updatedList));
    });

    on<CalculateGameSum>((event, emit) async {
      double sum = 0.0;
      for (String price in event.prices) {
        sum += double.tryParse(price) ?? 0.0;
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('sumOfGame2', sum);
      emit(FormStateCustom(formData: state.formData..sumOfGame = sum));
    });

    on<AddMusicTitle>((event, emit) async {
      final prefs = await SharedPreferences.getInstance();
      final updatedList = [...state.formData.musicTitleList, event.title];
      await prefs.setStringList('musicTitleList2', updatedList);
      emit(FormStateCustom(formData: state.formData..musicTitleList = updatedList));
    });

    on<AddMusicPrice>((event, emit) async {
      final prefs = await SharedPreferences.getInstance();
      final updatedList = [...state.formData.musicPriceList, event.price];
      await prefs.setStringList('musicPriceList2', updatedList);
      emit(FormStateCustom(formData: state.formData..musicPriceList = updatedList));
    });

    on<CalculateMusicSum>((event, emit) async {
      double sum = 0.0;
      for (String price in event.prices) {
        sum += double.tryParse(price) ?? 0.0;
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('sumOfMusic2', sum);
      emit(FormStateCustom(formData: state.formData..sumOfMusic = sum));
    });

    on<AddInternetTitle>((event, emit) async {
      final prefs = await SharedPreferences.getInstance();
      final updatedList = [...state.formData.internetTitleList, event.title];
      await prefs.setStringList('internetTitleList2', updatedList);
      emit(FormStateCustom(formData: state.formData..internetTitleList = updatedList));
    });

    on<AddInternetPrice>((event, emit) async {
      final prefs = await SharedPreferences.getInstance();
      final updatedList = [...state.formData.internetPriceList, event.price];
      await prefs.setStringList('internetPriceList2', updatedList);
      emit(FormStateCustom(formData: state.formData..internetPriceList = updatedList));
    });

    on<CalculateInternetSum>((event, emit) async {
      double sum = 0.0;
      for (String price in event.prices) {
        sum += double.tryParse(price) ?? 0.0;
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('sumOfInternet2', sum);
      emit(FormStateCustom(formData: state.formData..sumOfInternet = sum));
    });

    on<AddRentTitle>((event, emit) async {
      final prefs = await SharedPreferences.getInstance();
      final updatedList = [...state.formData.rentTitleList, event.title];
      await prefs.setStringList('rentTitleList2', updatedList);
      emit(FormStateCustom(formData: state.formData..rentTitleList = updatedList));
    });

    on<AddRentPrice>((event, emit) async {
      final prefs = await SharedPreferences.getInstance();
      final updatedList = [...state.formData.rentPriceList, event.price];
      await prefs.setStringList('rentPriceList2', updatedList);
      emit(FormStateCustom(formData: state.formData..rentPriceList = updatedList));
    });

    on<CalculateRentSum>((event, emit) async {
      double sum = 0.0;
      for (String price in event.prices) {
        sum += double.tryParse(price) ?? 0.0;
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('sumOfRent2', sum);
      emit(FormStateCustom(formData: state.formData..sumOfRent = sum));
    });
  }
}