import 'package:dio/dio.dart';

/// 认证 header 注入 + 401 钩子。
///
/// 这几个 header 是全应用统一的约定，所以放在拦截器里而不是各域客户端里 ——
/// 域客户端只管路径与解析，谁都不需要记得带 token。
///
/// header 名与认证方案都可覆盖：默认值对应「`Authorization: Bearer <token>`
/// + device-id + platform」这套约定，换后端只需在构造时传新名字。
///
/// ⚠️ header 名一律用连字符（默认值即如此）：nginx 反代默认
/// `underscores_in_headers off`，会静默丢弃带下划线的 header。
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    this.accessToken,
    this.deviceId,
    this.platform,
    this.authorizationHeader = "Authorization",
    this.deviceIdHeader = "device-id",
    this.platformHeader = "platform",
    this.scheme = "Bearer",
  });

  /// 认证方案前缀，发出的值是 `"$scheme $accessToken"`。
  final String scheme;

  final String authorizationHeader;

  final String deviceIdHeader;

  final String platformHeader;

  /// 登录后由 auth 层写入，登出清空；为空则不发该 header。
  String? accessToken;

  /// 装机标识，后端按它判定「同一账号单设备活跃」。
  String? deviceId;

  /// `ios` / `android`。
  String? platform;

  /// 收到 401 时触发，用来清掉已失效的登录态。
  ///
  /// ⚠️ Dio 不会自动重放原请求 —— 将来接刷新流程时，要在接线处自己用
  /// `dio.fetch(options)` 重发。
  void Function()? onUnauthorized;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (accessToken != null) {
      options.headers[authorizationHeader] = "$scheme $accessToken";
    }
    if (deviceId != null) {
      options.headers[deviceIdHeader] = deviceId;
    }
    if (platform != null) {
      options.headers[platformHeader] = platform;
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      onUnauthorized?.call();
    }
    handler.next(err);
  }
}
