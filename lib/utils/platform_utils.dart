import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

/// Web 安全的平台检测工具，替代直接使用 dart:io Platform
class PlatformUtils {
  static bool get isWeb => kIsWeb;
  static bool get isWindows => !kIsWeb && Platform.isWindows;
  static bool get isMacOS => !kIsWeb && Platform.isMacOS;
  static bool get isLinux => !kIsWeb && Platform.isLinux;
  static bool get isAndroid => !kIsWeb && Platform.isAndroid;
  static bool get isIOS => !kIsWeb && Platform.isIOS;
  static bool get isDesktop => isWindows || isMacOS || isLinux;
  static bool get isMobile => isAndroid || isIOS;
  static String get operatingSystemVersion =>
      kIsWeb ? 'web' : Platform.operatingSystemVersion;
  static Map<String, String> get environment =>
      kIsWeb ? {} : Platform.environment;
  static String get resolvedExecutable =>
      kIsWeb ? '' : Platform.resolvedExecutable;
}
