class CpfValidator {
  static bool isValid(String? cpf) {
    if (cpf == null) return false;
    var numbers = cpf.replaceAll(RegExp(r'[^0-9]'), '');
    if (numbers.length != 11) return false;
    if (RegExp(r'^(\d)\1*$').hasMatch(numbers)) return false;

    List<int> digits = numbers.split('').map(int.parse).toList();

    int calcDv1 = 0;
    for (int i = 0; i < 9; i++) calcDv1 += digits[i] * (10 - i);
    int dv1 = 11 - (calcDv1 % 11);
    if (dv1 > 9) dv1 = 0;
    if (digits[9] != dv1) return false;

    int calcDv2 = 0;
    for (int i = 0; i < 10; i++) calcDv2 += digits[i] * (11 - i);
    int dv2 = 11 - (calcDv2 % 11);
    if (dv2 > 9) dv2 = 0;
    if (digits[10] != dv2) return false;

    return true;
  }
}
