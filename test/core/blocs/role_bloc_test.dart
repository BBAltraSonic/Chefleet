import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:chefleet/core/blocs/role_bloc.dart';
import 'package:chefleet/core/blocs/role_event.dart';
import 'package:chefleet/core/blocs/role_state.dart';
import 'package:chefleet/core/models/user_role.dart';
import 'package:chefleet/core/services/role_storage_service.dart';
import 'package:chefleet/core/services/role_sync_service.dart';
import 'package:chefleet/core/services/role_service.dart';

// Mock classes
class MockRoleStorageService extends Mock implements RoleStorageService {}
class MockRoleSyncService extends Mock implements RoleSyncService {}

void main() {
  late MockRoleStorageService mockStorageService;
  late MockRoleSyncService mockSyncService;

  setUp(() {
    mockStorageService = MockRoleStorageService();
    mockSyncService = MockRoleSyncService();
  });

  group('RoleBloc', () {
    test('initial state is RoleInitial', () {
      final bloc = RoleBloc(
        storageService: mockStorageService,
        syncService: mockSyncService,
      );
      expect(bloc.state, equals(const RoleInitial()));
      bloc.close();
    });

    group('RoleRequested', () {
      blocTest<RoleBloc, RoleState>(
        'emits [RoleLoading, RoleLoaded] when role is loaded from cache',
        build: () {
          when(() => mockStorageService.getActiveRole())
              .thenAnswer((_) async => UserRole.customer);
          when(() => mockStorageService.getAvailableRoles())
              .thenAnswer((_) async => {UserRole.customer});
          when(() => mockSyncService.fetchRoleData())
              .thenAnswer((_) async => (UserRole.customer, {UserRole.customer}));
          return RoleBloc(
            storageService: mockStorageService,
            syncService: mockSyncService,
          );
        },
        act: (bloc) => bloc.add(const RoleRequested()),
        expect: () => [
          const RoleLoading(),
          const RoleLoaded(
            activeRole: UserRole.customer,
            availableRoles: {UserRole.customer},
          ),
        ],
        verify: (_) {
          verify(() => mockStorageService.getActiveRole()).called(1);
          verify(() => mockStorageService.getAvailableRoles()).called(1);
        },
      );

      blocTest<RoleBloc, RoleState>(
        'emits [RoleLoading, RoleLoaded] when role is fetched from backend',
        build: () {
          when(() => mockStorageService.getActiveRole())
              .thenAnswer((_) async => null);
          when(() => mockStorageService.getAvailableRoles())
              .thenAnswer((_) async => null);
          when(() => mockSyncService.fetchRoleData())
              .thenAnswer((_) async => (UserRole.customer, {UserRole.customer}));
          when(() => mockStorageService.saveActiveRole(any()))
              .thenAnswer((_) async => true);
          when(() => mockStorageService.saveAvailableRoles(any()))
              .thenAnswer((_) async => true);
          return RoleBloc(
            storageService: mockStorageService,
            syncService: mockSyncService,
          );
        },
        act: (bloc) => bloc.add(const RoleRequested()),
        expect: () => [
          const RoleLoading(),
          const RoleLoaded(
            activeRole: UserRole.customer,
            availableRoles: {UserRole.customer},
          ),
        ],
        verify: (_) {
          verify(() => mockSyncService.fetchRoleData()).called(1);
          verify(() => mockStorageService.saveActiveRole(UserRole.customer)).called(1);
          verify(() => mockStorageService.saveAvailableRoles({UserRole.customer})).called(1);
        },
      );

      blocTest<RoleBloc, RoleState>(
        'emits [RoleLoading, RoleError] when not authenticated',
        build: () {
          when(() => mockStorageService.getActiveRole())
              .thenAnswer((_) async => null);
          when(() => mockStorageService.getAvailableRoles())
              .thenAnswer((_) async => null);
          when(() => mockSyncService.fetchRoleData())
              .thenThrow(const RoleNotAuthenticatedException());
          return RoleBloc(
            storageService: mockStorageService,
            syncService: mockSyncService,
          );
        },
        act: (bloc) => bloc.add(const RoleRequested()),
        expect: () => [
          const RoleLoading(),
          isA<RoleError>()
              .having((s) => s.message, 'message', 'User not authenticated')
              .having((s) => s.code, 'code', 'NOT_AUTHENTICATED'),
        ],
      );
    });

    group('RoleSwitchRequested', () {
      blocTest<RoleBloc, RoleState>(
        'emits [RoleSwitching, RoleSwitched, RoleLoaded] when switch is successful',
        build: () {
          when(() => mockStorageService.saveActiveRole(any()))
              .thenAnswer((_) async => true);
          when(() => mockSyncService.syncActiveRole(any()))
              .thenAnswer((_) async {});
          return RoleBloc(
            storageService: mockStorageService,
            syncService: mockSyncService,
          );
        },
        seed: () => const RoleLoaded(
          activeRole: UserRole.customer,
          availableRoles: {UserRole.customer, UserRole.vendor},
        ),
        act: (bloc) => bloc.add(const RoleSwitchRequested(newRole: UserRole.vendor)),
        expect: () => [
          const RoleSwitching(
            fromRole: UserRole.customer,
            toRole: UserRole.vendor,
          ),
          const RoleSwitched(
            newRole: UserRole.vendor,
            availableRoles: {UserRole.customer, UserRole.vendor},
          ),
          const RoleLoaded(
            activeRole: UserRole.vendor,
            availableRoles: {UserRole.customer, UserRole.vendor},
          ),
        ],
        verify: (_) {
          verify(() => mockStorageService.saveActiveRole(UserRole.vendor)).called(1);
        },
      );

      blocTest<RoleBloc, RoleState>(
        'emits [RoleError] when role is not available',
        build: () => RoleBloc(
          storageService: mockStorageService,
          syncService: mockSyncService,
        ),
        seed: () => const RoleLoaded(
          activeRole: UserRole.customer,
          availableRoles: {UserRole.customer},
        ),
        act: (bloc) => bloc.add(const RoleSwitchRequested(newRole: UserRole.vendor)),
        expect: () => [
          isA<RoleError>()
              .having((s) => s.message, 'message', 'Role Vendor is not available')
              .having((s) => s.code, 'code', 'ROLE_NOT_AVAILABLE'),
        ],
      );

      blocTest<RoleBloc, RoleState>(
        'does not emit when switching to same role',
        build: () => RoleBloc(
          storageService: mockStorageService,
          syncService: mockSyncService,
        ),
        seed: () => const RoleLoaded(
          activeRole: UserRole.customer,
          availableRoles: {UserRole.customer},
        ),
        act: (bloc) => bloc.add(const RoleSwitchRequested(newRole: UserRole.customer)),
        expect: () => [],
      );

      blocTest<RoleBloc, RoleState>(
        'emits [RoleError] when role is not loaded',
        build: () => RoleBloc(
          storageService: mockStorageService,
          syncService: mockSyncService,
        ),
        act: (bloc) => bloc.add(const RoleSwitchRequested(newRole: UserRole.vendor)),
        expect: () => [
          isA<RoleError>()
              .having((s) => s.message, 'message', 'Cannot switch role: role not loaded')
              .having((s) => s.code, 'code', 'ROLE_NOT_LOADED'),
        ],
      );
    });

    group('RoleRestored', () {
      blocTest<RoleBloc, RoleState>(
        'emits [RoleLoaded] when role is restored successfully',
        build: () {
          when(() => mockStorageService.getAvailableRoles())
              .thenAnswer((_) async => {UserRole.customer, UserRole.vendor});
          when(() => mockSyncService.fetchRoleData())
              .thenAnswer((_) async => (UserRole.vendor, {UserRole.customer, UserRole.vendor}));
          return RoleBloc(
            storageService: mockStorageService,
            syncService: mockSyncService,
          );
        },
        act: (bloc) => bloc.add(const RoleRestored(UserRole.vendor)),
        expect: () => [
          const RoleLoaded(
            activeRole: UserRole.vendor,
            availableRoles: {UserRole.customer, UserRole.vendor},
          ),
        ],
      );

      blocTest<RoleBloc, RoleState>(
        'falls back to customer when restored role is not available',
        build: () {
          when(() => mockStorageService.getAvailableRoles())
              .thenAnswer((_) async => {UserRole.customer});
          when(() => mockSyncService.fetchRoleData())
              .thenAnswer((_) async => (UserRole.customer, {UserRole.customer}));
          return RoleBloc(
            storageService: mockStorageService,
            syncService: mockSyncService,
          );
        },
        act: (bloc) => bloc.add(const RoleRestored(UserRole.vendor)),
        expect: () => [
          const RoleLoaded(
            activeRole: UserRole.customer,
            availableRoles: {UserRole.customer},
          ),
        ],
      );
    });

    group('AvailableRolesRequested', () {
      blocTest<RoleBloc, RoleState>(
        'emits [RoleLoaded] with updated roles',
        build: () {
          when(() => mockSyncService.fetchRoleData())
              .thenAnswer((_) async => (UserRole.customer, {UserRole.customer, UserRole.vendor}));
          when(() => mockStorageService.saveActiveRole(any()))
              .thenAnswer((_) async => true);
          when(() => mockStorageService.saveAvailableRoles(any()))
              .thenAnswer((_) async => true);
          return RoleBloc(
            storageService: mockStorageService,
            syncService: mockSyncService,
          );
        },
        seed: () => const RoleLoaded(
          activeRole: UserRole.customer,
          availableRoles: {UserRole.customer},
        ),
        act: (bloc) => bloc.add(const AvailableRolesRequested()),
        expect: () => [
          const RoleLoaded(
            activeRole: UserRole.customer,
            availableRoles: {UserRole.customer, UserRole.vendor},
          ),
        ],
        verify: (_) {
          verify(() => mockSyncService.fetchRoleData()).called(1);
        },
      );
    });

    group('VendorRoleGranted', () {
      blocTest<RoleBloc, RoleState>(
        'emits [VendorRoleGranting, VendorRoleGranted] when vendor role is granted',
        build: () {
          when(() => mockSyncService.grantVendorRole(vendorProfileId: any(named: 'vendorProfileId')))
              .thenAnswer((_) async {});
          when(() => mockSyncService.fetchRoleData())
              .thenAnswer((_) async => (UserRole.vendor, {UserRole.customer, UserRole.vendor}));
          when(() => mockStorageService.saveAvailableRoles(any()))
              .thenAnswer((_) async => true);
          when(() => mockStorageService.saveActiveRole(any()))
              .thenAnswer((_) async => true);
          return RoleBloc(
            storageService: mockStorageService,
            syncService: mockSyncService,
          );
        },
        seed: () => const RoleLoaded(
          activeRole: UserRole.customer,
          availableRoles: {UserRole.customer},
        ),
        act: (bloc) => bloc.add(const VendorRoleGranted(
          vendorProfileId: 'test-vendor-id',
          switchToVendor: true,
        )),
        expect: () => [
          const VendorRoleGranting(),
          isA<VendorRoleGranted>()
              .having((s) => s.activeRole, 'activeRole', UserRole.vendor)
              .having((s) => s.availableRoles, 'availableRoles', {UserRole.customer, UserRole.vendor}),
        ],
        verify: (_) {
          verify(() => mockSyncService.grantVendorRole(vendorProfileId: 'test-vendor-id')).called(1);
          verify(() => mockStorageService.saveActiveRole(UserRole.vendor)).called(1);
        },
      );
    });

    group('currentRole getter', () {
      test('returns active role when state is RoleLoaded', () {
        final bloc = RoleBloc(
          storageService: mockStorageService,
          syncService: mockSyncService,
        );
        bloc.emit(const RoleLoaded(
          activeRole: UserRole.vendor,
          availableRoles: {UserRole.customer, UserRole.vendor},
        ));
        expect(bloc.currentRole, equals(UserRole.vendor));
        bloc.close();
      });

      test('returns null when state is not RoleLoaded', () {
        final bloc = RoleBloc(
          storageService: mockStorageService,
          syncService: mockSyncService,
        );
        expect(bloc.currentRole, isNull);
        bloc.close();
      });
    });

    group('availableRoles getter', () {
      test('returns available roles when state is RoleLoaded', () {
        final bloc = RoleBloc(
          storageService: mockStorageService,
          syncService: mockSyncService,
        );
        bloc.emit(const RoleLoaded(
          activeRole: UserRole.customer,
          availableRoles: {UserRole.customer, UserRole.vendor},
        ));
        expect(bloc.availableRoles, equals({UserRole.customer, UserRole.vendor}));
        bloc.close();
      });

      test('returns null when state is not RoleLoaded', () {
        final bloc = RoleBloc(
          storageService: mockStorageService,
          syncService: mockSyncService,
        );
        expect(bloc.availableRoles, isNull);
        bloc.close();
      });
    });
  });
}
