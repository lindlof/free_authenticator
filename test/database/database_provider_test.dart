import 'package:flutter_test/flutter_test.dart';
import 'package:free_authenticator/database/database_entry.dart';
import 'package:free_authenticator/database/database_provider.dart';
import 'package:free_authenticator/keychain/keychain_provider.dart';
import 'package:free_authenticator/model/api/entry.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqlite_api.dart';

class MockDatabase extends Mock implements Database {}
class MockKeychainProvider extends Mock implements KeychainProvider {}
class MockDeps extends Mock implements DatabaseProviderDeps {}

void main() {

  testWidgets('Provides database', (WidgetTester tester) async {
    final database = MockDatabase();
    final keychain = MockKeychainProvider();
    final dependencies = MockDeps();

    when(dependencies.openDatabase(any, version: anyNamed("version"), onCreate: anyNamed("onCreate")))
      .thenAnswer((invocation) async {
        return database;
      });

    final provider = DatabaseProvider(keychain, dependencies: dependencies);
    expect(await provider.database, equals(database));
  });

  testWidgets('Caches database', (WidgetTester tester) async {
    final database = MockDatabase();
    final keychain = MockKeychainProvider();
    final dependencies = MockDeps();

    when(dependencies.openDatabase(any, version: anyNamed("version"), onCreate: anyNamed("onCreate")))
      .thenAnswer((invocation) async {
        return database;
      });

    final provider = DatabaseProvider(keychain, dependencies: dependencies);
    expect(await provider.database, equals(database));
    expect(await provider.database, equals(database));
    verify(dependencies.openDatabase(any, version: anyNamed("version"), onCreate: anyNamed("onCreate"))).called(1);
  });

  testWidgets('Database creation', (WidgetTester tester) async {
    final database = MockDatabase();
    final keychain = MockKeychainProvider();
    final dependencies = MockDeps();

    when(dependencies.openDatabase(any, version: anyNamed("version"), onCreate: anyNamed("onCreate")))
      .thenAnswer((invocation) async {
        Function(Database, int) onCreate = invocation.namedArguments[Symbol("onCreate")];
        await onCreate(database, 1);
        return database;
      });

    final provider = DatabaseProvider(keychain, dependencies: dependencies);
    await provider.database;

    verify(database.execute(argThat(contains('CREATE TABLE ${DatabaseEntry.table}'))));
    verify(database.insert(DatabaseEntry.table, argThat(containsPair(DatabaseEntry.columnId, "${VaultEntry.rootId}"))));
  });
}
