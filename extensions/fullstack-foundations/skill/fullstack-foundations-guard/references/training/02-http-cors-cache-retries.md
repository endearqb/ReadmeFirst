# 02. HTTP、CORS、Cookie、缓存、超时与重试

## 学习目标

- 理解 HTTP 方法、状态码、幂等性和错误模型；
- 区分 CORS、认证、授权和 CSRF；
- 正确配置 Cookie 与浏览器缓存；
- 为客户端、服务端、数据库和下游建立 timeout 与取消；
- 只对适合的请求实施有限重试。

## CORS 不是鉴权

Origin 由协议、主机和端口组成。CORS 只是浏览器读取跨源响应的约束，不阻止非浏览器客户端调用 API，也不证明用户有权限。带凭证请求不能与通配符 Origin 组合；动态 Origin 还应返回 `Vary: Origin`。

Cookie 会话通常需要：

```text
HttpOnly
Secure
SameSite=Lax/Strict/None（按场景）
Path 和尽量窄的 Domain
明确过期、轮换、撤销与 CSRF 防护
```

## 缓存语义

- `no-cache`：允许存储，但复用前必须重新验证；
- `no-store`：不应存储；
- 个性化响应应使用 `private` 或 `no-store`，不能进入共享 CDN；
- 静态哈希资源可使用长缓存和 `immutable`；
- ETag/Last-Modified 用于条件请求，304 不是业务错误。

## 超时、取消与重试

每次网络调用都要有总预算，并尽量传播调用者取消信号。只有临时错误且方法安全或具备幂等保护时才有限重试；使用指数退避、抖动和 `Retry-After`，避免浏览器、网关、服务端和 SDK 多层重试放大流量。

非幂等 POST 超时后，服务端可能已经成功。正确做法是幂等键、状态查询或可证明未执行，而不是盲目重发。

## 练习

为一个 Cookie 会话 API 设计 CORS、CSRF、缓存、timeout 和 retry 策略，并用浏览器自动化测试：允许来源成功、非允许来源失败、个性化响应不被共享缓存、重复 POST 不产生重复副作用。
