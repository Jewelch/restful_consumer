import 'package:flutter_test/flutter_test.dart';
import 'package:restful_consumer/src/utils/debugging_printer.dart';

void main() {
  group('Debugger', () {
    test('black should not throw', () {
      expect(() => Debugger.black('Test message'), returnsNormally);
    });

    test('yellow should not throw', () {
      expect(() => Debugger.yellow('Test message'), returnsNormally);
    });

    test('orange should not throw', () {
      expect(() => Debugger.orange('Test message'), returnsNormally);
    });

    test('red should not throw', () {
      expect(() => Debugger.red('Test message'), returnsNormally);
    });

    test('green should not throw', () {
      expect(() => Debugger.green('Test message'), returnsNormally);
    });

    test('blue should not throw', () {
      expect(() => Debugger.blue('Test message'), returnsNormally);
    });

    test('magenta should not throw', () {
      expect(() => Debugger.magenta('Test message'), returnsNormally);
    });

    test('cyan should not throw', () {
      expect(() => Debugger.cyan('Test message'), returnsNormally);
    });

    test('white should not throw', () {
      expect(() => Debugger.white('Test message'), returnsNormally);
    });

    test('all methods should handle different types', () {
      expect(() => Debugger.black(123), returnsNormally);
      expect(() => Debugger.yellow(true), returnsNormally);
      expect(() => Debugger.orange(['list']), returnsNormally);
      expect(() => Debugger.red({'key': 'value'}), returnsNormally);
      expect(() => Debugger.green(null), returnsNormally);
      expect(() => Debugger.blue(42.5), returnsNormally);
      expect(() => Debugger.magenta(Exception('test')), returnsNormally);
      expect(() => Debugger.cyan(StackTrace.current), returnsNormally);
      expect(() => Debugger.white(Object()), returnsNormally);
    });

    test('all methods should handle empty strings', () {
      expect(() => Debugger.black(''), returnsNormally);
      expect(() => Debugger.yellow(''), returnsNormally);
      expect(() => Debugger.orange(''), returnsNormally);
      expect(() => Debugger.red(''), returnsNormally);
      expect(() => Debugger.green(''), returnsNormally);
      expect(() => Debugger.blue(''), returnsNormally);
      expect(() => Debugger.magenta(''), returnsNormally);
      expect(() => Debugger.cyan(''), returnsNormally);
      expect(() => Debugger.white(''), returnsNormally);
    });

    test('all methods should handle multiline strings', () {
      const multiline = 'Line 1\nLine 2\nLine 3';
      expect(() => Debugger.black(multiline), returnsNormally);
      expect(() => Debugger.yellow(multiline), returnsNormally);
      expect(() => Debugger.orange(multiline), returnsNormally);
      expect(() => Debugger.red(multiline), returnsNormally);
      expect(() => Debugger.green(multiline), returnsNormally);
      expect(() => Debugger.blue(multiline), returnsNormally);
      expect(() => Debugger.magenta(multiline), returnsNormally);
      expect(() => Debugger.cyan(multiline), returnsNormally);
      expect(() => Debugger.white(multiline), returnsNormally);
    });
  });
}
