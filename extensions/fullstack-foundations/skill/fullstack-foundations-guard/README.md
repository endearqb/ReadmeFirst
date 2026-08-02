# fullstack-foundations-guard

> 更新于:2026-08-02

面向 CodeAgent / Agent Skills 兼容编码代理的全栈工程质量 Skill。它不把“接口能跑”视为完成，而是覆盖浏览器、HTTP、Node.js、PostgreSQL、事务并发、缓存、权限、安全、迁移和恢复的完整请求链路。

在 README First v2.2 项目中，本 Skill 由 `.ai/profiles/fullstack-foundations.md` 按风险领域触发；在未采用 README First 的项目中，也可以使用 `references/agents-snippet.md` 直接集成。

## 目录

```text
fullstack-foundations-guard/
├── SKILL.md
├── README.md
├── examples/
│   └── review-example.md
├── references/
│   ├── agents-snippet.md
│   ├── output-contract.md
│   ├── patterns-and-antipatterns.md
│   ├── review-checklist.md
│   ├── source-map.md
│   ├── training-handbook.md
│   └── training/                 # 按需加载的 10 个专题章节
└── scripts/
    └── risk_scan.py
```

## README First v2.2 安装

从能力包根目录复制：

```bash
mkdir -p <target>/.ai/profiles <target>/skills
cp PROFILE.md <target>/.ai/profiles/fullstack-foundations.md
cp -R skill/fullstack-foundations-guard \
  <target>/skills/fullstack-foundations-guard
```

然后在目标项目本地化 Profile：

- 核对真实技术栈和触发路径；
- 填写 lint、typecheck、test、build、migration 命令；
- 删除不适用风险领域；
- 确认 `install_skill_path` 指向 `skills/fullstack-foundations-guard`；
- 用一次真实 L1/L2 任务验证风险路由。

## 独立安装

不采用 README First 时，将整个目录复制到 Agent 能扫描的 Skill 目录：

```bash
mkdir -p skills
cp -R fullstack-foundations-guard skills/
```

再把 `references/agents-snippet.md` 中的短路由合并到项目规则文件。不要把完整培训手册复制进每次必读的 `AGENTS.md`。

## 触发示例

```text
使用 fullstack-foundations-guard 审查这个 PR。重点检查 SQL、事务、并发、CORS、敏感数据和迁移风险，只报告有证据的问题。
```

```text
使用 fullstack-foundations-guard 实现这个 Node API。先写业务不变量、权限边界、事务、资源预算和幂等策略，再实现并运行测试。
```

```text
使用 fullstack-foundations-guard 以 Mentor 模式，从零教我完成一个 PostgreSQL + Node.js 的任务接口。每一步包含失败复现、修复和验收证据。
```

## 候选风险扫描器

扫描器不依赖第三方 Python 包：

```bash
python3 skills/fullstack-foundations-guard/scripts/risk_scan.py . \
  > fullstack-risk-candidates.md
```

JSON 输出：

```bash
python3 skills/fullstack-foundations-guard/scripts/risk_scan.py . \
  --format json
```

CI 中仅把高风险候选作为非零退出条件：

```bash
python3 skills/fullstack-foundations-guard/scripts/risk_scan.py . \
  --fail-on high
```

扫描命中只是调查线索，不是已经确认的缺陷或漏洞；无命中也不代表安全。Agent 必须回到真实数据流、配置、权限边界和运行证据完成验证。

## 推荐工作流

1. README First 先完成任务定级和风险领域识别；
2. Profile 决定是否触发本 Skill；
3. Skill 建立请求链路、信任边界、业务不变量与资源预算；
4. 按风险加载 checklist、模式库和培训材料；
5. 运行项目测试、查询计划或最小并发复现；
6. 可选运行候选扫描器；
7. 按输出契约报告 finding、证据、修复与残余风险。

## 设计原则

- 证据优先，而非关键词审查；
- 先保证正确性和安全，再谈局部性能；
- 客户端不可信，服务端维护最终真相；
- 并发、重复、超时和部分失败属于正常路径；
- SQL 和索引建议绑定真实查询形状与执行证据；
- 自动扫描只做线索发现；
- references 渐进加载，Mentor 模式才默认读取完整培训手册。
