import 'package:collection/collection.dart';

enum Tirages {
  NEWYORK,
  GEORGIA,
  FLORIDA,
}

enum Moment {
  MIDI,
  SOIR,
}

enum Paiement {
  Cash,
  Moncash,
  Stripe,
}

enum Mois {
  Janvier,
  Fevrier,
  Mars,
  Avril,
  Mai,
  Juin,
  Juillet,
  Aout,
  Septembre,
  Octobre,
  Novembre,
  Decembre,
}

enum StoryType {
  bingo,
  youtube,
}

extension FFEnumExtensions<T extends Enum> on T {
  String serialize() => name;
}

extension FFEnumListExtensions<T extends Enum> on Iterable<T> {
  T? deserialize(String? value) =>
      firstWhereOrNull((e) => e.serialize() == value);
}

T? deserializeEnum<T>(String? value) {
  switch (T) {
    case (Tirages):
      return Tirages.values.deserialize(value) as T?;
    case (Moment):
      return Moment.values.deserialize(value) as T?;
    case (Paiement):
      return Paiement.values.deserialize(value) as T?;
    case (Mois):
      return Mois.values.deserialize(value) as T?;
    case (StoryType):
      return StoryType.values.deserialize(value) as T?;
    default:
      return null;
  }
}
