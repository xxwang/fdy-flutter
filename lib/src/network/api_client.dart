import 'package:dio/dio.dart';

import '../result.dart';

/// 接口客户端基类：持 [Dio]、把响应折成 [Result]、把异常收敛在一处。
///
/// 各域的接口组分在各自的子类里（惯例叫 `<域>_api_client.dart`），只写
/// 「路径 + 解析」。下面的动词就是子类的全部工具箱：新增接口 = 挑一个动词 +
/// 写 `parse`，子类不需要自己去碰 Dio —— [_dio] 是私有的，子类拿不到。
///
/// 将来要加的信封解包、业务码判断、非 2xx 翻译，全部落在 [_request] 这一处，
/// 各子类不受影响。
abstract class ApiClient {
  ApiClient(this._dio);

  final Dio _dio;

  /// GET。
  ///
  /// `path` 以 http(s) 开头时是绝对地址，会绕过 [BaseOptions.baseUrl]。
  Future<Result<T>> get<T>(
    String path, {
    required T Function(dynamic data) parse,
    Map<String, dynamic>? query,
    Map<String, dynamic>? headers,
    CancelToken? cancelToken,
  }) => _request(
    () => _dio.get<dynamic>(
      path,
      queryParameters: query,
      cancelToken: cancelToken,
      options: _options(headers: headers),
    ),
    parse,
  );

  /// POST。`body` 传 [Map] 由 Dio 编成 JSON，传 [FormData] 则走 multipart。
  Future<Result<T>> post<T>(
    String path, {
    required T Function(dynamic data) parse,
    Object? body,
    Map<String, dynamic>? query,
    Map<String, dynamic>? headers,
    CancelToken? cancelToken,
  }) => _request(
    () => _dio.post<dynamic>(
      path,
      data: body,
      queryParameters: query,
      cancelToken: cancelToken,
      options: _options(headers: headers),
    ),
    parse,
  );

  /// PUT：整体替换，`body` 同 [post]。
  Future<Result<T>> put<T>(
    String path, {
    required T Function(dynamic data) parse,
    Object? body,
    Map<String, dynamic>? query,
    Map<String, dynamic>? headers,
    CancelToken? cancelToken,
  }) => _request(
    () => _dio.put<dynamic>(
      path,
      data: body,
      queryParameters: query,
      cancelToken: cancelToken,
      options: _options(headers: headers),
    ),
    parse,
  );

  /// PATCH：局部更新，`body` 同 [post]。
  Future<Result<T>> patch<T>(
    String path, {
    required T Function(dynamic data) parse,
    Object? body,
    Map<String, dynamic>? query,
    Map<String, dynamic>? headers,
    CancelToken? cancelToken,
  }) => _request(
    () => _dio.patch<dynamic>(
      path,
      data: body,
      queryParameters: query,
      cancelToken: cancelToken,
      options: _options(headers: headers),
    ),
    parse,
  );

  /// 上传：本质是带 [FormData] 的 POST，单独给个名字让调用点自明。
  ///
  /// ```dart
  /// api.upload<String>(
  ///   "/me/avatar",
  ///   form: FormData.fromMap({
  ///     "file": await MultipartFile.fromFile(filePath),
  ///   }),
  ///   parse: (dynamic data) => data["url"] as String,
  ///   onSendProgress: (int sent, int total) => print("$sent/$total"),
  /// );
  /// ```
  Future<Result<T>> upload<T>(
    String path, {
    required FormData form,
    required T Function(dynamic data) parse,
    Map<String, dynamic>? query,
    Map<String, dynamic>? headers,
    ProgressCallback? onSendProgress,
    CancelToken? cancelToken,
  }) => _request(
    () => _dio.post<dynamic>(
      path,
      data: form,
      queryParameters: query,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      options: _options(headers: headers),
    ),
    parse,
  );

  /// 下载到 [savePath]，成功后返回该路径本身。
  ///
  /// ⚠️ 只写文件、不建目录：父目录要先存在。
  /// [deleteOnError] 保持默认 —— 失败时清掉写了一半的残档，否则会留下
  /// 一个「看起来像正常文件」的坏文件。
  Future<Result<String>> download(
    String path, {
    required String savePath,
    Map<String, dynamic>? query,
    Map<String, dynamic>? headers,
    ProgressCallback? onReceiveProgress,
    bool deleteOnError = true,
    CancelToken? cancelToken,
  }) => _request(
    () => _dio.download(
      path,
      savePath,
      queryParameters: query,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
      deleteOnError: deleteOnError,
      options: _options(headers: headers),
    ),
    (dynamic _) => savePath,
  );

  /// 下载到内存。适合小文件或要在内存里直接解析的响应；
  /// 大文件（导出报表之类）走 [download] 落盘，别整份读进内存。
  Future<Result<List<int>>> downloadBytes(
    String path, {
    Map<String, dynamic>? query,
    Map<String, dynamic>? headers,
    ProgressCallback? onReceiveProgress,
    CancelToken? cancelToken,
  }) => _request(
    () => _dio.get<dynamic>(
      path,
      queryParameters: query,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
      options: Options(responseType: ResponseType.bytes, headers: headers),
    ),
    (dynamic data) => data as List<int>,
  );

  /// 所有动词的唯一出口：发请求、折 [Result]、收敛异常。
  ///
  /// 要加信封解包 / 业务码判断，就加在这里 —— 七种动词自动一起生效。
  Future<Result<T>> _request<T>(
    Future<Response<dynamic>> Function() send,
    T Function(dynamic data) parse,
  ) async {
    try {
      final Response<dynamic> response = await send();
      return Result.ok(parse(response.data));
    } on Exception catch (error) {
      // DioException（网络 / 超时 / 非 2xx）都落这一支。
      return Result.error(error);
    } catch (error) {
      // parse 里 `data as List` 失败抛的是 TypeError（dart:core.Error，不是
      // Exception），而 Result.error 只收 Exception —— 少了这一兜，异常会
      // 绕过 Result 契约直接穿到 repository。
      return Result.error(ApiException("响应处理失败：$error"));
    }
  }

  Options? _options({Map<String, dynamic>? headers}) =>
      headers == null ? null : Options(headers: headers);
}

/// [Result.error] 只收 [Exception]，用它把非 Exception 的失败包进来。
class ApiException implements Exception {
  ApiException(this.message);

  final String message;

  @override
  String toString() => "ApiException: $message";
}
