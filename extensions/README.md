# README First Capability Extensions

> 更新于:2026-08-02

`extensions/` 发布可选的专业能力包。它让 README First Core 保持轻量，同时允许目标项目按真实技术栈和风险领域安装更深的 Profile、Skill、references、scripts 与培训材料。

## 能力包与核心协议的边界

README First Core 负责：

- L0/L1/L2 任务分级；
- 项目上下文读取；
- 不确定性压缩；
- 风险领域识别；
- Profile / Skill 路由；
- changes、architecture 和 decisions 的证据沉淀。

能力包负责：

- 某一专业领域的失败模型；
- 项目本地 Profile 的模板；
- 可复用 Agent Skill；
- 风险专用检查清单、脚本、示例和培训材料。

能力包不应：

- 覆盖目标项目更严格的 `AGENTS.md` 或目录 README；
- 把通用建议伪装成目标项目事实；
- 自动进入所有任务上下文；
- 把扫描器命中直接认定为缺陷；
- 静默安装到不匹配的项目。

## 标准结构

```text
extensions/<capability-pack>/
├── PROFILE.md
├── README.md
└── skill/
    └── <skill-name>/
        ├── SKILL.md
        ├── references/
        ├── scripts/
        └── examples/
```

`PROFILE.md` 使用 `profile-template.md` 定义的 frontmatter 和章节。能力包可以省略不需要的 `scripts/` 或 `examples/`，但必须保留清晰的安装路径和验证方式。

## 安装到目标项目

```bash
mkdir -p .ai/profiles skills
cp extensions/<capability-pack>/PROFILE.md \
  .ai/profiles/<profile-id>.md
cp -R extensions/<capability-pack>/skill/<skill-name> \
  skills/<skill-name>
```

安装后必须本地化：

1. 核对触发条件是否符合真实技术栈；
2. 填写项目验证命令和关键入口；
3. 删除不适用风险领域；
4. 确认 `install_skill_path` 指向真实 `SKILL.md`；
5. 在一次真实 L1/L2 任务中验证路由和证据模板；
6. 在 `.ai/changes/` 记录安装原因、范围和验证。

## 版本与兼容

- ReadmeFirst 协议版本与能力包版本独立。
- Profile 的 `profile_version` 与 Skill metadata 版本应保持兼容。
- 升级能力包时只合并通用改进，不覆盖目标项目对 Profile 的本地化修改。
- 破坏性 Profile Schema 变化必须提供能力包迁移说明。

## 当前能力包

| 能力包 | 风险领域 | 状态 |
|---|---|---|
| `fullstack-foundations` | Node.js、PostgreSQL、事务并发、HTTP、缓存、安全、迁移 | Reference / 1.0.0 |

## 新能力包验收

新增能力包至少满足：

- Profile 触发条件可以从项目事实判断；
- 风险领域有限且命名稳定；
- Skill 主文件不复制整份培训手册；
- references 按需加载；
- 脚本输出明确区分候选线索和确认结论；
- 有最小安装与卸载说明；
- `python3 tests/validate_repository.py` 通过。
