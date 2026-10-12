import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopping_app/user_model.dart';

Future<UserModel> freshModel([Map<String, Object> stored = const {}]) async {
  SharedPreferences.setMockInitialValues(stored);
  final model = UserModel();
  await Future<void>.delayed(const Duration(milliseconds: 50)); // let _loadUserData finish
  return model;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('the password itself is never stored', () async {
    final model = await freshModel();
    model.register('asha', 'asha@example.com', 'correct horse');
    await Future<void>.delayed(const Duration(milliseconds: 50));
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('password'), isNull);
    expect(prefs.getString('passwordHash'), isNotEmpty);
    expect(prefs.getString('passwordHash'), isNot(contains('correct horse')));
    expect(prefs.getString('passwordSalt'), isNotEmpty);
  });

  test('right password logs in, wrong password does not', () async {
    final model = await freshModel();
    model.register('asha', 'asha@example.com', 'correct horse');
    expect(model.authenticate('asha', 'correct horse'), isTrue);
    expect(model.authenticate('asha@example.com', 'correct horse'), isTrue);
    expect(model.authenticate('asha', 'wrong'), isFalse);
    expect(model.authenticate('someone', 'correct horse'), isFalse);
  });

  test('a plain-text password from an older version is converted and deleted', () async {
    final model = await freshModel({'userName': 'asha', 'email': 'a@example.com', 'password': 'old secret'});
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('password'), isNull);
    expect(model.authenticate('asha', 'old secret'), isTrue);
  });

  test('two users with the same password get different hashes', () async {
    final a = await freshModel();
    a.register('a', 'a@example.com', 'same');
    await Future<void>.delayed(const Duration(milliseconds: 50));
    final hashA = (await SharedPreferences.getInstance()).getString('passwordHash');
    final b = await freshModel();
    b.register('b', 'b@example.com', 'same');
    await Future<void>.delayed(const Duration(milliseconds: 50));
    final hashB = (await SharedPreferences.getInstance()).getString('passwordHash');
    expect(hashA, isNot(equals(hashB)));
  });
}
