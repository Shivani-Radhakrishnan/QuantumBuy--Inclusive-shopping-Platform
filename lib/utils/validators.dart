/// Form field validators shared by the login, registration, profile and
/// checkout forms. Each returns an error message, or null when valid.
library;

String? requiredField(String? value, String what) =>
    (value == null || value.trim().isEmpty) ? 'Please enter $what' : null;

final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

String? validateEmail(String? value) {
  final missing = requiredField(value, 'an email');
  if (missing != null) return missing;
  return _emailPattern.hasMatch(value!.trim()) ? null : 'Please enter a valid email';
}

String? validateNewPassword(String? value) {
  if (value == null || value.isEmpty) return 'Please enter a password';
  if (value.length < 6) return 'Password must be at least 6 characters long';
  return null;
}

/// Indian mobile numbers: 10 digits, optionally with +91 / spaces / dashes.
String? validatePhone(String? value) {
  final missing = requiredField(value, 'a phone number');
  if (missing != null) return missing;
  var digits = value!.replaceAll(RegExp(r'[\s-]'), '');
  if (digits.startsWith('+91')) digits = digits.substring(3);
  return RegExp(r'^[6-9]\d{9}$').hasMatch(digits) ? null : 'Please enter a valid 10-digit mobile number';
}

/// UPI ids look like name@bank.
String? validateUpiId(String? value) {
  final missing = requiredField(value, 'your UPI ID');
  if (missing != null) return missing;
  return RegExp(r'^[\w.\-]{2,256}@[a-zA-Z]{2,64}$').hasMatch(value!.trim())
      ? null
      : 'Enter a UPI ID like name@bank';
}

/// Card numbers: 12-19 digits that pass the Luhn checksum.
String? validateCardNumber(String? value) {
  final missing = requiredField(value, 'the card number');
  if (missing != null) return missing;
  final digits = value!.replaceAll(RegExp(r'[\s-]'), '');
  if (!RegExp(r'^\d{12,19}$').hasMatch(digits) || !luhnValid(digits)) {
    return 'Please enter a valid card number';
  }
  return null;
}

bool luhnValid(String digits) {
  var sum = 0;
  var doubleIt = false;
  for (var i = digits.length - 1; i >= 0; i--) {
    var d = digits.codeUnitAt(i) - 48;
    if (doubleIt) {
      d *= 2;
      if (d > 9) d -= 9;
    }
    sum += d;
    doubleIt = !doubleIt;
  }
  return sum % 10 == 0;
}

/// Expiry as MM/YY, not in the past relative to [now].
String? validateExpiry(String? value, {DateTime? now}) {
  final missing = requiredField(value, 'the expiry date');
  if (missing != null) return missing;
  final match = RegExp(r'^(\d{2})\s*/\s*(\d{2})$').firstMatch(value!.trim());
  if (match == null) return 'Use the format MM/YY';
  final month = int.parse(match.group(1)!);
  final year = 2000 + int.parse(match.group(2)!);
  if (month < 1 || month > 12) return 'Use the format MM/YY';
  final today = now ?? DateTime.now();
  // A card is valid until the end of its expiry month.
  if (!DateTime(year, month + 1).isAfter(DateTime(today.year, today.month))) {
    return 'This card has expired';
  }
  return null;
}

String? validateCvv(String? value) {
  final missing = requiredField(value, 'the CVV');
  if (missing != null) return missing;
  return RegExp(r'^\d{3,4}$').hasMatch(value!.trim()) ? null : 'CVV is 3 or 4 digits';
}
