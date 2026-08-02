# 01. JavaScript、TypeScript 与浏览器基础

## 学习目标

- 区分浏览器与 Node.js 运行时；
- 理解同步代码、微任务、异步 I/O 和 Promise；
- 在 HTTP、JSON、环境变量等边界使用 `unknown` 和运行时校验；
- 正确传播、分类和记录错误；
- 使用 DevTools 的 Network、Application、Performance 和 Console 面板。

## 核心机制

`async/await` 让异步代码易读，但不会自动限制并发，也不会让 CPU 密集代码变成非阻塞代码。以下代码会一次启动全部任务：

```ts
await Promise.all(items.map(processItem));
```

当 `items` 来自用户输入或数据库且没有上限时，它可能耗尽连接池、内存或第三方 API 配额。

TypeScript 只在编译期工作。HTTP JSON 在运行时仍可能不符合声明：

```ts
function parseJson(text: string): unknown {
  return JSON.parse(text);
}

const raw = parseJson(input);
const value = schema.parse(raw);
```

不要用 `as User` 把未知数据伪装成已验证数据。

## 浏览器调试清单

1. 请求 URL、方法、Origin、Cookie、Authorization；
2. 是否发生 OPTIONS 预检；
3. 请求是否取消、超时、重定向或重复；
4. 状态码、响应头与缓存命中；
5. Timing 中 DNS、连接、TLS、TTFB 和下载时间；
6. Application 面板是否保存了不该持久化的 Token 或敏感用户数据。

## 常见反模式

- `catch {}` 吞掉错误；
- 组件卸载后旧响应覆盖新结果；
- 用全局可变对象保存当前用户或租户；
- 客户端承担唯一权限判断、金额或库存计算；
- 对未知长度数组直接 `Promise.all`。

## 练习

实现一个搜索页面：输入变化后取消旧请求；对返回 JSON 做运行时校验；区分空结果、输入错误、未认证、超时和服务器错误；连续输入 20 次时只展示最后一次查询结果。
