/// fdy —— Flutter 开发工具集（全量入口）。
///
/// 只想用网络工具、且要让代码保持**不依赖 Flutter**（纯 Dart 的 data 层、
/// 命令行脚本），改用 `package:fdy/fdy_network.dart` —— 那个入口不导出
/// 依赖 Flutter 的 `ColorExt` 以及 `lib/src/l10n/` 下的多语言工具。
///
/// `lib/src/` 下的实现是内部细节，跨版本不承诺兼容。
library;

export "src/color_ext.dart";
export "src/l10n/locale_resolution.dart";
export "src/l10n/map_localizations.dart";
export "src/network/api_client.dart";
export "src/network/auth_interceptor.dart";
export "src/result.dart";
