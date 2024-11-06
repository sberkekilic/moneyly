class FormData {
  bool hasTVSelected = false;
  bool hasGameSelected = false;
  bool hasMusicSelected = false;
  bool hasHomeSelected = false;
  bool hasInternetSelected = false;
  bool hasPhoneSelected = false;
  bool hasRentSelected = false;
  bool hasKitchenSelected = false;
  bool hasCateringSelected = false;
  bool hasEntertainmentSelected = false;
  bool hasOtherSelected = false;

  List<String> tvTitleList = [];
  List<String> gameTitleList = [];
  List<String> musicTitleList = [];
  List<String> homeBillsTitleList = [];
  List<String> internetTitleList = [];
  List<String> phoneTitleList = [];
  List<String> rentTitleList = [];
  List<String> kitchenTitleList = [];
  List<String> cateringTitleList = [];
  List<String> entertainmentTitleList = [];
  List<String> otherTitleList = [];

  List<String> tvPriceList = [];
  List<String> gamePriceList = [];
  List<String> musicPriceList = [];
  List<String> homeBillsPriceList = [];
  List<String> internetPriceList = [];
  List<String> phonePriceList = [];
  List<String> rentPriceList = [];
  List<String> kitchenPriceList = [];
  List<String> cateringPriceList = [];
  List<String> entertainmentPriceList = [];
  List<String> otherPriceList = [];

  double sumOfTV = 0.0;
  double sumOfGame = 0.0;
  double sumOfMusic = 0.0;
  double sumOfHomeBills = 0.0;
  double sumOfInternet = 0.0;
  double sumOfPhone = 0.0;
  double sumOfRent = 0.0;
  double sumOfKitchen = 0.0;
  double sumOfCatering = 0.0;
  double sumOfEnt = 0.0;
  double sumOfOther = 0.0;
}