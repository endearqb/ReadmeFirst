# 0005 - 将任务级别与风险领域分离，并引入 Profile 与能力包

## 背景

README First v2.1 已能用 L0/L1/L2 控制上下文读取、任务契约、变更记录和最终输出的流程重量，但同一维度同时承担了“改动影响有多大”和“任务需要什么专业能力”两个问题。

例如，一个只修改单个 Node.js 接口文件的任务可能仍涉及数据库索引、事务并发、跨租户授权、缓存隔离或外部副作用。仅按文件数和公共接口判断任务级别，无法稳定路由到数据库、安全、网络等专业检查；反过来，把所有服务端修改都升级为 L2 又会让协议重新变重。

## 决策

1. **采用二维路由**：
   - L0/L1/L2 继续决定流程重量；
   - `risk_domains` 描述可能的失败机制，并决定加载哪个项目 Profile、专业 Skill 与风险对应证据。
2. **引入项目本地 Profile**：目标项目可在 `.ai/profiles/` 放置短路由契约。Profile 只记录触发条件、风险领域、必读上下文、业务不变量、最低证据、阻断条件和 Skill 绑定，不承载完整教程。
3. **引入 canonical 能力包**：ReadmeFirst 仓库在 `extensions/` 发布可选的 Profile + Skill + references + scripts + training。能力包不进入最小系统，Builder 只能基于仓库事实提出候选，必须经显式选择后安装。
4. **建立优先级**：项目 `AGENTS.md` > 最近目录 README > 项目本地 Profile > 通用 Skill > Skill references。下层不得覆盖项目更具体或更严格的规则。
5. **把证据与风险绑定**：L2 记录新增风险领域、使用的 Profile/Skill、业务不变量与信任边界、风险对应证据。通用测试通过不能替代查询计划、并发测试、权限负面用例、迁移恢复等领域证据。
6. **首个参考能力包**：发布 `fullstack-foundations`，覆盖数据库、事务、并发、HTTP、缓存与过载、运行时资源、认证授权、安全隐私、迁移发布和外部副作用。
7. **保持渐进披露**：培训手册和大体量 references 只在 Mentor/教学或具体问题需要时加载，不复制进每次必读的 `AGENTS.md`。
8. **Scanner 只产生候选**：静态扫描命中不得直接表述为已确认 finding；必须结合调用链、配置、测试和运行证据确认。

## 影响

- 协议版本升级至 2.2.0；下游通过 `migrations/v2.1-to-v2.2.md` 无损升级。
- `AGENTS.md`、Builder 模板与 `.ai/changes` L2 模板增加风险路由字段。
- 根 README 和 `.ai/architecture/` 纳入 `.ai/profiles/` 与 `extensions/`。
- Builder 增加能力包候选发现和显式安装流程；Maintainer 增加 Profile/Skill/证据治理。
- 维护脚本增加 Profile 结构校验，仓库增加 fixture 回归测试和 GitHub Actions 验证。
- 未安装任何 Profile 的 v2.1 项目仍可继续按原 L0/L1/L2 协议工作，不强制引入全栈能力包。

## 非目标

- 不把 README First 变成某一技术栈的后端规范。
- 不要求每个项目安装所有能力包，也不自动复制培训手册。
- 不替代 DBA、安全、SRE、法律或领域专家的高风险审查。
- 不在 v2.2 引入中心化 Profile Registry、CLI 或机器可解析的 changes 数据库；先用 Markdown 契约和轻量验证积累真实使用证据。
