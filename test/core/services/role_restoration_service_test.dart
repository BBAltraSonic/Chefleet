import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:chefleet/core/models/user_role.dart';
import 'package:chefleet/core/services/role_storage_service.dart';
import 'package:chefleet/core/services/role_sync_service.dart';
import 'package:chefleet/core/services/role_restoration_service.dart';
import 'package:chefleet/core/services/role_service.dart';

class MockRoleStorageService extends Mock implements RoleStorageService {}

class MockRoleSyncService extends Mock implements RoleSyncService {}

void main() {
  late MockRoleStorageService mockStorageService;
  late MockRoleSyncService mockSyncService;
  late RoleRestorationService restorationService;

  setUp(() {
    mockStorageService = MockRoleStorageService();
    mockSyncService = MockRoleSyncService();
    restorationService = RoleRestorationService(
      storageService: mockStorageService,
      syncService: mockSyncService,
    );
  });

  group('RoleRestorationService', () {
    group('restoreRole', () {
      test('returns backend data when available and matches local', () async {
        // Arrange
        when(() => mockStorageService.preloadCache()).thenAnswer((_) async => {});
        when(() => mockStorageService.getActiveRole())
            .thenAnswer((_) async => UserRole.customer);
        when(() => mockStorageService.getAvailableRoles())
            .thenAnswer((_) async => {UserRole.customer});
        when(() => mockSyncService.fetchRoleData())
            .thenAnswer((_) async => (UserRole.customer, {UserRole.customer}));

        // Act
        final result = await restorationService.restoreRole();

        // Assert
        expect(result.activeRole, UserRole.customer);
        expect(result.availableRoles, {UserRole.customer});
        expect(result.source, RoleRestorationSource.backend);
        expect(result.hadConflict, isFalse);
        expect(result.isSuccess, isTrue);
      });

      test('resolves conflict when backend differs from local', () async {
        // Arrange
        when(() => mockStorageService.preloadCache()).thenAnswer((_) async => {});
        when(() => mockStorageService.getActiveRole())
            .thenAnswer((_) async => UserRole.customer);
        when(() => mockStorageService.getAvailableRoles())
            .thenAnswer((_) async => {UserRole.customer});
        when(() => mockSyncService.fetchRoleData())
            .thenAnswer((_) async => (UserRole.vendor, {UserRole.customer, UserRole.vendor}));
        when(() => mockStorageService.saveActiveRole(any()))
            .thenAnswer((_) async => true);
        when(() => mockStorageService.saveAvailableRoles(any()))
            .thenAnswer((_) async => true);

        // Act
        final result = await restorationService.restoreRole();

        // Assert
        expect(result.activeRole, UserRole.vendor);
        expect(result.availableRoles, {UserRole.customer, UserRole.vendor});
        expect(result.source, RoleRestorationSource.backendConflictResolved);
        expect(result.hadConflict, isTrue);
        verify(() => mockStorageService.saveActiveRole(UserRole.vendor)).called(1);
        verify(() => mockStorageService.saveAvailableRoles(
              {UserRole.customer, UserRole.vendor},
            )).called(1);
      });

      test('uses local storage when backend fetch fails', () async {
        // Arrange
        when(() => mockStorageService.preloadCache()).thenAnswer((_) async => {});
        when(() => mockStorageService.getActiveRole())
            .thenAnswer((_) async => UserRole.vendor);
        when(() => mockStorageService.getAvailableRoles())
            .thenAnswer((_) async => {UserRole.customer, UserRole.vendor});
        when(() => mockSyncService.fetchRoleData())
            .thenThrow(RoleSyncException('Network error'));

        // Act
        final result = await restorationService.restoreRole();

        // Assert
        expect(result.activeRole, UserRole.vendor);
        expect(result.availableRoles, {UserRole.customer, UserRole.vendor});
        expect(result.source, RoleRestorationSource.localStorage);
        expect(result.error, isNotNull);
        expect(result.isSuccess, isFalse);
      });

      test('uses defaults when both backend and local storage fail', () async {
        // Arrange
        when(() => mockStorageService.preloadCache()).thenAnswer((_) async => {});
        when(() => mockStorageService.getActiveRole()).thenAnswer((_) async => null);
        when(() => mockStorageService.getAvailableRoles()).thenAnswer((_) async => null);
        when(() => mockSyncService.fetchRoleData())
            .thenThrow(RoleSyncException('Network error'));
        when(() => mockStorageService.saveActiveRole(any()))
            .thenAnswer((_) async => true);
        when(() => mockStorageService.saveAvailableRoles(any()))
            .thenAnswer((_) async => true);

        // Act
        final result = await restorationService.restoreRole();

        // Assert
        expect(result.activeRole, UserRole.customer);
        expect(result.availableRoles, {UserRole.customer});
        expect(result.source, RoleRestorationSource.defaultFallback);
        expect(result.usedDefaults, isTrue);
        verify(() => mockStorageService.saveActiveRole(UserRole.customer)).called(1);
        verify(() => mockStorageService.saveAvailableRoles({UserRole.customer})).called(1);
      });

      test('updates local storage when backend has data but local does not', () async {
        // Arrange
        when(() => mockStorageService.preloadCache()).thenAnswer((_) async => {});
        when(() => mockStorageService.getActiveRole()).thenAnswer((_) async => null);
        when(() => mockStorageService.getAvailableRoles()).thenAnswer((_) async => null);
        when(() => mockSyncService.fetchRoleData())
            .thenAnswer((_) async => (UserRole.vendor, {UserRole.customer, UserRole.vendor}));
        when(() => mockStorageService.saveActiveRole(any()))
            .thenAnswer((_) async => true);
        when(() => mockStorageService.saveAvailableRoles(any()))
            .thenAnswer((_) async => true);

        // Act
        final result = await restorationService.restoreRole();

        // Assert
        expect(result.activeRole, UserRole.vendor);
        expect(result.source, RoleRestorationSource.backend);
        verify(() => mockStorageService.saveActiveRole(UserRole.vendor)).called(1);
        verify(() => mockStorageService.saveAvailableRoles(
              {UserRole.customer, UserRole.vendor},
            )).called(1);
      });
    });

    group('validateAndCorrectRole', () {
      test('returns role unchanged if it is in available roles', () async {
        // Act
        final result = await restorationService.validateAndCorrectRole(
          UserRole.vendor,
          {UserRole.customer, UserRole.vendor},
        );

        // Assert
        expect(result, UserRole.vendor);
        verifyNever(() => mockStorageService.saveActiveRole(any()));
      });

      test('switches to customer if active role is not available', () async {
        // Arrange
        when(() => mockStorageService.saveActiveRole(any()))
            .thenAnswer((_) async => true);
        when(() => mockSyncService.syncActiveRole(any()))
            .thenAnswer((_) async => {});

        // Act
        final result = await restorationService.validateAndCorrectRole(
          UserRole.vendor,
          {UserRole.customer},
        );

        // Assert
        expect(result, UserRole.customer);
        verify(() => mockStorageService.saveActiveRole(UserRole.customer)).called(1);
        verify(() => mockSyncService.syncActiveRole(UserRole.customer)).called(1);
      });

      test('continues even if backend sync fails', () async {
        // Arrange
        when(() => mockStorageService.saveActiveRole(any()))
            .thenAnswer((_) async => true);
        when(() => mockSyncService.syncActiveRole(any()))
            .thenThrow(RoleSyncException('Network error'));

        // Act
        final result = await restorationService.validateAndCorrectRole(
          UserRole.vendor,
          {UserRole.customer},
        );

        // Assert
        expect(result, UserRole.customer);
        verify(() => mockStorageService.saveActiveRole(UserRole.customer)).called(1);
      });
    });

    group('backgroundSync', () {
      test('syncs active role to backend', () async {
        // Arrange
        when(() => mockSyncService.syncActiveRole(any()))
            .thenAnswer((_) async => {});

        // Act
        await restorationService.backgroundSync(UserRole.vendor);

        // Assert
        verify(() => mockSyncService.syncActiveRole(UserRole.vendor)).called(1);
      });

      test('does not throw if sync fails', () async {
        // Arrange
        when(() => mockSyncService.syncActiveRole(any()))
            .thenThrow(RoleSyncException('Network error'));

        // Act & Assert - should not throw
        await restorationService.backgroundSync(UserRole.vendor);
      });
    });

    group('clearRoleData', () {
      test('clears storage and sync queue', () async {
        // Arrange
        when(() => mockStorageService.clearRoleData()).thenAnswer((_) async => {});
        when(() => mockSyncService.clearSyncQueue()).thenReturn(null);

        // Act
        await restorationService.clearRoleData();

        // Assert
        verify(() => mockStorageService.clearRoleData()).called(1);
        verify(() => mockSyncService.clearSyncQueue()).called(1);
      });
    });
  });

  group('RoleRestorationResult', () {
    test('isSuccess returns true when no error', () {
      final result = RoleRestorationResult(
        activeRole: UserRole.customer,
        availableRoles: {UserRole.customer},
        source: RoleRestorationSource.backend,
      );

      expect(result.isSuccess, isTrue);
    });

    test('isSuccess returns false when error exists', () {
      final result = RoleRestorationResult(
        activeRole: UserRole.customer,
        availableRoles: {UserRole.customer},
        source: RoleRestorationSource.localStorage,
        error: 'Network error',
      );

      expect(result.isSuccess, isFalse);
    });

    test('usedDefaults returns true for defaultFallback source', () {
      final result = RoleRestorationResult(
        activeRole: UserRole.customer,
        availableRoles: {UserRole.customer},
        source: RoleRestorationSource.defaultFallback,
      );

      expect(result.usedDefaults, isTrue);
    });

    test('isFromBackend returns true for backend sources', () {
      final result1 = RoleRestorationResult(
        activeRole: UserRole.customer,
        availableRoles: {UserRole.customer},
        source: RoleRestorationSource.backend,
      );

      final result2 = RoleRestorationResult(
        activeRole: UserRole.customer,
        availableRoles: {UserRole.customer},
        source: RoleRestorationSource.backendConflictResolved,
      );

      expect(result1.isFromBackend, isTrue);
      expect(result2.isFromBackend, isTrue);
    });
  });
}
