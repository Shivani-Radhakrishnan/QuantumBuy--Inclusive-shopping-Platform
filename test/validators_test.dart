import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_app/utils/validators.dart';

void main() {
  test('required fields', () {
    expect(requiredField('', 'a name'), 'Please enter a name');
    expect(requiredField('   ', 'a name'), isNotNull);
    expect(requiredField('x', 'a name'), isNull);
  });

  test('email', () {
    expect(validateEmail('asha@example.com'), isNull);
    expect(validateEmail('asha@example'), isNotNull);
    expect(validateEmail('a b@example.com'), isNotNull);
  });

  test('phone', () {
    expect(validatePhone('9876543210'), isNull);
    expect(validatePhone('+91 98765-43210'), isNull);
    expect(validatePhone('12345'), isNotNull);
    expect(validatePhone('1234567890'), isNotNull);
  });

  test('UPI id', () {
    expect(validateUpiId('asha@okbank'), isNull);
    expect(validateUpiId('asha'), isNotNull);
    expect(validateUpiId('asha@1'), isNotNull);
  });

  test('card number uses the Luhn checksum', () {
    expect(validateCardNumber('4111 1111 1111 1111'), isNull); // standard test number
    expect(validateCardNumber('4111 1111 1111 1112'), isNotNull);
    expect(validateCardNumber('1234'), isNotNull);
    expect(luhnValid('79927398713'), isTrue);
  });

  test('expiry', () {
    final now = DateTime(2026, 10, 12);
    expect(validateExpiry('10/26', now: now), isNull, reason: 'valid until the end of the month');
    expect(validateExpiry('09/26', now: now), 'This card has expired');
    expect(validateExpiry('01/30', now: now), isNull);
    expect(validateExpiry('13/30', now: now), isNotNull);
    expect(validateExpiry('1030', now: now), isNotNull);
  });

  test('CVV', () {
    expect(validateCvv('123'), isNull);
    expect(validateCvv('1234'), isNull);
    expect(validateCvv('12'), isNotNull);
    expect(validateCvv('12a'), isNotNull);
  });

  test('new password', () {
    expect(validateNewPassword('12345'), isNotNull);
    expect(validateNewPassword('123456'), isNull);
  });
}
