/// 用返回值表达成功/失败，替代跨层抛异常。
///
/// [Result] 只可能是带值的 [Ok] 或带失败的 [Error]，
/// 调用方必须显式 switch 解包，不会漏掉错误分支。
///
/// 类型名与工厂名照搬 Flutter 官方 Compass 示例的 utils/result.dart：
/// https://github.com/flutter/samples/blob/main/compass_app/app/lib/utils/result.dart
/// 已知代价：`Error` 与 dart:core.Error 同名。本文件不引用核心 Error，
/// 但引用本文件的代码若写 `on Error catch` 会命中这里的泛型类 ——
/// 真需要核心那个时写 `dart:core.Error` 限定即可。
sealed class Result<T> {
  const Result();

  /// 成功结果，携带 [value]。
  const factory Result.ok(T value) = Ok._;

  /// 失败结果，携带 [error]。
  const factory Result.error(Exception error) = Error._;
}

/// 成功时的结果。
final class Ok<T> extends Result<T> {
  const Ok._(this.value);

  final T value;

  @override
  String toString() => "Result<$T>.ok($value)";
}

/// 失败时的结果。
final class Error<T> extends Result<T> {
  const Error._(this.error);

  final Exception error;

  @override
  String toString() => "Result<$T>.error($error)";
}
