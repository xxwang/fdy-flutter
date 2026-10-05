## 0.0.1

* `ColorExt`：`Color.fromHex("#RRGGBB")` 与随机颜色。
* `Result` / `Ok` / `Error`：用返回值表达成功/失败，替代跨层抛异常。
* `ApiClient`：接口客户端基类，封 `get` / `post` / `put` / `patch` /
  `upload` / `download` / `downloadBytes` 七个动词，统一折 `Result` 并把
  异常收敛在一处（含 `ApiException`）。
* `AuthInterceptor`：认证 header 注入 + 401 钩子，header 名与 scheme 可覆盖。
* `MapLocalizations` / `MapLocalizationsDelegate`：手写 Map 文案表 + delegate
  的多语言基类，零 codegen，缺 key 显示 `[KEY]`。
* `localeFallbackResolver`：`supportedLocales` 都匹配不到时退到指定兜底语言的
  `localeResolutionCallback`（内置算法只会退到 `supportedLocales.first`）。
