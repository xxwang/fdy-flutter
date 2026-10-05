/// fdy 的网络工具（纯 Dart 入口）。
///
/// 不导出 `ColorExt` 与 `lib/src/l10n/` 下的多语言工具，所以**不会把 Flutter
/// 拖进依赖** —— 适合纯 Dart 的 data 层与命令行脚本，也让这部分代码能脱离
/// Flutter 单跑。
///
/// `lib/src/` 下的实现是内部细节，跨版本不承诺兼容。
library;

export "src/network/api_client.dart";
export "src/network/auth_interceptor.dart";
export "src/result.dart";
