# README First Risk Profile Template

> 更新于:2026-08-02

复制本模板到能力包 `PROFILE.md`，安装到目标项目时再复制到 `.ai/profiles/<profile-id>.md`。删除所有占位说明，只保留基于真实能力包和目标项目事实的内容。

```md
---
profile_id: <lowercase-kebab-case>
profile_version: "0.1.0"
status: optional
skill_name: <skill-directory-name>
canonical_skill_path: extensions/<pack>/skill/<skill-name>
install_skill_path: skills/<skill-name>
risk_domains:
  - <standard-risk-domain>
---

# <Profile Display Name>

## 目的
（一段话：本 Profile 防止什么失败，不负责什么。）

## 触发条件

命中任一时加载：

- <可从任务、路径、依赖或配置判断的条件>；

不要只写“相关任务”或“复杂修改”。

## 不触发条件

- <明确排除的低风险或不相关任务>；

## 必读上下文

- <目标项目的目录、配置、schema、测试或运行证据>；

只列项目上下文类型，不硬编码不存在的路径。

## 业务不变量与信任边界

1. <必须长期成立的事实>；
2. <外部输入、身份、租户、权限或资源边界>。

## 执行路由

- Review：<检查重点>；
- Implementation：<实现前必须建立的事实>；
- Design：<方案必须覆盖的路径>；
- Mentor：<需要加载的培训材料>。

对应 Skill：`<install_skill_path>/SKILL.md`。

## 最低验证证据

| 风险领域 | 最低证据 | 不接受的替代物 |
|---|---|---|
| `<domain>` | <命令、测试、计划、指标或复现> | <仅凭直觉、关键词或类型检查> |

## 阻断条件

- <未满足时不得宣告完成或合并的条件>；

## 项目本地化

安装后填写：

- Install：`<command>`
- Lint：`<command>`
- Typecheck：`<command>`
- Unit tests：`<command>`
- Integration tests：`<command>`
- Build：`<command>`
- Migration check：`<command>`

## 非目标

- <明确不承担的专业领域或业务职责>。
```

## Frontmatter 规则

- `profile_id`、`profile_version`、`skill_name`、`canonical_skill_path`、`install_skill_path` 必填；
- `risk_domains` 至少一个，只使用 `AGENTS.md` 定义的标准领域；
- 路径必须是仓库相对路径，不使用绝对路径；
- canonical Profile 可以指向 `extensions/`；安装后的本地 Profile 必须能解析到项目中的 Skill；
- Profile 版本与 Skill metadata 版本不要求数值完全相同，但必须在能力包 README 中说明兼容关系。
