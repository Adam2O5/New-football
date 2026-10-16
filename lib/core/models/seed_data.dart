import 'package:new_football/core/models/enums.dart';

export 'seed_clubs.dart';

part 'seed_name_pools_europe.dart';
part 'seed_name_pools_americas.dart';
part 'seed_name_pools_africa.dart';
part 'seed_name_pools_asia.dart';

const namePools = <Nationality, NamePool>{
  Nationality.poland: _polandNamePool,
  Nationality.brazil: _brazilNamePool,
  Nationality.france: _franceNamePool,
  Nationality.spain: _spainNamePool,
  Nationality.england: _englandNamePool,
  Nationality.germany: _germanyNamePool,
  Nationality.argentina: _argentinaNamePool,
  Nationality.portugal: _portugalNamePool,
  Nationality.italy: _italyNamePool,
  Nationality.netherlands: _netherlandsNamePool,
  Nationality.belgium: _belgiumNamePool,
  Nationality.croatia: _croatiaNamePool,
  Nationality.nigeria: _nigeriaNamePool,
  Nationality.senegal: _senegalNamePool,
  Nationality.japan: _japanNamePool,
  Nationality.usa: _usaNamePool,
  Nationality.mexico: _mexicoNamePool,
  Nationality.morocco: _moroccoNamePool,
  Nationality.colombia: _colombiaNamePool,
  Nationality.switzerland: _switzerlandNamePool,
  Nationality.uruguay: _uruguayNamePool,
  Nationality.egypt: _egyptNamePool,
  Nationality.china: _chinaNamePool,
};

class NamePool {
  const NamePool({required this.firstNames, required this.lastNames});

  final List<String> firstNames;
  final List<String> lastNames;
}
