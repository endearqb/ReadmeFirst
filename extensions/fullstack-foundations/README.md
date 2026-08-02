# Full-stack Foundations Capability Pack

> 更新于:2026-08-02

这是 README First v2.2 的首个参考能力包，面向由前端或全栈工程师维护的 Node.js / TypeScript 服务，以及涉及 PostgreSQL、事务并发、HTTP、缓存、安全、隐私和迁移的任务。

## 组成

```text
fullstack-foundations/
├── PROFILE.md
├── README.md
└── skill/
    └── fullstack-foundations-guard/
        ├── SKILL.md
        ├── README.md
        ├── examples/
        ├── references/
        │   ├── training-handbook.md      # 培训索引与基础框架
        │   ├── training/                 # 10 个按需加载专题
        │   ├── review-checklist.md
        │   ├── patterns-and-antipatterns.md
        │   ├── output-contract.md
        │   └── source-map.md
        └── scripts/
            └── risk_scan.py
```

- `PROFILE.md`：项目级触发、路由、业务不变量、阻断条件和最低证据；
- `SKILL.md`：Review、Implementation、Design、Mentor 工作流；
- `references/training-handbook.md` + `references/training/`：培训索引、基础框架与 10 个按需加载专题；
- `references/review-checklist.md`：PR 与实现检查清单；
- `references/patterns-and-antipatterns.md`：正反模式；
- `scripts/risk_scan.py`：无第三方依赖的风险候选扫描器。

## 安装

在 canonical ReadmeFirst 仓库或能力包目录中执行：

```bash
mkdir -p <target>/.ai/profiles <target>/skills
cp PROFILE.md <target>/.ai/profiles/fullstack-foundations.md
cp -R skill/fullstack-foundations-guard \
  <target>/skills/fullstack-foundations-guard
```

随后：

1. 根据目标项目事实本地化 Profile；
2. 填写真实验证命令；
3. 确认 `skills/fullstack-foundations-guard/SKILL.md` 存在；
4. 在一次真实 L1/L2 任务中验证风险路由；
5. 在 `.ai/changes/` 记录安装和验证证据。

## 使用原则

- 命中 Profile 触发条件才加载 Skill；
- Skill 主文件先行，references 按需读取；
- Mentor 模式才默认读取完整培训手册；
- Scanner 命中只是调查候选；
- 项目本地规则、代码、schema、配置和测试始终优先。

## 卸载

1. 确认没有项目规则或 plans 仍引用该 Profile / Skill；
2. 删除 `.ai/profiles/fullstack-foundations.md`；
3. 删除 `skills/fullstack-foundations-guard/`；
4. 更新相关 README 和 `.ai/changes/`；
5. 运行项目路径检查。

卸载不应删除由真实项目经验沉淀到目录 README、architecture 或 decisions 的长期知识。

## 验证

```bash
python3 - <<'PY'
import ast
from pathlib import Path
path = Path("skill/fullstack-foundations-guard/scripts/risk_scan.py")
ast.parse(path.read_text(encoding="utf-8"), filename=str(path))
print("risk-scan syntax: clean")
PY
python3 skill/fullstack-foundations-guard/scripts/risk_scan.py \
  skill/fullstack-foundations-guard --format json
```
