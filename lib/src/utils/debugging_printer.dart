import 'dart:developer' show log;

abstract final class Debugger {
  static const String _prefix = '\x1B[';
  static const String _suffix = '${_prefix}0m';

  static void black(dynamic text) => log('${_prefix}30m$text$_suffix');

  static void yellow(dynamic text) => log('${_prefix}33;1m\x1B[5m$text$_suffix');

  static void orange(dynamic text) => log('${_prefix}33m$text$_suffix');

  static void red(dynamic text) => log('${_prefix}31m$text$_suffix');

  static void green(dynamic text) => log('${_prefix}32m$text$_suffix');

  static void blue(dynamic text) => log('${_prefix}34m$text$_suffix');

  static void magenta(dynamic text) => log('${_prefix}35;1m\x1B[5m$text$_suffix');

  static void cyan(dynamic text) => log('${_prefix}36m$text$_suffix');

  static void white(dynamic text) => log('${_prefix}37m$text$_suffix');
}
