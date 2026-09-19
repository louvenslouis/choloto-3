import 'package:choloto/app_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('beta feature cache expires after one hour and survives recreation',
      () async {
    SharedPreferences.setMockInitialValues({});
    FFAppState.reset();
    final state = FFAppState();
    await state.initializePersistedState();
    final fetchedAt = DateTime(2026, 9, 19, 10);

    expect(state.shouldRefreshBetaFeatures(fetchedAt), isTrue);
    state.markBetaFeaturesFetched(fetchedAt);
    expect(
      state.shouldRefreshBetaFeatures(
        fetchedAt.add(const Duration(minutes: 59)),
      ),
      isFalse,
    );

    FFAppState.reset();
    final restored = FFAppState();
    await restored.initializePersistedState();
    expect(restored.betaFeaturesFetchedAt, fetchedAt);
    expect(
      restored.shouldRefreshBetaFeatures(
        fetchedAt.add(const Duration(hours: 1)),
      ),
      isTrue,
    );
  });
}
