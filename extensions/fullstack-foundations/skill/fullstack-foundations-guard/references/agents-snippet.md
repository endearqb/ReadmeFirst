# 项目规则集成片段

## README First v2.2 项目

优先安装能力包的 `PROFILE.md`，不要把下面所有门禁直接塞入根 `AGENTS.md`。根规则只需保留短路由：

```markdown
## Full-stack foundations route

当任务命中 `.ai/profiles/fullstack-foundations.md` 的触发条件时：

1. 读取该 Profile 的风险领域、业务不变量、阻断条件和最低证据；
2. 使用 `skills/fullstack-foundations-guard/SKILL.md`；
3. 只加载当前任务需要的 references；
4. L2 changes 记录风险领域、使用的 Profile / Skill 和风险对应证据；
5. Scanner 命中只作为候选线索，不得直接认定为缺陷。
```

## 未采用 README First 的项目

可以把下面内容加入仓库 Agent 规则文件，并根据项目命令和技术栈删减：

```markdown
## Full-stack foundations gate

当任务涉及 Node.js 服务、API、SQL/ORM、schema/迁移、事务并发、幂等重试、缓存队列、CORS/Cookie/session/token、权限、敏感数据、资源上限或外部副作用时，使用 `fullstack-foundations-guard`。

执行要求：

1. 实现前写出请求链路、业务不变量、信任边界、资源上限和失败路径。
2. 审查以真实 diff、代码、配置、查询计划、测试和运行结果为证据。
3. SQL/索引建议说明查询形状、数据规模、代价和验证方法。
4. 写操作检查并发、重复、超时未知结果、事务边界和幂等。
5. 权限覆盖主体、租户、资源、动作和字段，不信任客户端身份参数。
6. 关键接口有输入、分页、并发、超时、连接、重试和响应大小上限。
7. 不记录或暴露密码、会话标识、密钥、Cookie 和不必要个人数据。
8. 数据库、权限、事务、缓存或协议修改补相应集成/并发/迁移测试。
9. Scanner 命中只是候选，不是确认 finding。
10. 已确认 P0/P1、破坏性迁移无恢复方案、关键副作用无幂等、无界资源风险未处理时，不宣告完成。
```

## 项目命令补充模板

```markdown
### Project verification commands

- Install: `<project install command>`
- Format: `<format command>`
- Lint: `<lint command>`
- Typecheck: `<typecheck command>`
- Unit tests: `<unit test command>`
- Integration / concurrency tests: `<integration command>`
- Build: `<build command>`
- Database migration check: `<migration command>`
- Local service dependencies: `<docker compose or dev command>`
```
