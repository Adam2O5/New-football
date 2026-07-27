import 'package:new_football/core/models/enums.dart';

/// Grupowanie pozycji do sortu "Pozycja" na liście zawodników (squad_lineup_tab).
/// Nie rozróżnia strony boiska (L/R) — tylko typ roli.
enum PositionGroup {
  gk,
  centreBack,
  fullBack,
  wingBack,
  midfield,
  winger,
  striker,
}

extension PositionGroupX on PositionGroup {
  /// Kolejność linii dla sortu "Pozycja": GK -> CB -> FB/WB -> MID -> Winger -> ST.
  int get sortOrder {
    switch (this) {
      case PositionGroup.gk:
        return 0;
      case PositionGroup.centreBack:
        return 1;
      case PositionGroup.fullBack:
      case PositionGroup.wingBack:
        return 2;
      case PositionGroup.midfield:
        return 3;
      case PositionGroup.winger:
        return 4;
      case PositionGroup.striker:
        return 5;
    }
  }
}

PositionGroup positionGroupOf(Position position) {
  switch (position) {
    case Position.gk:
      return PositionGroup.gk;
    case Position.cb:
      return PositionGroup.centreBack;
    case Position.lb:
    case Position.rb:
      return PositionGroup.fullBack;
    case Position.lwb:
    case Position.rwb:
      return PositionGroup.wingBack;
    case Position.cdm:
    case Position.cm:
    case Position.cam:
      return PositionGroup.midfield;
    case Position.lw:
    case Position.rw:
      return PositionGroup.winger;
    case Position.st:
      return PositionGroup.striker;
  }
}

/// Grupowanie po stronie boiska, używane wyłącznie do sugerowania zmienników
/// (SubstituteSheet). Rozłączne z [PositionGroup] — tu LB łączy się z LWB
/// (ta sama strona, inna głębokość), nie z RB. Środek (CDM/CM/CAM) i skrzydła
/// (LW/RW) są rozdzielone stronami tam, gdzie to ma sens; CB i ST nie mają
/// podziału na strony.
enum SubstituteGroup {
  gk,
  centreBack,
  leftSide, // LB, LWB
  rightSide, // RB, RWB
  centralMidfield, // CDM, CM, CAM
  leftWinger, // LW
  rightWinger, // RW
  striker,
}

SubstituteGroup substituteGroupOf(Position position) {
  switch (position) {
    case Position.gk:
      return SubstituteGroup.gk;
    case Position.cb:
      return SubstituteGroup.centreBack;
    case Position.lb:
    case Position.lwb:
      return SubstituteGroup.leftSide;
    case Position.rb:
    case Position.rwb:
      return SubstituteGroup.rightSide;
    case Position.cdm:
    case Position.cm:
    case Position.cam:
      return SubstituteGroup.centralMidfield;
    case Position.lw:
      return SubstituteGroup.leftWinger;
    case Position.rw:
      return SubstituteGroup.rightWinger;
    case Position.st:
      return SubstituteGroup.striker;
  }
}
