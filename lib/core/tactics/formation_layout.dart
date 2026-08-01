import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/tactics/position_group.dart';

class AssignedSlot {
  const AssignedSlot({
    required this.key,
    required this.position,
    required this.group,
    required this.x,
    required this.y,
  });

  final String key;
  final Position position;
  final PositionGroup group;
  final double x;
  final double y;
}

AssignedSlot _slot(String key, Position position, double x, double y) {
  return AssignedSlot(
    key: key,
    position: position,
    group: positionGroupOf(position),
    x: x,
    y: y,
  );
}

class FormationLayout {
  const FormationLayout({required this.formation, required this.slots});

  final Formation formation;
  final List<AssignedSlot> slots;

  static FormationLayout of(Formation formation) {
    switch (formation) {
      case Formation.f343:
        return _f343;
      case Formation.f3421:
        return _f3421;
      case Formation.f352:
        return _f352;
      case Formation.f3511:
        return _f3511;
      case Formation.f41212Narrow:
        return _f41212Narrow;
      case Formation.f4132:
        return _f4132;
      case Formation.f4141:
        return _f4141;
      case Formation.f4231:
        return _f4231;
      case Formation.f4231Wide:
        return _f4231Wide;
      case Formation.f424:
        return _f424;
      case Formation.f4312:
        return _f4312;
      case Formation.f4321:
        return _f4321;
      case Formation.f433:
        return _f433;
      case Formation.f433Attack:
        return _f433Attack;
      case Formation.f433Defend:
        return _f433Defend;
      case Formation.f442:
        return _f442;
      case Formation.f442Defend:
        return _f442Defend;
      case Formation.f451:
        return _f451;
      case Formation.f5212:
        return _f5212;
      case Formation.f523:
        return _f523;
      case Formation.f532:
        return _f532;
    }
  }

  List<AssignedSlot> assignSlots() => slots;
}

final FormationLayout _f343 = FormationLayout(
  formation: Formation.f343,
  slots: [
    _slot('gk', Position.gk, 0.50, 0.08),
    _slot('lcb', Position.cb, 0.24, 0.22),
    _slot('cb', Position.cb, 0.50, 0.20),
    _slot('rcb', Position.cb, 0.76, 0.22),
    _slot('lw', Position.lw, 0.12, 0.56),
    _slot('rw', Position.rw, 0.88, 0.56),
    _slot('cm1', Position.cm, 0.38, 0.54),
    _slot('cm2', Position.cm, 0.62, 0.54),
    _slot('st1', Position.st, 0.22, 0.82),
    _slot('st', Position.st, 0.50, 0.86),
    _slot('st2', Position.st, 0.78, 0.82),
  ],
);

final FormationLayout _f3421 = FormationLayout(
  formation: Formation.f3421,
  slots: [
    _slot('gk', Position.gk, 0.50, 0.08),
    _slot('lcb', Position.cb, 0.24, 0.22),
    _slot('cb', Position.cb, 0.50, 0.20),
    _slot('rcb', Position.cb, 0.76, 0.22),
    _slot('lw', Position.lw, 0.12, 0.56),
    _slot('rw', Position.rw, 0.88, 0.56),
    _slot('cm1', Position.cm, 0.38, 0.52),
    _slot('cm2', Position.cm, 0.62, 0.52),
    _slot('cam1', Position.cam, 0.36, 0.72),
    _slot('cam2', Position.cam, 0.64, 0.72),
    _slot('st', Position.st, 0.50, 0.86),
  ],
);

final FormationLayout _f352 = FormationLayout(
  formation: Formation.f352,
  slots: [
    _slot('gk', Position.gk, 0.50, 0.08),
    _slot('lcb', Position.cb, 0.24, 0.22),
    _slot('cb', Position.cb, 0.50, 0.20),
    _slot('rcb', Position.cb, 0.76, 0.22),
    _slot('lw', Position.lw, 0.12, 0.56),
    _slot('rw', Position.rw, 0.88, 0.56),
    _slot('cm1', Position.cm, 0.32, 0.54),
    _slot('cm2', Position.cm, 0.68, 0.54),
    _slot('cam', Position.cam, 0.50, 0.68),
    _slot('st1', Position.st, 0.40, 0.84),
    _slot('st2', Position.st, 0.60, 0.84),
  ],
);

final FormationLayout _f3511 = FormationLayout(
  formation: Formation.f3511,
  slots: [
    _slot('gk', Position.gk, 0.50, 0.08),
    _slot('lcb', Position.cb, 0.24, 0.22),
    _slot('cb', Position.cb, 0.50, 0.20),
    _slot('rcb', Position.cb, 0.76, 0.22),
    _slot('lw', Position.lw, 0.12, 0.56),
    _slot('rw', Position.rw, 0.88, 0.56),
    _slot('cdm', Position.cdm, 0.50, 0.44),
    _slot('cm1', Position.cm, 0.34, 0.56),
    _slot('cm2', Position.cm, 0.66, 0.56),
    _slot('cam', Position.cam, 0.50, 0.70),
    _slot('st', Position.st, 0.50, 0.86),
  ],
);

final FormationLayout _f41212Narrow = FormationLayout(
  formation: Formation.f41212Narrow,
  slots: [
    _slot('gk', Position.gk, 0.50, 0.08),
    _slot('lb', Position.lb, 0.18, 0.24),
    _slot('lcb', Position.cb, 0.38, 0.22),
    _slot('rcb', Position.cb, 0.62, 0.22),
    _slot('rb', Position.rb, 0.82, 0.24),
    _slot('cdm', Position.cdm, 0.50, 0.42),
    _slot('cm1', Position.cm, 0.34, 0.56),
    _slot('cm2', Position.cm, 0.66, 0.56),
    _slot('cam', Position.cam, 0.50, 0.70),
    _slot('st1', Position.st, 0.40, 0.84),
    _slot('st2', Position.st, 0.60, 0.84),
  ],
);

final FormationLayout _f4132 = FormationLayout(
  formation: Formation.f4132,
  slots: [
    _slot('gk', Position.gk, 0.50, 0.08),
    _slot('lb', Position.lb, 0.18, 0.24),
    _slot('lcb', Position.cb, 0.38, 0.22),
    _slot('rcb', Position.cb, 0.62, 0.22),
    _slot('rb', Position.rb, 0.82, 0.24),
    _slot('cdm', Position.cdm, 0.50, 0.42),
    _slot('cm1', Position.cm, 0.28, 0.58),
    _slot('cm2', Position.cm, 0.50, 0.58),
    _slot('cm3', Position.cm, 0.72, 0.58),
    _slot('st1', Position.st, 0.40, 0.84),
    _slot('st2', Position.st, 0.60, 0.84),
  ],
);

final FormationLayout _f4141 = FormationLayout(
  formation: Formation.f4141,
  slots: [
    _slot('gk', Position.gk, 0.50, 0.08),
    _slot('lb', Position.lb, 0.18, 0.24),
    _slot('lcb', Position.cb, 0.38, 0.22),
    _slot('rcb', Position.cb, 0.62, 0.22),
    _slot('rb', Position.rb, 0.82, 0.24),
    _slot('cdm', Position.cdm, 0.50, 0.42),
    _slot('lw', Position.lw, 0.16, 0.58),
    _slot('cm1', Position.cm, 0.40, 0.58),
    _slot('cm2', Position.cm, 0.60, 0.58),
    _slot('rw', Position.rw, 0.84, 0.58),
    _slot('st', Position.st, 0.50, 0.84),
  ],
);

final FormationLayout _f4231 = FormationLayout(
  formation: Formation.f4231,
  slots: [
    _slot('gk', Position.gk, 0.50, 0.08),
    _slot('lb', Position.lb, 0.18, 0.24),
    _slot('lcb', Position.cb, 0.38, 0.22),
    _slot('rcb', Position.cb, 0.62, 0.22),
    _slot('rb', Position.rb, 0.82, 0.24),
    _slot('cdm1', Position.cdm, 0.40, 0.44),
    _slot('cdm2', Position.cdm, 0.60, 0.44),
    _slot('cam1', Position.cam, 0.26, 0.66),
    _slot('cam', Position.cam, 0.50, 0.70),
    _slot('cam2', Position.cam, 0.74, 0.66),
    _slot('st', Position.st, 0.50, 0.84),
  ],
);

final FormationLayout _f4231Wide = FormationLayout(
  formation: Formation.f4231Wide,
  slots: [
    _slot('gk', Position.gk, 0.50, 0.08),
    _slot('lb', Position.lb, 0.18, 0.24),
    _slot('lcb', Position.cb, 0.38, 0.22),
    _slot('rcb', Position.cb, 0.62, 0.22),
    _slot('rb', Position.rb, 0.82, 0.24),
    _slot('cdm1', Position.cdm, 0.40, 0.44),
    _slot('cdm2', Position.cdm, 0.60, 0.44),
    _slot('lw', Position.lw, 0.16, 0.64),
    _slot('cam', Position.cam, 0.50, 0.70),
    _slot('rw', Position.rw, 0.84, 0.64),
    _slot('st', Position.st, 0.50, 0.84),
  ],
);

final FormationLayout _f424 = FormationLayout(
  formation: Formation.f424,
  slots: [
    _slot('gk', Position.gk, 0.50, 0.08),
    _slot('lb', Position.lb, 0.18, 0.24),
    _slot('lcb', Position.cb, 0.38, 0.22),
    _slot('rcb', Position.cb, 0.62, 0.22),
    _slot('rb', Position.rb, 0.82, 0.24),
    _slot('cm1', Position.cm, 0.40, 0.52),
    _slot('cm2', Position.cm, 0.60, 0.52),
    _slot('lw', Position.lw, 0.16, 0.80),
    _slot('rw', Position.rw, 0.84, 0.80),
    _slot('st1', Position.st, 0.40, 0.84),
    _slot('st2', Position.st, 0.60, 0.84),
  ],
);

final FormationLayout _f4312 = FormationLayout(
  formation: Formation.f4312,
  slots: [
    _slot('gk', Position.gk, 0.50, 0.08),
    _slot('lb', Position.lb, 0.18, 0.24),
    _slot('lcb', Position.cb, 0.38, 0.22),
    _slot('rcb', Position.cb, 0.62, 0.22),
    _slot('rb', Position.rb, 0.82, 0.24),
    _slot('cm1', Position.cm, 0.28, 0.54),
    _slot('cm2', Position.cm, 0.50, 0.50),
    _slot('cm3', Position.cm, 0.72, 0.54),
    _slot('cam', Position.cam, 0.50, 0.68),
    _slot('st1', Position.st, 0.40, 0.84),
    _slot('st2', Position.st, 0.60, 0.84),
  ],
);

final FormationLayout _f4321 = FormationLayout(
  formation: Formation.f4321,
  slots: [
    _slot('gk', Position.gk, 0.50, 0.08),
    _slot('lb', Position.lb, 0.18, 0.24),
    _slot('lcb', Position.cb, 0.38, 0.22),
    _slot('rcb', Position.cb, 0.62, 0.22),
    _slot('rb', Position.rb, 0.82, 0.24),
    _slot('cm1', Position.cm, 0.28, 0.52),
    _slot('cm2', Position.cm, 0.50, 0.50),
    _slot('cm3', Position.cm, 0.72, 0.52),
    _slot('cam1', Position.cam, 0.36, 0.72),
    _slot('cam2', Position.cam, 0.64, 0.72),
    _slot('st', Position.st, 0.50, 0.86),
  ],
);

final FormationLayout _f433 = FormationLayout(
  formation: Formation.f433,
  slots: [
    _slot('gk', Position.gk, 0.50, 0.08),
    _slot('lb', Position.lb, 0.18, 0.24),
    _slot('lcb', Position.cb, 0.38, 0.22),
    _slot('rcb', Position.cb, 0.62, 0.22),
    _slot('rb', Position.rb, 0.82, 0.24),
    _slot('cm1', Position.cm, 0.28, 0.54),
    _slot('cm2', Position.cm, 0.50, 0.50),
    _slot('cm3', Position.cm, 0.72, 0.54),
    _slot('lw', Position.lw, 0.20, 0.78),
    _slot('st', Position.st, 0.50, 0.84),
    _slot('rw', Position.rw, 0.80, 0.78),
  ],
);

final FormationLayout _f433Attack = FormationLayout(
  formation: Formation.f433Attack,
  slots: [
    _slot('gk', Position.gk, 0.50, 0.08),
    _slot('lb', Position.lb, 0.18, 0.24),
    _slot('lcb', Position.cb, 0.38, 0.22),
    _slot('rcb', Position.cb, 0.62, 0.22),
    _slot('rb', Position.rb, 0.82, 0.24),
    _slot('cm1', Position.cm, 0.32, 0.52),
    _slot('cm2', Position.cm, 0.68, 0.52),
    _slot('cam', Position.cam, 0.50, 0.66),
    _slot('lw', Position.lw, 0.20, 0.78),
    _slot('st', Position.st, 0.50, 0.84),
    _slot('rw', Position.rw, 0.80, 0.78),
  ],
);

final FormationLayout _f433Defend = FormationLayout(
  formation: Formation.f433Defend,
  slots: [
    _slot('gk', Position.gk, 0.50, 0.08),
    _slot('lb', Position.lb, 0.18, 0.24),
    _slot('lcb', Position.cb, 0.38, 0.22),
    _slot('rcb', Position.cb, 0.62, 0.22),
    _slot('rb', Position.rb, 0.82, 0.24),
    _slot('cdm1', Position.cdm, 0.40, 0.44),
    _slot('cdm2', Position.cdm, 0.60, 0.44),
    _slot('cm', Position.cm, 0.50, 0.60),
    _slot('lw', Position.lw, 0.20, 0.78),
    _slot('st', Position.st, 0.50, 0.84),
    _slot('rw', Position.rw, 0.80, 0.78),
  ],
);

final FormationLayout _f442 = FormationLayout(
  formation: Formation.f442,
  slots: [
    _slot('gk', Position.gk, 0.50, 0.08),
    _slot('lb', Position.lb, 0.18, 0.24),
    _slot('lcb', Position.cb, 0.38, 0.22),
    _slot('rcb', Position.cb, 0.62, 0.22),
    _slot('rb', Position.rb, 0.82, 0.24),
    _slot('lw', Position.lw, 0.16, 0.56),
    _slot('cm1', Position.cm, 0.40, 0.56),
    _slot('cm2', Position.cm, 0.60, 0.56),
    _slot('rw', Position.rw, 0.84, 0.56),
    _slot('st1', Position.st, 0.40, 0.84),
    _slot('st2', Position.st, 0.60, 0.84),
  ],
);

final FormationLayout _f442Defend = FormationLayout(
  formation: Formation.f442Defend,
  slots: [
    _slot('gk', Position.gk, 0.50, 0.08),
    _slot('lb', Position.lb, 0.18, 0.24),
    _slot('lcb', Position.cb, 0.38, 0.22),
    _slot('rcb', Position.cb, 0.62, 0.22),
    _slot('rb', Position.rb, 0.82, 0.24),
    _slot('lw', Position.lw, 0.16, 0.56),
    _slot('cdm1', Position.cdm, 0.40, 0.46),
    _slot('cdm2', Position.cdm, 0.60, 0.46),
    _slot('rw', Position.rw, 0.84, 0.56),
    _slot('st1', Position.st, 0.40, 0.84),
    _slot('st2', Position.st, 0.60, 0.84),
  ],
);

final FormationLayout _f451 = FormationLayout(
  formation: Formation.f451,
  slots: [
    _slot('gk', Position.gk, 0.50, 0.08),
    _slot('lb', Position.lb, 0.18, 0.24),
    _slot('lcb', Position.cb, 0.38, 0.22),
    _slot('rcb', Position.cb, 0.62, 0.22),
    _slot('rb', Position.rb, 0.82, 0.24),
    _slot('lw', Position.lw, 0.16, 0.58),
    _slot('cm1', Position.cm, 0.32, 0.54),
    _slot('cm2', Position.cm, 0.50, 0.50),
    _slot('cm3', Position.cm, 0.68, 0.54),
    _slot('rw', Position.rw, 0.84, 0.58),
    _slot('st', Position.st, 0.50, 0.84),
  ],
);

final FormationLayout _f5212 = FormationLayout(
  formation: Formation.f5212,
  slots: [
    _slot('gk', Position.gk, 0.50, 0.08),
    _slot('lwb', Position.lwb, 0.10, 0.26),
    _slot('lcb', Position.cb, 0.28, 0.20),
    _slot('cb', Position.cb, 0.50, 0.18),
    _slot('rcb', Position.cb, 0.72, 0.20),
    _slot('rwb', Position.rwb, 0.90, 0.26),
    _slot('cm1', Position.cm, 0.38, 0.54),
    _slot('cm2', Position.cm, 0.62, 0.54),
    _slot('cam', Position.cam, 0.50, 0.68),
    _slot('st1', Position.st, 0.40, 0.84),
    _slot('st2', Position.st, 0.60, 0.84),
  ],
);

final FormationLayout _f523 = FormationLayout(
  formation: Formation.f523,
  slots: [
    _slot('gk', Position.gk, 0.50, 0.08),
    _slot('lwb', Position.lwb, 0.10, 0.26),
    _slot('lcb', Position.cb, 0.28, 0.20),
    _slot('cb', Position.cb, 0.50, 0.18),
    _slot('rcb', Position.cb, 0.72, 0.20),
    _slot('rwb', Position.rwb, 0.90, 0.26),
    _slot('cm1', Position.cm, 0.40, 0.52),
    _slot('cm2', Position.cm, 0.60, 0.52),
    _slot('lw', Position.lw, 0.18, 0.80),
    _slot('st', Position.st, 0.50, 0.84),
    _slot('rw', Position.rw, 0.82, 0.80),
  ],
);

final FormationLayout _f532 = FormationLayout(
  formation: Formation.f532,
  slots: [
    _slot('gk', Position.gk, 0.50, 0.08),
    _slot('lwb', Position.lwb, 0.10, 0.26),
    _slot('lcb', Position.cb, 0.28, 0.20),
    _slot('cb', Position.cb, 0.50, 0.18),
    _slot('rcb', Position.cb, 0.72, 0.20),
    _slot('rwb', Position.rwb, 0.90, 0.26),
    _slot('cdm', Position.cdm, 0.50, 0.42),
    _slot('cm1', Position.cm, 0.34, 0.56),
    _slot('cm2', Position.cm, 0.66, 0.56),
    _slot('st1', Position.st, 0.40, 0.84),
    _slot('st2', Position.st, 0.60, 0.84),
  ],
);
