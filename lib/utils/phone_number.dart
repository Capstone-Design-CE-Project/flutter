/// 백엔드 core/phone.py와 동일한 국내 전화번호 정규화 규칙.
String? normalizePhoneNumber(String? value) {
  if (value == null || value.isEmpty) return null;
  var digits = value.replaceAll(RegExp(r'\D'), '');
  if (digits.isEmpty) return null;

  if (digits.startsWith('00')) digits = digits.substring(2);
  if (digits.startsWith('82')) digits = '0${digits.substring(2)}';
  if (!digits.startsWith('0') && digits.length >= 9 && digits.length <= 10) {
    digits = '0$digits';
  }
  if (digits.length < 9 || digits.length > 11) return null;
  return digits;
}
