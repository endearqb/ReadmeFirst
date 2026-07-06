# v1 → v2.0 迁移指南（留档）

核心变化：**协议重量与任务风险成正比**。其余都是这一变化的推论。

## 变了什么

| 维度 | v1 | v2.0 |
|---|---|---|
| 执行方式 | 所有任务走同一套 10 步流程 | L0 / L1 / L2 三级，读取、契约、记录、输出全部随级别缩放 |
| 每次必读 | AGENTS.md 全文 + 根 README + 路径 README(+ architecture) | AGENTS.md 第 0 节(约 35 行)+ 最近目录 README；根 README 仅会话首次；architecture 仅跨目录任务 |
| 阅读边界 | 无明确停止条件 | "够用即停"：影响本次任务的偶然不确定性消除即停 |
| 会话内重复阅读 | 未定义 | 已读且未修改的文档不重读 |
| README-代码一致性核对 | 每次任务的标准步骤 | 日常只核对与本次修改直接相关的声明；系统性巡检交给 maintainer |
| changes 记录 | 每次修改 11 字段 | L0 不记；L1 五字段；L2 十字段 |
| changes 累积 | 只进不出 | maintainer 定期压缩为月度 digest + archive |
| 最终报告 | 统一 7 项 | L0 一两句；L1 四项；L2 七项 |
| 任务契约 | 统一 8 项 | L1 三项；L2 八项 |
| 维护机制 | 无 | readme-first-maintainer：巡检 / 压缩 / 沉淀 / 校准 |
| .ai/architecture 起步 | 多文件 | 单文件起步，超过约 150 行才拆分 |
| builder 覆盖策略 | P0→P1→P2 尽量补全 | 只建 P0(上限 3–7 个)，其余渐进 |
| builder 模板来源 | 依赖网络拉取上游 | 离线优先：references/ 自带完整模板，有网时才对比上游 |

没有变的：银弹理论的不确定性框架(偶然/本质二分、压缩顺序、风险四级表、提问与假设规则)、`.ai/` 三层记录结构(architecture / changes / decisions)、文档只记长期知识、记录原因而非结果、合并不覆盖、全部禁止行为。

新增了一条禁止行为：低报任务级别以规避流程。分级不是协议的漏洞，分级本身就是一次风险评估。

## 迁移路径

### A. ReadmeFirst 仓库本身

1. 用 v2.0 的 `README.md`、`AGENTS.md` 替换根文件。
2. 替换 `skills/readme-first-builder/`(v2.0 的 references/ 结构不同：旧版 readmefirst-source 的内容已并入 SKILL.md，新增 agents-md-template 与 templates 两个 reference 文件)。
3. 新增 `skills/readme-first-maintainer/`。
4. 同步 `.ai/architecture/` 中受影响的文件。
5. 在 `.ai/changes/` 记录本次升级。

### B. 已用 v1 初始化的下游项目

1. 用 v2.0 模板替换 AGENTS.md 的协议部分，保留项目特化规则(验证命令、本地约定、更严格的规则)。
2. `.ai/changes/` 历史记录原样保留，新记录开始使用分级模板。
3. 升级后运行一次 maintainer：压缩存量记录、巡检漂移，顺带完成 v2.0 的第一次基线体检。
