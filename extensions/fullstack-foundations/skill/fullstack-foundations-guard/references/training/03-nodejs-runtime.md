# 03. Node.js 运行时与服务端工程

## 学习目标

- 理解事件循环、线程池与进程资源边界；
- 识别同步 I/O、CPU 密集任务、大 JSON 和无界并发；
- 建立 route、service、repository 与 domain 的清晰边界；
- 设计统一错误模型、资源释放和优雅停机。

## 事件循环与资源公平

Node.js 用少量线程处理大量连接。同步文件、压缩、加密、复杂正则、巨大 JSON、无界循环或用户输入驱动的 `Promise.all` 都可能让一个请求占用过多时间或资源。“使用 async/await”不是非阻塞证明。

## 推荐分层

```text
transport / route
  → HTTP 解析、schema 校验、状态码、响应头
application service
  → 授权、业务用例、事务边界
repository / gateway
  → 参数化 SQL、查询 timeout、外部 API
observability
  → requestId、日志、指标、Trace
```

分层的目的不是制造目录，而是让权限、事务、业务规则和 I/O 可以独立测试与审查。

## 错误处理

- 输入错误、未认证、无权、资源不存在、版本冲突、限流和下游不可用使用稳定错误码；
- 内部错误不要直接返回 SQL、堆栈、路径或密钥；
- 在 `finally` 释放数据库连接、stream、timer 和 listener；
- 客户端取消后尽量取消下游工作；
- 进程收到终止信号后停止接收新请求，完成有限窗口内的在途请求，再关闭连接池和后台任务。

## 练习

构建一个最小 Node API：运行时校验、统一错误模型、request ID、timeout、取消、有界分页、结构化日志和优雅停机；用负载测试证明大输入或慢下游不会拖垮整个实例。
