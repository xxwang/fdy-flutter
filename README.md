# fdy-flutter

Flutter 开发工具集。

## 安装

```yaml
dependencies:
  fdy:
    path: ../fdy-flutter
```

要走远端分支时换成：

```yaml
  fdy:
    git:
      url: https://github.com/xxwang/fdy-flutter.git
      ref: develop
```

## 内容

| 入口 | 说明 |
|---|---|
| `ColorExt` | `ColorExt.fromHex("#RRGGBB")`、`ColorExt.random` |
| `Result` / `Ok` / `Error` | 用返回值表达成功/失败，调用方必须 switch 解包 |
| `ApiClient` | 接口客户端基类：`get` / `post` / `put` / `patch` / `upload` / `download` / `downloadBytes`，统一折 `Result`、统一收敛异常 |
| `AuthInterceptor` | 认证 header 注入 + 401 钩子，header 名与 scheme 可覆盖 |
| `MapLocalizations` | 手写 Map 文案表 + delegate 的多语言基类，零 codegen |
| `localeFallbackResolver` | `supportedLocales` 都匹配不上时退到指定兜底语言的解析回调（内置算法只会退到 `supportedLocales.first`） |

两个入口：

| 入口 | 导出 | 什么时候用 |
|---|---|---|
| `package:fdy/fdy.dart` | 全部 | 一般情况 |
| `package:fdy/fdy_network.dart` | `Result` / `ApiClient` / `AuthInterceptor` | 纯 Dart 代码（data 层、命令行脚本）—— 这个入口**不拖入 Flutter** |

`lib/src/` 是内部实现，不承诺跨版本兼容。各入口的用法见对应文件的 doc comment。
