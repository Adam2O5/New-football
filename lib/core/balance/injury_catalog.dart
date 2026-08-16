import 'package:new_football/core/models/enums.dart';

/// One weighted injury definition from `player_management.md`.
class InjuryDefinition {
  const InjuryDefinition({
    required this.id,
    required this.name,
    required this.group,
    required this.type,
    required this.minDays,
    required this.maxDays,
    required this.weight,
  });

  final String id;
  final String name;
  final InjuryGroup group;
  final InjuryType type;
  final int minDays;
  final int maxDays;
  final double weight;
}

/// The complete Task 10 injury catalogue.
class InjuryCatalog {
  InjuryCatalog._();

  static const List<InjuryDefinition> definitions = [
    InjuryDefinition(
      id: 'concussion',
      name: 'Wstrząśnienie mózgu',
      group: InjuryGroup.headFace,
      type: InjuryType.minor,
      minDays: 3,
      maxDays: 14,
      weight: 2.9,
    ),
    InjuryDefinition(
      id: 'scalp_laceration',
      name: 'Rozcięta głowa',
      group: InjuryGroup.headFace,
      type: InjuryType.minor,
      minDays: 0,
      maxDays: 3,
      weight: 4.4,
    ),
    InjuryDefinition(
      id: 'eyebrow_laceration',
      name: 'Rozcięty łuk brwiowy',
      group: InjuryGroup.headFace,
      type: InjuryType.minor,
      minDays: 0,
      maxDays: 3,
      weight: 1.0,
    ),
    InjuryDefinition(
      id: 'jaw_fracture',
      name: 'Złamana szczęka',
      group: InjuryGroup.headFace,
      type: InjuryType.minor,
      minDays: 30,
      maxDays: 60,
      weight: 2.9,
    ),
    InjuryDefinition(
      id: 'nose_fracture',
      name: 'Złamany nos',
      group: InjuryGroup.headFace,
      type: InjuryType.minor,
      minDays: 3,
      maxDays: 14,
      weight: 3.6,
    ),
    InjuryDefinition(
      id: 'cheekbone_fracture',
      name: 'Złamana kość policzkowa',
      group: InjuryGroup.headFace,
      type: InjuryType.minor,
      minDays: 14,
      maxDays: 42,
      weight: 2.9,
    ),
    InjuryDefinition(
      id: 'shoulder_dislocation',
      name: 'Wybity bark',
      group: InjuryGroup.shouldersChest,
      type: InjuryType.minor,
      minDays: 21,
      maxDays: 42,
      weight: 2.9,
    ),
    InjuryDefinition(
      id: 'clavicle_fracture',
      name: 'Złamany obojczyk',
      group: InjuryGroup.shouldersChest,
      type: InjuryType.minor,
      minDays: 30,
      maxDays: 60,
      weight: 2.9,
    ),
    InjuryDefinition(
      id: 'rib_contusion',
      name: 'Stłuczenie żeber',
      group: InjuryGroup.shouldersChest,
      type: InjuryType.minor,
      minDays: 7,
      maxDays: 20,
      weight: 4.3,
    ),
    InjuryDefinition(
      id: 'rib_fracture',
      name: 'Złamanie żeber',
      group: InjuryGroup.shouldersChest,
      type: InjuryType.minor,
      minDays: 20,
      maxDays: 40,
      weight: 3.6,
    ),
    InjuryDefinition(
      id: 'chest_muscle_strain',
      name: 'Naciągnięcie mięśni klatki piersiowej',
      group: InjuryGroup.shouldersChest,
      type: InjuryType.minor,
      minDays: 3,
      maxDays: 14,
      weight: 2.9,
    ),
    InjuryDefinition(
      id: 'hamstring_strain',
      name: 'Naciągnięcie mięśnia dwugłowego uda',
      group: InjuryGroup.legMuscles,
      type: InjuryType.minor,
      minDays: 14,
      maxDays: 42,
      weight: 5.8,
    ),
    InjuryDefinition(
      id: 'hamstring_tear',
      name: 'Zerwanie mięśnia dwugłowego uda',
      group: InjuryGroup.legMuscles,
      type: InjuryType.major,
      minDays: 60,
      maxDays: 90,
      weight: 2.4,
    ),
    InjuryDefinition(
      id: 'quadriceps_strain',
      name: 'Naderwanie mięśnia czworogłowego uda',
      group: InjuryGroup.legMuscles,
      type: InjuryType.minor,
      minDays: 14,
      maxDays: 56,
      weight: 4.3,
    ),
    InjuryDefinition(
      id: 'groin_injury',
      name: 'Uraz pachwiny',
      group: InjuryGroup.legMuscles,
      type: InjuryType.minor,
      minDays: 7,
      maxDays: 90,
      weight: 5.2,
    ),
    InjuryDefinition(
      id: 'calf_strain',
      name: 'Naciągnięcie łydki',
      group: InjuryGroup.legMuscles,
      type: InjuryType.minor,
      minDays: 14,
      maxDays: 30,
      weight: 4.2,
    ),
    InjuryDefinition(
      id: 'calf_tear',
      name: 'Naderwanie łydki',
      group: InjuryGroup.legMuscles,
      type: InjuryType.minor,
      minDays: 25,
      maxDays: 42,
      weight: 3.6,
    ),
    InjuryDefinition(
      id: 'acl_tear',
      name: 'Zerwanie więzadeł krzyżowych',
      group: InjuryGroup.knees,
      type: InjuryType.major,
      minDays: 180,
      maxDays: 300,
      weight: 4.8,
    ),
    InjuryDefinition(
      id: 'mcl_lcl_damage',
      name: 'Uszkodzenie więzadeł pobocznych',
      group: InjuryGroup.knees,
      type: InjuryType.major,
      minDays: 50,
      maxDays: 90,
      weight: 2.6,
    ),
    InjuryDefinition(
      id: 'meniscus_damage',
      name: 'Uszkodzenie łąkotki',
      group: InjuryGroup.knees,
      type: InjuryType.major,
      minDays: 50,
      maxDays: 70,
      weight: 3.2,
    ),
    InjuryDefinition(
      id: 'knee_sprain',
      name: 'Skręcenie kolana',
      group: InjuryGroup.knees,
      type: InjuryType.minor,
      minDays: 14,
      maxDays: 28,
      weight: 6.5,
    ),
    InjuryDefinition(
      id: 'ankle_sprain',
      name: 'Skręcenie stawu skokowego',
      group: InjuryGroup.anklesFeet,
      type: InjuryType.minor,
      minDays: 3,
      maxDays: 42,
      weight: 7.0,
    ),
    InjuryDefinition(
      id: 'achilles_tear',
      name: 'Zerwanie ścięgna Achillesa',
      group: InjuryGroup.anklesFeet,
      type: InjuryType.major,
      minDays: 50,
      maxDays: 180,
      weight: 3.8,
    ),
    InjuryDefinition(
      id: 'metatarsal_fracture',
      name: 'Złamanie kości śródstopia',
      group: InjuryGroup.anklesFeet,
      type: InjuryType.major,
      minDays: 60,
      maxDays: 90,
      weight: 3.2,
    ),
    InjuryDefinition(
      id: 'toe_fracture',
      name: 'Złamany palec u nogi',
      group: InjuryGroup.anklesFeet,
      type: InjuryType.minor,
      minDays: 14,
      maxDays: 21,
      weight: 2.9,
    ),
    InjuryDefinition(
      id: 'foot_contusion',
      name: 'Stłuczenie stopy',
      group: InjuryGroup.anklesFeet,
      type: InjuryType.minor,
      minDays: 3,
      maxDays: 7,
      weight: 3.4,
    ),
  ];

  static InjuryDefinition byId(String id) => definitions.firstWhere(
    (definition) => definition.id == id,
    orElse: () => throw ArgumentError('Unknown injury id: $id'),
  );

  static double get totalWeight =>
      definitions.fold(0.0, (total, definition) => total + definition.weight);
}
