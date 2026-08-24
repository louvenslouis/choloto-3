import '/app_state.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';

enum BingoReaction { positive, negative }

class BingoReactionUnavailableException implements Exception {
  const BingoReactionUnavailableException();
}

class BingoReactionUpdate {
  const BingoReactionUpdate({
    required this.reaction,
    required this.reference,
  });

  final BingoReaction? reaction;
  final DocumentReference? reference;
}

BingoReaction? bingoReactionFromState(BingoStruct bingo) {
  if (!bingo.hasRefGain() || !bingo.hasGagner()) {
    return null;
  }

  return bingo.gagner ? BingoReaction.positive : BingoReaction.negative;
}

Map<String, int> bingoReactionCounterDeltas({
  required BingoReaction? previous,
  required BingoReaction? next,
}) {
  final deltas = <String, int>{};

  if (previous == BingoReaction.positive) {
    deltas['bingoGain'] = -1;
  } else if (previous == BingoReaction.negative) {
    deltas['bingoRater'] = -1;
  }

  if (next == BingoReaction.positive) {
    deltas.update('bingoGain', (value) => value + 1, ifAbsent: () => 1);
  } else if (next == BingoReaction.negative) {
    deltas.update('bingoRater', (value) => value + 1, ifAbsent: () => 1);
  }

  deltas.removeWhere((_, value) => value == 0);
  return deltas;
}

Future<BingoReaction?> toggleCurrentBingoReaction(
  BingoReaction requestedReaction,
) async {
  final update = await toggleBingoReaction(
    bingo: FFAppState().bingo,
    requestedReaction: requestedReaction,
    updateCurrentState: true,
  );
  return update.reaction;
}

Future<BingoReactionUpdate> toggleBingoReaction({
  required BingoStruct bingo,
  required BingoReaction requestedReaction,
  bool updateCurrentState = false,
}) async {
  final bingoReference = bingo.doc;
  final userReference = currentUserReference;

  if (bingoReference == null ||
      userReference == null ||
      currentUserUid.isEmpty) {
    throw const BingoReactionUnavailableException();
  }

  final previousReaction = bingoReactionFromState(bingo);
  final nextReaction =
      previousReaction == requestedReaction ? null : requestedReaction;
  final previousReference = bingo.refGain;
  final batch = FirebaseFirestore.instance.batch();
  DocumentReference? nextReference = previousReference;

  if (previousReference == null) {
    nextReference = BingostatsRecord.createDoc(bingoReference);
    batch.set(
      nextReference,
      createBingostatsRecordData(
        user: currentUserUid,
        gain: nextReaction == BingoReaction.positive,
      ),
    );
  } else if (nextReaction == null) {
    batch.delete(previousReference);
    nextReference = null;
  } else {
    batch.update(
      previousReference,
      createBingostatsRecordData(
        gain: nextReaction == BingoReaction.positive,
      ),
    );
  }

  final counterDeltas = bingoReactionCounterDeltas(
    previous: previousReaction,
    next: nextReaction,
  );
  batch.update(
    userReference,
    createUserRecordData(
      userStats: createUserStatsStruct(
        fieldValues: {
          for (final entry in counterDeltas.entries)
            entry.key: FieldValue.increment(entry.value),
        },
        clearUnsetFields: false,
      ),
    ),
  );

  await batch.commit();

  if (updateCurrentState && FFAppState().bingo.doc == bingoReference) {
    FFAppState().updateBingoStruct(
      (value) => value
        ..gagner = switch (nextReaction) {
          BingoReaction.positive => true,
          BingoReaction.negative => false,
          null => null,
        }
        ..refGain = nextReference,
    );
  }

  return BingoReactionUpdate(
    reaction: nextReaction,
    reference: nextReference,
  );
}
