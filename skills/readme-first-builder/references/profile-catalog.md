# README First Capability Profile Catalog

> 更新于:2026-08-02

Builder 使用本目录做**候选发现**，不是自动安装清单。安装前必须确认技术栈证据、能力包文件可用和目标项目策略。

| Profile | 风险领域 | Canonical 路径 | 默认行为 |
|---|---|---|---|
| `fullstack-foundations` | database、transaction、concurrency、HTTP、缓存、运行时、权限、安全、迁移、外部副作用 | `extensions/fullstack-foundations/` | 只建议；明确选择后安装 |

## Full-stack Foundations 候选证据

强证据（通常至少命中两类）：

- Node.js / TypeScript 服务端入口或 API 路由；
- PostgreSQL / SQL / ORM schema 和 migrations；
- 服务端 auth、tenant、session、Cookie 或 CORS 配置；
- 缓存、队列、外部 API、后台任务；
- 集成、并发、迁移或负载测试。

弱证据（不能单独触发安装）：

- 只有前端 `package.json`；
- 只有浏览器 fetch 调用；
- 文档中提到“全栈”但代码不存在；
- 仓库包含生成文件或示例 SQL，却不在生产路径使用。

## 能力包不可用时

如果 Builder 只以独立 Skill 安装，无法访问 canonical `extensions/`：

1. 输出候选 Profile、证据和 canonical 路径；
2. 不创建指向不存在 Skill 的 `.ai/profiles/`；
3. 不从网络拼装或编造能力包内容；
4. 用户提供能力包或在完整 ReadmeFirst 仓库运行后再安装。
