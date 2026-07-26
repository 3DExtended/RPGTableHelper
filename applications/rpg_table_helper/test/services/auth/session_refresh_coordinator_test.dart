import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quest_keeper/services/auth/access_token_expiry_store.dart';
import 'package:quest_keeper/services/auth/api_connector_service.dart';
import 'package:quest_keeper/services/auth/secure_refresh_token_storage.dart';
import 'package:quest_keeper/services/auth/session_refresh_coordinator.dart';
import 'package:quest_keeper/services/auth/token_refresher.dart';
import 'package:quest_keeper/services/systemclock_service.dart';

void main() {
  group('SessionRefreshCoordinator.refreshOrHandleFailure', () {
    test('returns the new access token on success without touching the timer',
        () async {
      // arrange
      var tokenRefresher = MockTokenRefresher(accessTokenOverride: 'new-jwt');
      var accessTokenExpiryStore = MockAccessTokenExpiryStore(
        expiryOverride: DateTime.utc(2030, 1, 1, 12),
      );
      var sessionLostCallCount = 0;
      var coordinator = SessionRefreshCoordinator(
        tokenRefresher: tokenRefresher,
        accessTokenExpiryStore: accessTokenExpiryStore,
        systemClockService:
            MockSystemClockService(nowOverride: DateTime.utc(2030, 1, 1)),
        apiConnectorService: MockApiConnectorService(),
        secureRefreshTokenStorage: MockSecureRefreshTokenStorage(),
        onSessionLost: () => sessionLostCallCount++,
      );

      // act
      var result = await coordinator.refreshOrHandleFailure();

      // assert
      expect(result, 'new-jwt');
      expect(sessionLostCallCount, 0);
    });

    test(
        'on failure clears jwt, refresh token, and expiry, then reports session loss',
        () async {
      // arrange
      var tokenRefresher = MockTokenRefresher(refreshResultOverride: false);
      var apiConnectorService = MockApiConnectorService();
      var secureRefreshTokenStorage = MockSecureRefreshTokenStorage(
        refreshTokenOverride: 'a-dead-refresh-token',
      );
      var accessTokenExpiryStore = MockAccessTokenExpiryStore(
        expiryOverride: DateTime.utc(2030, 1, 1, 12),
      );
      var sessionLostCallCount = 0;
      var coordinator = SessionRefreshCoordinator(
        tokenRefresher: tokenRefresher,
        accessTokenExpiryStore: accessTokenExpiryStore,
        systemClockService: MockSystemClockService(),
        apiConnectorService: apiConnectorService,
        secureRefreshTokenStorage: secureRefreshTokenStorage,
        onSessionLost: () => sessionLostCallCount++,
      );

      // act
      var result = await coordinator.refreshOrHandleFailure();

      // assert
      expect(result, isNull);
      expect(sessionLostCallCount, 1);
      expect(apiConnectorService.deleteJwtCallCount, 1);
      expect(secureRefreshTokenStorage.refreshTokenOverride, isNull);
      expect(accessTokenExpiryStore.expiryOverride, isNull);
    });
  });

  group('SessionRefreshCoordinator proactive timer', () {
    test(
        'schedules a refresh ~5 minutes before the persisted expiry and fires it',
        () {
      fakeAsync((async) {
        var now = DateTime.utc(2030, 1, 1, 12);
        var tokenRefresher =
            MockTokenRefresher(accessTokenOverride: 'refreshed-jwt');
        var accessTokenExpiryStore = MockAccessTokenExpiryStore(
          expiryOverride: now.add(const Duration(minutes: 10)),
        );
        var coordinator = SessionRefreshCoordinator(
          tokenRefresher: tokenRefresher,
          accessTokenExpiryStore: accessTokenExpiryStore,
          systemClockService: MockSystemClockService(nowOverride: now),
          apiConnectorService: MockApiConnectorService(),
          secureRefreshTokenStorage: MockSecureRefreshTokenStorage(),
          onSessionLost: () {},
        );

        coordinator.startMonitoring();
        async.flushMicrotasks();

        // Not due yet at 4 minutes (lead time is 5 minutes before the
        // 10-minute expiry, i.e. due at minute 5).
        async.elapse(const Duration(minutes: 4));
        expect(tokenRefresher.refreshCallCount, 0);

        // Crossing the 5-minute mark fires the proactive refresh.
        async.elapse(const Duration(minutes: 2));
        expect(tokenRefresher.refreshCallCount, 1);
      });
    });

    test('refreshes immediately when startMonitoring is called past the lead window',
        () {
      fakeAsync((async) {
        var now = DateTime.utc(2030, 1, 1, 12);
        var tokenRefresher =
            MockTokenRefresher(accessTokenOverride: 'refreshed-jwt');
        // Expiry is only 1 minute away - already inside the 5-minute lead
        // window.
        var accessTokenExpiryStore = MockAccessTokenExpiryStore(
          expiryOverride: now.add(const Duration(minutes: 1)),
        );
        var coordinator = SessionRefreshCoordinator(
          tokenRefresher: tokenRefresher,
          accessTokenExpiryStore: accessTokenExpiryStore,
          systemClockService: MockSystemClockService(nowOverride: now),
          apiConnectorService: MockApiConnectorService(),
          secureRefreshTokenStorage: MockSecureRefreshTokenStorage(),
          onSessionLost: () {},
        );

        coordinator.startMonitoring();
        async.flushMicrotasks();

        expect(tokenRefresher.refreshCallCount, 1);
      });
    });

    test('startMonitoring no-ops when no expiry is persisted (no active session)',
        () {
      fakeAsync((async) {
        var tokenRefresher = MockTokenRefresher();
        var coordinator = SessionRefreshCoordinator(
          tokenRefresher: tokenRefresher,
          accessTokenExpiryStore: MockAccessTokenExpiryStore(),
          systemClockService: MockSystemClockService(),
          apiConnectorService: MockApiConnectorService(),
          secureRefreshTokenStorage: MockSecureRefreshTokenStorage(),
          onSessionLost: () {},
        );

        coordinator.startMonitoring();
        async.flushMicrotasks();
        async.elapse(const Duration(hours: 1));

        expect(tokenRefresher.refreshCallCount, 0);
      });
    });

    test('stopMonitoring cancels a pending proactive timer', () {
      fakeAsync((async) {
        var now = DateTime.utc(2030, 1, 1, 12);
        var tokenRefresher = MockTokenRefresher();
        var accessTokenExpiryStore = MockAccessTokenExpiryStore(
          expiryOverride: now.add(const Duration(minutes: 10)),
        );
        var coordinator = SessionRefreshCoordinator(
          tokenRefresher: tokenRefresher,
          accessTokenExpiryStore: accessTokenExpiryStore,
          systemClockService: MockSystemClockService(nowOverride: now),
          apiConnectorService: MockApiConnectorService(),
          secureRefreshTokenStorage: MockSecureRefreshTokenStorage(),
          onSessionLost: () {},
        );

        coordinator.startMonitoring();
        async.flushMicrotasks();
        coordinator.stopMonitoring();

        async.elapse(const Duration(minutes: 10));

        expect(tokenRefresher.refreshCallCount, 0);
      });
    });
  });

  group('SessionRefreshCoordinator.onAppResume', () {
    test('refreshes when the access token is already expired', () async {
      // arrange
      var now = DateTime.utc(2030, 1, 1, 12);
      var tokenRefresher = MockTokenRefresher(accessTokenOverride: 'new-jwt');
      var coordinator = SessionRefreshCoordinator(
        tokenRefresher: tokenRefresher,
        accessTokenExpiryStore: MockAccessTokenExpiryStore(
          expiryOverride: now.subtract(const Duration(minutes: 1)),
        ),
        systemClockService: MockSystemClockService(nowOverride: now),
        apiConnectorService: MockApiConnectorService(),
        secureRefreshTokenStorage: MockSecureRefreshTokenStorage(),
        onSessionLost: () {},
      );

      // act
      await coordinator.onAppResume();

      // assert
      expect(tokenRefresher.refreshCallCount, 1);
    });

    test('refreshes when within the lead window but not yet expired',
        () async {
      // arrange
      var now = DateTime.utc(2030, 1, 1, 12);
      var tokenRefresher = MockTokenRefresher(accessTokenOverride: 'new-jwt');
      var coordinator = SessionRefreshCoordinator(
        tokenRefresher: tokenRefresher,
        accessTokenExpiryStore: MockAccessTokenExpiryStore(
          expiryOverride: now.add(const Duration(minutes: 2)),
        ),
        systemClockService: MockSystemClockService(nowOverride: now),
        apiConnectorService: MockApiConnectorService(),
        secureRefreshTokenStorage: MockSecureRefreshTokenStorage(),
        onSessionLost: () {},
      );

      // act
      await coordinator.onAppResume();

      // assert
      expect(tokenRefresher.refreshCallCount, 1);
    });

    test('does not refresh when well outside the lead window', () async {
      // arrange
      var now = DateTime.utc(2030, 1, 1, 12);
      var tokenRefresher = MockTokenRefresher();
      var coordinator = SessionRefreshCoordinator(
        tokenRefresher: tokenRefresher,
        accessTokenExpiryStore: MockAccessTokenExpiryStore(
          expiryOverride: now.add(const Duration(minutes: 30)),
        ),
        systemClockService: MockSystemClockService(nowOverride: now),
        apiConnectorService: MockApiConnectorService(),
        secureRefreshTokenStorage: MockSecureRefreshTokenStorage(),
        onSessionLost: () {},
      );

      // act
      await coordinator.onAppResume();

      // assert
      expect(tokenRefresher.refreshCallCount, 0);
    });

    test('no-ops when there is no active session (no persisted expiry)',
        () async {
      // arrange
      var tokenRefresher = MockTokenRefresher();
      var coordinator = SessionRefreshCoordinator(
        tokenRefresher: tokenRefresher,
        accessTokenExpiryStore: MockAccessTokenExpiryStore(),
        systemClockService: MockSystemClockService(),
        apiConnectorService: MockApiConnectorService(),
        secureRefreshTokenStorage: MockSecureRefreshTokenStorage(),
        onSessionLost: () {},
      );

      // act
      await coordinator.onAppResume();

      // assert
      expect(tokenRefresher.refreshCallCount, 0);
    });
  });

  group('MockSessionRefreshCoordinator', () {
    test('tracks call counts and returns the configured refresh result',
        () async {
      var mock = MockSessionRefreshCoordinator(
        refreshResultOverride: 'configured-token',
      );

      await mock.startMonitoring();
      mock.stopMonitoring();
      await mock.onAppResume();
      var result = await mock.refreshOrHandleFailure();

      expect(mock.startMonitoringCallCount, 1);
      expect(mock.stopMonitoringCallCount, 1);
      expect(mock.onAppResumeCallCount, 1);
      expect(result, 'configured-token');
      expect(mock.refreshOrHandleFailureCallCount, 1);
    });
  });
}
