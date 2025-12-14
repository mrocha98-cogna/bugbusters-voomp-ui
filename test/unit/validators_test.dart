import 'package:flutter_test/flutter_test.dart';
import 'package:voomp_sellers_rebranding/src/core/validators/cpf_validator.dart';

void main() {
  group('CpfValidator', () {
    test('Deve retornar false para CPF nulo ou vazio', () {
      expect(CpfValidator.isValid(null), isFalse);
      expect(CpfValidator.isValid(''), isFalse);
    });

    test('Deve retornar false para CPF com tamanho incorreto', () {
      expect(CpfValidator.isValid('123'), isFalse);
      expect(CpfValidator.isValid('123456789012345'), isFalse);
    });

    test('Deve retornar false para CPFs com todos os dígitos iguais', () {
      expect(CpfValidator.isValid('111.111.111-11'), isFalse);
      expect(CpfValidator.isValid('00000000000'), isFalse);
    });

    test('Deve retornar true para um CPF válido conhecido', () {
      // Obs: Use um gerador de CPF válido para testes ou um conhecido
      // Exemplo de CPF válido fictício matematicamente
      expect(CpfValidator.isValid('52998224725'), isTrue);
    });

    test('Deve retornar false para um CPF com dígitos verificadores inválidos', () {
      expect(CpfValidator.isValid('52998224700'), isFalse);
    });

    test('Deve validar corretamente mesmo com máscara', () {
      expect(CpfValidator.isValid('529.982.247-25'), isTrue);
    });
  });
}
