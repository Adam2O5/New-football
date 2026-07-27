import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/tactics/position_group.dart';
import 'package:new_football/core/tactics/tactics_setup.dart';

class FormationAnchor {
  const FormationAnchor({
    required this.key,
    required this.group,
    required this.x,
    required this.y,
  });

  final String key;
  final PositionGroup group;
  final double x;
  final double y;
}

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

class FormationLayout {
  const FormationLayout({
    required this.formation,
    required this.midfieldPoolSize,
    required this.anchors,
  });

  final Formation formation;
  final int midfieldPoolSize;
  final List<FormationAnchor> anchors;

  static FormationLayout of(Formation formation) {
    switch (formation) {
      case Formation.f343:
        return _f343;
      case Formation.f352:
        return _f352;
      case Formation.f424:
        return _f424;
      case Formation.f433:
        return _f433;
      case Formation.f442Wide:
        return _f442Wide;
      case Formation.f442Narrow:
        return _f442Narrow;
      case Formation.f451Wide:
        return _f451Wide;
      case Formation.f451Narrow:
        return _f451Narrow;
      case Formation.f523:
        return _f523;
      case Formation.f532:
        return _f532;
      case Formation.f541Wide:
        return _f541Wide;
      case Formation.f541Narrow:
        return _f541Narrow;
    }
  }

  List<AssignedSlot> assignSlots(MidfieldSlots? midfieldSlots) {
    final slots = <AssignedSlot>[
      for (final anchor in anchors)
        AssignedSlot(
          key: anchor.key,
          position: _fixedPositionFor(anchor.key),
          group: anchor.group,
          x: anchor.x,
          y: anchor.y,
        ),
    ];

    final resolvedMidfieldSlots = _normalizeMidfieldSlots(midfieldSlots);
    slots.addAll(_buildMidfieldSlots(resolvedMidfieldSlots));
    return slots;
  }

  MidfieldSlots _normalizeMidfieldSlots(MidfieldSlots? midfieldSlots) {
    if (midfieldPoolSize == 0) {
      return const MidfieldSlots(cdm: 0, cm: 0, cam: 0);
    }

    final fallback = _defaultMidfieldSlots(midfieldPoolSize);
    final source = midfieldSlots ?? fallback;
    final total = source.cdm + source.cm + source.cam;
    if (total == midfieldPoolSize) {
      return source;
    }
    return fallback;
  }

  List<AssignedSlot> _buildMidfieldSlots(MidfieldSlots midfieldSlots) {
    if (midfieldPoolSize == 0) {
      return const [];
    }

    final specs = <_MidfieldSpec>[
      for (var i = 0; i < midfieldSlots.cdm; i++) const _MidfieldSpec(Position.cdm, 0.00, 0.44),
      for (var i = 0; i < midfieldSlots.cm; i++) const _MidfieldSpec(Position.cm, 0.00, 0.54),
      for (var i = 0; i < midfieldSlots.cam; i++) const _MidfieldSpec(Position.cam, 0.00, 0.64),
    ];

    final lanes = _xLanesFor(midfieldPoolSize);
    final countsByRow = <double, int>{};
    final rowIndexBySpec = <int>[];

    for (final spec in specs) {
      final count = countsByRow.update(spec.y, (value) => value + 1, ifAbsent: () => 1);
      rowIndexBySpec.add(count - 1);
    }

    final slots = <AssignedSlot>[];
    for (var i = 0; i < specs.length; i++) {
      final spec = specs[i];
      final rowCount = countsByRow[spec.y]!;
      final rowLanes = _xLanesFor(rowCount);
      final x = rowLanes[rowIndexBySpec[i]];
      slots.add(
        AssignedSlot(
          key: 'mid_$i',
          position: spec.position,
          group: positionGroupOf(spec.position),
          x: rowCount == midfieldPoolSize ? lanes[i] : x,
          y: spec.y,
        ),
      );
    }

    return slots;
  }
}

class _MidfieldSpec {
  const _MidfieldSpec(this.position, this.x, this.y);

  final Position position;
  final double x;
  final double y;
}

MidfieldSlots _defaultMidfieldSlots(int midfieldPoolSize) {
  switch (midfieldPoolSize) {
    case 2:
      return const MidfieldSlots(cdm: 1, cm: 1, cam: 0);
    case 3:
      return const MidfieldSlots(cdm: 1, cm: 1, cam: 1);
    case 4:
      return const MidfieldSlots(cdm: 1, cm: 2, cam: 1);
    case 5:
      return const MidfieldSlots(cdm: 1, cm: 3, cam: 1);
    default:
      throw ArgumentError.value(midfieldPoolSize, 'midfieldPoolSize');
  }
}

List<double> _xLanesFor(int count) {
  switch (count) {
    case 1:
      return const [0.50];
    case 2:
      return const [0.36, 0.64];
    case 3:
      return const [0.28, 0.50, 0.72];
    case 4:
      return const [0.20, 0.40, 0.60, 0.80];
    case 5:
      return const [0.14, 0.32, 0.50, 0.68, 0.86];
    default:
      throw ArgumentError.value(count, 'count');
  }
}

Position _fixedPositionFor(String key) {
  switch (key) {
    case 'gk':
      return Position.gk;
    case 'lb':
      return Position.lb;
    case 'lcb':
    case 'cb':
    case 'cb1':
    case 'cb2':
    case 'cb3':
    case 'rcb':
      return Position.cb;
    case 'rb':
      return Position.rb;
    case 'lwb':
      return Position.lwb;
    case 'rwb':
      return Position.rwb;
    case 'lw':
      return Position.lw;
    case 'rw':
      return Position.rw;
    case 'st':
    case 'st1':
    case 'st2':
      return Position.st;
    default:
      throw ArgumentError.value(key, 'key');
  }
}

const FormationLayout _f343 = FormationLayout(
  formation: Formation.f343,
  midfieldPoolSize: 2,
  anchors: [
    FormationAnchor(key: 'gk', group: PositionGroup.gk, x: 0.50, y: 0.08),
    FormationAnchor(key: 'cb1', group: PositionGroup.centreBack, x: 0.24, y: 0.22),
    FormationAnchor(key: 'cb2', group: PositionGroup.centreBack, x: 0.50, y: 0.20),
    FormationAnchor(key: 'cb3', group: PositionGroup.centreBack, x: 0.76, y: 0.22),
    FormationAnchor(key: 'lwb', group: PositionGroup.wingBack, x: 0.10, y: 0.52),
    FormationAnchor(key: 'rwb', group: PositionGroup.wingBack, x: 0.90, y: 0.52),
    FormationAnchor(key: 'lw', group: PositionGroup.winger, x: 0.18, y: 0.80),
    FormationAnchor(key: 'st', group: PositionGroup.striker, x: 0.50, y: 0.84),
    FormationAnchor(key: 'rw', group: PositionGroup.winger, x: 0.82, y: 0.80),
  ],
);

const FormationLayout _f352 = FormationLayout(
  formation: Formation.f352,
  midfieldPoolSize: 3,
  anchors: [
    FormationAnchor(key: 'gk', group: PositionGroup.gk, x: 0.50, y: 0.08),
    FormationAnchor(key: 'cb1', group: PositionGroup.centreBack, x: 0.24, y: 0.22),
    FormationAnchor(key: 'cb2', group: PositionGroup.centreBack, x: 0.50, y: 0.20),
    FormationAnchor(key: 'cb3', group: PositionGroup.centreBack, x: 0.76, y: 0.22),
    FormationAnchor(key: 'lwb', group: PositionGroup.wingBack, x: 0.10, y: 0.52),
    FormationAnchor(key: 'rwb', group: PositionGroup.wingBack, x: 0.90, y: 0.52),
    FormationAnchor(key: 'st1', group: PositionGroup.striker, x: 0.40, y: 0.84),
    FormationAnchor(key: 'st2', group: PositionGroup.striker, x: 0.60, y: 0.84),
  ],
);

const FormationLayout _f424 = FormationLayout(
  formation: Formation.f424,
  midfieldPoolSize: 2,
  anchors: [
    FormationAnchor(key: 'gk', group: PositionGroup.gk, x: 0.50, y: 0.08),
    FormationAnchor(key: 'lb', group: PositionGroup.fullBack, x: 0.18, y: 0.24),
    FormationAnchor(key: 'lcb', group: PositionGroup.centreBack, x: 0.38, y: 0.22),
    FormationAnchor(key: 'rcb', group: PositionGroup.centreBack, x: 0.62, y: 0.22),
    FormationAnchor(key: 'rb', group: PositionGroup.fullBack, x: 0.82, y: 0.24),
    FormationAnchor(key: 'lw', group: PositionGroup.winger, x: 0.16, y: 0.80),
    FormationAnchor(key: 'st1', group: PositionGroup.striker, x: 0.40, y: 0.84),
    FormationAnchor(key: 'st2', group: PositionGroup.striker, x: 0.60, y: 0.84),
    FormationAnchor(key: 'rw', group: PositionGroup.winger, x: 0.84, y: 0.80),
  ],
);

const FormationLayout _f433 = FormationLayout(
  formation: Formation.f433,
  midfieldPoolSize: 3,
  anchors: [
    FormationAnchor(key: 'gk', group: PositionGroup.gk, x: 0.50, y: 0.08),
    FormationAnchor(key: 'lb', group: PositionGroup.fullBack, x: 0.18, y: 0.24),
    FormationAnchor(key: 'lcb', group: PositionGroup.centreBack, x: 0.38, y: 0.22),
    FormationAnchor(key: 'rcb', group: PositionGroup.centreBack, x: 0.62, y: 0.22),
    FormationAnchor(key: 'rb', group: PositionGroup.fullBack, x: 0.82, y: 0.24),
    FormationAnchor(key: 'lw', group: PositionGroup.winger, x: 0.20, y: 0.78),
    FormationAnchor(key: 'st', group: PositionGroup.striker, x: 0.50, y: 0.84),
    FormationAnchor(key: 'rw', group: PositionGroup.winger, x: 0.80, y: 0.78),
  ],
);

const FormationLayout _f442Wide = FormationLayout(
  formation: Formation.f442Wide,
  midfieldPoolSize: 2,
  anchors: [
    FormationAnchor(key: 'gk', group: PositionGroup.gk, x: 0.50, y: 0.08),
    FormationAnchor(key: 'lb', group: PositionGroup.fullBack, x: 0.18, y: 0.24),
    FormationAnchor(key: 'lcb', group: PositionGroup.centreBack, x: 0.38, y: 0.22),
    FormationAnchor(key: 'rcb', group: PositionGroup.centreBack, x: 0.62, y: 0.22),
    FormationAnchor(key: 'rb', group: PositionGroup.fullBack, x: 0.82, y: 0.24),
    FormationAnchor(key: 'lw', group: PositionGroup.winger, x: 0.16, y: 0.56),
    FormationAnchor(key: 'rw', group: PositionGroup.winger, x: 0.84, y: 0.56),
    FormationAnchor(key: 'st1', group: PositionGroup.striker, x: 0.40, y: 0.84),
    FormationAnchor(key: 'st2', group: PositionGroup.striker, x: 0.60, y: 0.84),
  ],
);

const FormationLayout _f442Narrow = FormationLayout(
  formation: Formation.f442Narrow,
  midfieldPoolSize: 4,
  anchors: [
    FormationAnchor(key: 'gk', group: PositionGroup.gk, x: 0.50, y: 0.08),
    FormationAnchor(key: 'lb', group: PositionGroup.fullBack, x: 0.18, y: 0.24),
    FormationAnchor(key: 'lcb', group: PositionGroup.centreBack, x: 0.38, y: 0.22),
    FormationAnchor(key: 'rcb', group: PositionGroup.centreBack, x: 0.62, y: 0.22),
    FormationAnchor(key: 'rb', group: PositionGroup.fullBack, x: 0.82, y: 0.24),
    FormationAnchor(key: 'st1', group: PositionGroup.striker, x: 0.40, y: 0.84),
    FormationAnchor(key: 'st2', group: PositionGroup.striker, x: 0.60, y: 0.84),
  ],
);

const FormationLayout _f451Wide = FormationLayout(
  formation: Formation.f451Wide,
  midfieldPoolSize: 3,
  anchors: [
    FormationAnchor(key: 'gk', group: PositionGroup.gk, x: 0.50, y: 0.08),
    FormationAnchor(key: 'lb', group: PositionGroup.fullBack, x: 0.18, y: 0.24),
    FormationAnchor(key: 'lcb', group: PositionGroup.centreBack, x: 0.38, y: 0.22),
    FormationAnchor(key: 'rcb', group: PositionGroup.centreBack, x: 0.62, y: 0.22),
    FormationAnchor(key: 'rb', group: PositionGroup.fullBack, x: 0.82, y: 0.24),
    FormationAnchor(key: 'lw', group: PositionGroup.winger, x: 0.16, y: 0.56),
    FormationAnchor(key: 'rw', group: PositionGroup.winger, x: 0.84, y: 0.56),
    FormationAnchor(key: 'st', group: PositionGroup.striker, x: 0.50, y: 0.84),
  ],
);

const FormationLayout _f451Narrow = FormationLayout(
  formation: Formation.f451Narrow,
  midfieldPoolSize: 5,
  anchors: [
    FormationAnchor(key: 'gk', group: PositionGroup.gk, x: 0.50, y: 0.08),
    FormationAnchor(key: 'lb', group: PositionGroup.fullBack, x: 0.18, y: 0.24),
    FormationAnchor(key: 'lcb', group: PositionGroup.centreBack, x: 0.38, y: 0.22),
    FormationAnchor(key: 'rcb', group: PositionGroup.centreBack, x: 0.62, y: 0.22),
    FormationAnchor(key: 'rb', group: PositionGroup.fullBack, x: 0.82, y: 0.24),
    FormationAnchor(key: 'st', group: PositionGroup.striker, x: 0.50, y: 0.84),
  ],
);

const FormationLayout _f523 = FormationLayout(
  formation: Formation.f523,
  midfieldPoolSize: 2,
  anchors: [
    FormationAnchor(key: 'gk', group: PositionGroup.gk, x: 0.50, y: 0.08),
    FormationAnchor(key: 'lwb', group: PositionGroup.wingBack, x: 0.10, y: 0.26),
    FormationAnchor(key: 'cb1', group: PositionGroup.centreBack, x: 0.28, y: 0.20),
    FormationAnchor(key: 'cb2', group: PositionGroup.centreBack, x: 0.50, y: 0.18),
    FormationAnchor(key: 'cb3', group: PositionGroup.centreBack, x: 0.72, y: 0.20),
    FormationAnchor(key: 'rwb', group: PositionGroup.wingBack, x: 0.90, y: 0.26),
    FormationAnchor(key: 'lw', group: PositionGroup.winger, x: 0.18, y: 0.80),
    FormationAnchor(key: 'st', group: PositionGroup.striker, x: 0.50, y: 0.84),
    FormationAnchor(key: 'rw', group: PositionGroup.winger, x: 0.82, y: 0.80),
  ],
);

const FormationLayout _f532 = FormationLayout(
  formation: Formation.f532,
  midfieldPoolSize: 3,
  anchors: [
    FormationAnchor(key: 'gk', group: PositionGroup.gk, x: 0.50, y: 0.08),
    FormationAnchor(key: 'lwb', group: PositionGroup.wingBack, x: 0.10, y: 0.26),
    FormationAnchor(key: 'cb1', group: PositionGroup.centreBack, x: 0.28, y: 0.20),
    FormationAnchor(key: 'cb2', group: PositionGroup.centreBack, x: 0.50, y: 0.18),
    FormationAnchor(key: 'cb3', group: PositionGroup.centreBack, x: 0.72, y: 0.20),
    FormationAnchor(key: 'rwb', group: PositionGroup.wingBack, x: 0.90, y: 0.26),
    FormationAnchor(key: 'st1', group: PositionGroup.striker, x: 0.40, y: 0.84),
    FormationAnchor(key: 'st2', group: PositionGroup.striker, x: 0.60, y: 0.84),
  ],
);

const FormationLayout _f541Wide = FormationLayout(
  formation: Formation.f541Wide,
  midfieldPoolSize: 2,
  anchors: [
    FormationAnchor(key: 'gk', group: PositionGroup.gk, x: 0.50, y: 0.08),
    FormationAnchor(key: 'lwb', group: PositionGroup.wingBack, x: 0.10, y: 0.26),
    FormationAnchor(key: 'cb1', group: PositionGroup.centreBack, x: 0.28, y: 0.20),
    FormationAnchor(key: 'cb2', group: PositionGroup.centreBack, x: 0.50, y: 0.18),
    FormationAnchor(key: 'cb3', group: PositionGroup.centreBack, x: 0.72, y: 0.20),
    FormationAnchor(key: 'rwb', group: PositionGroup.wingBack, x: 0.90, y: 0.26),
    FormationAnchor(key: 'lw', group: PositionGroup.winger, x: 0.16, y: 0.56),
    FormationAnchor(key: 'rw', group: PositionGroup.winger, x: 0.84, y: 0.56),
    FormationAnchor(key: 'st', group: PositionGroup.striker, x: 0.50, y: 0.84),
  ],
);

const FormationLayout _f541Narrow = FormationLayout(
  formation: Formation.f541Narrow,
  midfieldPoolSize: 4,
  anchors: [
    FormationAnchor(key: 'gk', group: PositionGroup.gk, x: 0.50, y: 0.08),
    FormationAnchor(key: 'lwb', group: PositionGroup.wingBack, x: 0.10, y: 0.26),
    FormationAnchor(key: 'cb1', group: PositionGroup.centreBack, x: 0.28, y: 0.20),
    FormationAnchor(key: 'cb2', group: PositionGroup.centreBack, x: 0.50, y: 0.18),
    FormationAnchor(key: 'cb3', group: PositionGroup.centreBack, x: 0.72, y: 0.20),
    FormationAnchor(key: 'rwb', group: PositionGroup.wingBack, x: 0.90, y: 0.26),
    FormationAnchor(key: 'st', group: PositionGroup.striker, x: 0.50, y: 0.84),
  ],
);
