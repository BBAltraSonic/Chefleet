import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mocktail/mocktail.dart';
import 'package:chefleet/core/models/user_role.dart';
import 'package:chefleet/core/services/role_storage_service.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late MockFlutterSecureStorage mockSecureStorage;
  late RoleStorageService roleStorageService;

  setUp(() {
    mockSecureStorage = MockFlutterSecureStorage();
    roleStorageService = RoleStorageService(secureStorage: mockSecureStorage);
  });

  group('RoleStorageService', () {
    group('saveActiveRole', () {
      test('saves role to secure storage and updates cache', () async {
        // Arrange
        when(() => mockSecureStorage.write(
              key: any(named: 'key'),
              value: any(named: 'value'),
            )).thenAnswer((_) async => {});

        // Act
        final result = await roleStorageService.saveActiveRole(UserRole.vendor);

        // Assert
        expect(result, isTrue);
        verify(() => mockSecureStorage.write(
              key: 'user_active_role',
              value: 'vendor',
            )).called(1);
        expect(roleStorageService.getActiveRoleSync(), UserRole.vendor);
      });

      test('returns false when storage write fails', () async {
        // Arrange
        when(() => mockSecureStorage.write(
              key: any(named: 'key'),
              value: any(named: 'value'),
            )).thenThrow(Exception('Storage error'));

        // Act
        final result = await roleStorageService.saveActiveRole(UserRole.vendor);

        // Assert
        expect(result, isFalse);
      });
    });

    group('getActiveRole', () {
      test('returns cached role if available', () async {
        // Arrange
        when(() => mockSecureStorage.write(
              key: any(named: 'key'),
              value: any(named: 'value'),
            )).thenAnswer((_) async => {});
        await roleStorageService.saveActiveRole(UserRole.customer);

        // Act
        final role = await roleStorageService.getActiveRole();

        // Assert
        expect(role, UserRole.customer);
        verifyNever(() => mockSecureStorage.read(key: any(named: 'key')));
      });

      test('reads from storage if cache is empty', () async {
        // Arrange
        when(() => mockSecureStorage.read(key: 'user_active_role'))
            .thenAnswer((_) async => 'vendor');

        // Act
        final role = await roleStorageService.getActiveRole();

        // Assert
        expect(role, UserRole.vendor);
        verify(() => mockSecureStorage.read(key: 'user_active_role')).called(1);
      });

      test('returns null if no role is stored', () async {
        // Arrange
        when(() => mockSecureStorage.read(key: 'user_active_role'))
            .thenAnswer((_) async => null);

        // Act
        final role = await roleStorageService.getActiveRole();

        // Assert
        expect(role, isNull);
      });

      test('returns null if storage read fails', () async {
        // Arrange
        when(() => mockSecureStorage.read(key: 'user_active_role'))
            .thenThrow(Exception('Storage error'));

        // Act
        final role = await roleStorageService.getActiveRole();

        // Assert
        expect(role, isNull);
      });
    });

    group('saveAvailableRoles', () {
      test('saves roles to secure storage and updates cache', () async {
        // Arrange
        final roles = {UserRole.customer, UserRole.vendor};
        when(() => mockSecureStorage.write(
              key: any(named: 'key'),
              value: any(named: 'value'),
            )).thenAnswer((_) async => {});

        // Act
        final result = await roleStorageService.saveAvailableRoles(roles);

        // Assert
        expect(result, isTrue);
        verify(() => mockSecureStorage.write(
              key: 'user_available_roles',
              value: 'customer,vendor',
            )).called(1);
        expect(roleStorageService.getAvailableRolesSync(), roles);
      });
    });

    group('getAvailableRoles', () {
      test('returns cached roles if available', () async {
        // Arrange
        final roles = {UserRole.customer, UserRole.vendor};
        when(() => mockSecureStorage.write(
              key: any(named: 'key'),
              value: any(named: 'value'),
            )).thenAnswer((_) async => {});
        await roleStorageService.saveAvailableRoles(roles);

        // Act
        final result = await roleStorageService.getAvailableRoles();

        // Assert
        expect(result, roles);
        verifyNever(() => mockSecureStorage.read(key: any(named: 'key')));
      });

      test('reads from storage if cache is empty', () async {
        // Arrange
        when(() => mockSecureStorage.read(key: 'user_available_roles'))
            .thenAnswer((_) async => 'customer,vendor');

        // Act
        final roles = await roleStorageService.getAvailableRoles();

        // Assert
        expect(roles, {UserRole.customer, UserRole.vendor});
        verify(() => mockSecureStorage.read(key: 'user_available_roles')).called(1);
      });

      test('returns null if no roles are stored', () async {
        // Arrange
        when(() => mockSecureStorage.read(key: 'user_available_roles'))
            .thenAnswer((_) async => null);

        // Act
        final roles = await roleStorageService.getAvailableRoles();

        // Assert
        expect(roles, isNull);
      });
    });

    group('clearRoleData', () {
      test('clears storage and cache', () async {
        // Arrange
        when(() => mockSecureStorage.delete(key: any(named: 'key')))
            .thenAnswer((_) async => {});
        when(() => mockSecureStorage.write(
              key: any(named: 'key'),
              value: any(named: 'value'),
            )).thenAnswer((_) async => {});

        await roleStorageService.saveActiveRole(UserRole.vendor);
        await roleStorageService.saveAvailableRoles({UserRole.vendor});

        // Act
        await roleStorageService.clearRoleData();

        // Assert
        verify(() => mockSecureStorage.delete(key: 'user_active_role')).called(1);
        verify(() => mockSecureStorage.delete(key: 'user_available_roles')).called(1);
        expect(roleStorageService.getActiveRoleSync(), isNull);
        expect(roleStorageService.getAvailableRolesSync(), isNull);
      });

      test('clears cache even if storage delete fails', () async {
        // Arrange
        when(() => mockSecureStorage.delete(key: any(named: 'key')))
            .thenThrow(Exception('Storage error'));
        when(() => mockSecureStorage.write(
              key: any(named: 'key'),
              value: any(named: 'value'),
            )).thenAnswer((_) async => {});

        await roleStorageService.saveActiveRole(UserRole.vendor);

        // Act
        await roleStorageService.clearRoleData();

        // Assert
        expect(roleStorageService.getActiveRoleSync(), isNull);
      });
    });

    group('hasStoredRole', () {
      test('returns true if role is stored', () async {
        // Arrange
        when(() => mockSecureStorage.read(key: 'user_active_role'))
            .thenAnswer((_) async => 'customer');

        // Act
        final hasRole = await roleStorageService.hasStoredRole();

        // Assert
        expect(hasRole, isTrue);
      });

      test('returns false if no role is stored', () async {
        // Arrange
        when(() => mockSecureStorage.read(key: 'user_active_role'))
            .thenAnswer((_) async => null);

        // Act
        final hasRole = await roleStorageService.hasStoredRole();

        // Assert
        expect(hasRole, isFalse);
      });

      test('returns false if storage read fails', () async {
        // Arrange
        when(() => mockSecureStorage.read(key: 'user_active_role'))
            .thenThrow(Exception('Storage error'));

        // Act
        final hasRole = await roleStorageService.hasStoredRole();

        // Assert
        expect(hasRole, isFalse);
      });
    });

    group('preloadCache', () {
      test('loads both active role and available roles into cache', () async {
        // Arrange
        when(() => mockSecureStorage.read(key: 'user_active_role'))
            .thenAnswer((_) async => 'vendor');
        when(() => mockSecureStorage.read(key: 'user_available_roles'))
            .thenAnswer((_) async => 'customer,vendor');

        // Act
        await roleStorageService.preloadCache();

        // Assert
        expect(roleStorageService.getActiveRoleSync(), UserRole.vendor);
        expect(
          roleStorageService.getAvailableRolesSync(),
          {UserRole.customer, UserRole.vendor},
        );
      });
    });

    group('clearCache', () {
      test('clears cache without affecting storage', () async {
        // Arrange
        when(() => mockSecureStorage.write(
              key: any(named: 'key'),
              value: any(named: 'value'),
            )).thenAnswer((_) async => {});
        when(() => mockSecureStorage.read(key: 'user_active_role'))
            .thenAnswer((_) async => 'vendor');

        await roleStorageService.saveActiveRole(UserRole.vendor);
        expect(roleStorageService.getActiveRoleSync(), UserRole.vendor);

        // Act
        roleStorageService.clearCache();

        // Assert
        expect(roleStorageService.getActiveRoleSync(), isNull);
        // Storage should still have the value
        final roleFromStorage = await roleStorageService.getActiveRole();
        expect(roleFromStorage, UserRole.vendor);
      });
    });
  });
}
