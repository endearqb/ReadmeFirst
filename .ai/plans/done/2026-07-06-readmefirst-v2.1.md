# ReadmeFirst v2.1 优化需求与实施计划

> **执行者须知**:本计划写给零上下文的执行 Agent。执行前先读目标仓库的 `AGENTS.md` 与本计划全文;按阶段逐任务执行,每个任务自带验收方式;遇到阻塞停下来问,不要猜。本计划本身即 v2.1「计划协议」(R7) 的格式示范。

**基线**:README First v2(分级执行版,已交付的 AGENTS.md / README.md / builder / maintainer)。
**目标版本**:v2.1.0。
**借鉴来源**:obra/superpowers、mattpocock/skills、code-yeongyu/oh-my-openagent(含 lazycodex)、garrytan/gstack。

---

## 0. 目标与硬约束

**目标**:在不增加日常任务负担的前提下,吸收五个仓库中经过实战验证的九项机制,补齐 v2 的四块短板——验证的可信度、框架自身的可升级性、本质不确定性的主动压缩手段、跨会话的工作连续性。

**硬约束(重量预算,任何需求实现与之冲突时以本节为准)**:

1. **每任务必经路径零新增**:`AGENTS.md` 第 0 节最小闭环的 L0/L1 要求不得增加任何步骤。所有新组件均为触发式:命中条件才启用,不命中时 Agent 甚至不需要知道它们存在。
2. **AGENTS.md 总长 ≤ 300 行,第 0 节必读核心 ≤ 45 行**。新协议条款每项只允许 3–6 行,模板一律外置到 builder 的 `references/templates.md`。
3. **推荐最小系统不变**(AGENTS.md、根 README、architecture、changes、decisions)。plans、glossary、handoff 定位为「标准扩展」:builder 默认创建占位但不强制使用,协议中标注"如存在则…"。
4. **保持纯 Markdown + 少量只读 bash 脚本**。脚本只做检测输出数据,不做修改;判断和修改始终由 Agent 完成。

**非目标(评估后明确排除)**:changes 的 jsonl 机器可解析化(牺牲可读性);SKILL.md.tmpl 生成机制(引入构建链);巡检接入 CI(本次只到脚本);superpowers 式"1% 可能就必须触发"的强制条款(与"够用即停"哲学冲突);omo 式 `.ai/evidence/` 重型证据落盘目录(个人项目过重,只采纳轻量版 R3)。

---

## 1. 需求清单

| 编号 | 需求 | 来源机制 | 落点 |
|---|---|---|---|
| R1 | 文档时效戳 | omo:AGENTS.md 头部 Generated/Commit 戳 | 目录 README、architecture 文件头部;AGENTS.md §5.2;maintainer 巡检 |
| R2 | 框架版本化与升级通道 | gstack:VERSION + migrations + /gstack-upgrade | 仓库根 VERSION、migrations/、builder 升级模式、下游版本印记 |
| R3 | 验证证据门(轻量版) | superpowers:verification-before-completion;omo:无证据=未发生 | AGENTS.md §5.1 / §6 / §7 |
| R4 | 建点双因子算法 | omo init-deep:复杂度评分选点 | builder 第 1 步、maintainer 覆盖检查、脚本 dir-hotspots.sh |
| R5 | 拷问式访谈(访谈模式) | mattpocock:grilling | AGENTS.md §3.5 扩展;R7 计划流程第一步引用 |
| R6 | 术语表 | mattpocock:CONTEXT.md 共享语言 | `.ai/glossary.md` + 读取路由 + builder/maintainer |
| R7 | 计划协议 | superpowers:writing-plans / executing-plans | `.ai/plans/` + AGENTS.md 新增短节 + 模板 |
| R8 | 会话交接 | mattpocock:handoff | `.ai/handoff.md` + 读取路由 + 清理规则 |
| R9 | maintainer 检查脚本 | lazycodex:文档内容测试(不接 CI) | `skills/readme-first-maintainer/scripts/` 三个只读脚本 |

---

## 2. 设计决策(实施时写入 `.ai/decisions/`)

**D1 版本号方案(R2)**:采用三段语义版本。MAJOR=协议执行方式不兼容变化(如 v1→v2 分级);MINOR=新增组件或规则,向后兼容;PATCH=文字修正。已合并的分级协议基线定为 **2.0.0**,本计划完成后升至 **2.1.0**。下游项目的版本印记写在其 `AGENTS.md` 首行注释:`<!-- README First protocol v2.1.0 -->`。

**D2 扩展组件边界**:plans / glossary / handoff 是标准扩展而非最小系统成员。理由:三者都有明确的触发条件,不命中时为空文件或不存在,不应出现在"每个项目必须理解"的最小集合里。协议条款统一用"如存在则读/用"的措辞。

**D3 grilling 并入协议而非独立技能**:访谈是不确定性压缩的手段,归属 §3.5(提问规则),不新增第三个技能。理由:保持"两技能一协议"的极简结构;mattpocock 的 grilling 之所以是技能,是因为其仓库是技能集,而 ReadmeFirst 是协议。

**D4 handoff 存放于项目内**(`.ai/handoff.md`)而非系统临时目录(mattpocock 的做法)。理由:ReadmeFirst 的哲学是项目内持久上下文;跨机器、跨 Agent 工具也能接续。同时采纳其两条纪律:不复制其他文档已有的内容(引用路径即可)、脱敏(密钥、密码、个人信息不入交接文档)。

**D5 脚本语言与平台**:bash 编写、只读输出、POSIX 风格;Windows 环境经 Git Bash 运行(仓库维护者当前使用 PowerShell,脚本内避免 bashism 高级特性,并在 maintainer SKILL.md 注明)。

---

## 3. 需求详细规格

### R1 文档时效戳

目录 README 与 `.ai/architecture/` 各文件标题下加一行:

```md
> 更新于:YYYY-MM-DD · commit <short-sha>
```

规则(写入 AGENTS.md §5.2 末尾,2 行):更新某文档时同步刷新其时效戳;builder 生成文档时写入。maintainer 工作流 1b 的时效检查改为以戳为锚点:戳日期与该目录代码最后提交相差超过 60 天 → 标记待审;发现无戳文档 → 补戳。

### R2 框架版本化与升级通道

新增文件:仓库根 `VERSION`(内容 `2.1.0`);`migrations/v2.0-to-v2.1.md`(面向 Agent 的 Markdown 操作清单:下游 v2.0 项目如何升到 v2.1——AGENTS.md 增补哪些节、创建哪些占位文件、模板字段怎么改)。此前的 UPGRADE-NOTES.md 内容并入 `migrations/v1-to-v2.0.md` 留档。

builder 新增**升级模式**:检测目标项目 AGENTS.md 首行版本印记 → 与自身 VERSION 比较 → 相同则报告"已最新";落后则按序逐个应用 migrations 文件(每个迁移完成后更新印记),全程遵循原有合并规则(不覆盖本地内容)。无印记的项目视为 v1 或未初始化,先判别再走对应路径。

maintainer 巡检新增一项:报告目标项目版本印记与上游 VERSION 的差距(有网络时对比 GitHub raw,无网络时跳过并注明)。

### R3 验证证据门(轻量版)

核心原则一句话(写入 §5.1):**没有新鲜的验证证据,不得声称完成。** 具体改动:

1. §5.1 L2 模板的"验证方式"字段改名"**验证证据**",格式要求:实际运行的命令 + 关键输出摘录(1–5 行)+ 结论;确实无法运行时,写明原因与所做的替代核查。L1 模板"验证"字段沿用同格式,可精简为一行"命令 → 结果"。
2. §6 禁止行为第 7 条强化为:"在没有本次会话内新鲜验证证据的情况下声称问题已解决。"
3. §7 L2 输出要求中"验证方式与结果"同步改为"验证证据"。

### R4 建点双因子算法

选点依据从单一 git 热度改为**热度 × 复杂度**:热度 = 近 90 天该目录提交触达次数;复杂度 = 文件数、代码行数、子目录深度、大文件(>500 行)数的粗评分。判断规则写进 builder 第 1 步与 maintainer 工作流 1c(各 3 行):双高 → P0 必建;高热低复杂 → 短 README(最小三节);高复杂低热 → 待观察,列入报告;双低 → 不建。数据由 R9 的 `dir-hotspots.sh` 输出,判断由 Agent 做。无 git 历史的新项目只用复杂度因子。

### R5 拷问式访谈(访谈模式)

§3.5 增补一段(约 5 行):当 L2 任务的剩余本质不确定性主要来自用户意图、业务规则或取舍标准(即"只存在于用户脑中、读代码无法压缩"的部分),Agent 应主动发起**访谈模式**:一次只问一个问题;每个问题说明它影响哪个实现分支;沿决策树逐层收敛,直到分支全部解决或用户叫停;访谈结论写入任务契约,重要结论按 §5 沉淀。访谈模式是 §3.5 防御性提问规则的例外通道——防御规则防的是"用提问逃避读上下文",访谈模式处理的是"读遍上下文也无法压缩的部分",两者以此为界。R7 的计划编写流程第一步默认引用访谈模式。

### R6 术语表

新增 `.ai/glossary.md`,表格三列:术语 | 定义 | 别名/易混淆项。规则:

1. 读取路由(§2 表格加一行):会话内首次接触项目时,若 glossary 存在则与根 README 一并读取——它是省 token 的投资,读取成本远低于收益。
2. 写入触发(§5.2 加 1 行):任务中出现需要多句话解释、且在对话或代码中反复出现的领域概念 → 顺手添加词条(L1 及以上)。
3. 命名约束(§3.6 加 1 行):新增代码的命名应使用 glossary 术语,不得为同一概念发明第二套词汇。
4. builder:初始化第 5 步之后新增可选步骤——扫描中发现明显领域术语(≥3 个)时创建 glossary 并预填,否则只建带表头的占位文件。
5. maintainer:巡检新增术语表检查——词条与代码实际命名的漂移、重复/冲突词条、长期未用词条建议修剪。

### R7 计划协议

新增 `.ai/plans/YYYY-MM-DD-<slug>.md`,完成后移入 `.ai/plans/done/`。AGENTS.md 新增短节「5.4 计划协议」(约 6 行):

- **触发**:L2 且预计涉及 3 个以上文件或多阶段执行,或用户明确要求"先出计划"。其余任务不写计划文件,任务契约在内部完成即可。
- **标准**(借 superpowers):计划要写到"零上下文、不了解本项目的执行者也能照做"的粒度——每个任务标明涉及文件、具体步骤、验证命令,用 checkbox 追踪;编写前先走访谈模式(R5)收敛决策。
- **执行**:执行会话先读计划并批判性审查(有疑虑先提出),逐项勾选,遇阻塞停下来问而不是绕过;完成后计划归档,changes 记录引用计划路径。

计划模板(头部:目标 / 方式 / 全局约束;正文:分阶段 checkbox 任务)放入 `references/templates.md`。

### R8 会话交接

新增 `.ai/handoff.md`(单文件,同一时间至多一份活跃交接)。AGENTS.md §2 路由表加一行 + §5 加 3 行:

- **写入时机**:会话将结束但任务未完成(用户示意暂停、或上下文接近极限)时,写交接文档:任务目标、已完成、当前状态、下一步、关键假设、建议先读的文件(引用路径,不复制其他文档已有内容;脱敏)。
- **读取时机**:会话开始时若 `.ai/handoff.md` 存在且非空 → 必读(优先级仅次于 AGENTS.md 第 0 节)。
- **清理**:接续会话完成该任务后清空此文件并在 changes 中记录;maintainer 巡检发现超过 14 天的陈旧交接 → 列入待确认(归档或作废)。

### R9 maintainer 检查脚本

新增 `skills/readme-first-maintainer/scripts/`(全部只读、输出数据、退出码非零表示有发现):

| 脚本 | 职责 | 对应巡检 |
|---|---|---|
| `check-paths.sh` | 提取所有 md 中反引号路径与相对链接,验证存在性,输出失效清单 | 工作流 1a |
| `check-freshness.sh` | 对比各 README 时效戳(R1)/git 时间与所在目录代码最后提交时间,输出过期清单(阈值参数化,默认 60 天) | 工作流 1b |
| `dir-hotspots.sh` | 输出各目录的热度与复杂度双因子数据表(R4),排除构建产物目录 | 工作流 1c |

maintainer SKILL.md 相应改写:三个巡检项改为"先跑脚本取数据,再由 Agent 判断";注明 Windows 经 Git Bash 运行;脚本各带 `--help` 与自测样例。

---

## 4. 实施计划

按文件批次分三阶段,每阶段可在一个会话内完成,均按 L2 记录。阶段间有依赖,顺序执行。

### Phase 1 —— 协议层(AGENTS.md / 根 README / 模板)

覆盖:R1、R3、R5、R6、R7、R8 的协议条款。

- [ ] 1.1 修改 `AGENTS.md`:§2 路由表加 glossary、handoff 两行;§3.5 增补访谈模式;§3.6 加术语命名约束;§5.1 改验证证据字段(L1/L2 模板);§5.2 加时效戳与 glossary 写入触发;新增 §5.4 计划协议;§5 加 handoff 三条;§6 第 7 条强化;§7 同步。**验收**:全文 ≤ 300 行(`wc -l`);第 0 节 ≤ 45 行;L0/L1 必经要求与 v2 逐字比对无新增。
- [ ] 1.2 修改根 `README.md`:系统组成树与职责表加入三个标准扩展(标注"按需启用");原则 5 提及验证证据;加版本说明段(VERSION 与版本印记机制)。**验收**:总长 ≤ 145 行;最小系统表述未变。
- [ ] 1.3 更新 `skills/readme-first-builder/references/templates.md`:新增计划模板、glossary 表头模板、handoff 模板;changes 两级模板的验证字段改为证据格式;目录 README 模板头部加时效戳行。**验收**:模板与 1.1 中的协议措辞逐项对应。
- [ ] 1.4 同步 `references/agents-md-template.md` 为 1.1 的最新全文(保留头部同步注释)。**验收**:`diff` 除注释外零差异。

### Phase 2 —— 技能层(builder / maintainer / 脚本)

覆盖:R2、R4、R9,及 R6 的技能侧。前置:Phase 1 完成。

- [ ] 2.1 创建根 `VERSION`(`2.1.0`)与 `migrations/` 目录;编写 `migrations/v2.0-to-v2.1.md`(操作清单:逐节增补指令 + 占位文件创建 + 印记更新);将 UPGRADE-NOTES.md 改写并入 `migrations/v1-to-v2.0.md`。**验收**:一个只见过 v2.0 的 Agent 按迁移文件操作后,产物与 Phase 1 模板一致。
- [ ] 2.2 修改 builder SKILL.md:新增升级模式(印记检测→比对→按序迁移);第 1 步选点改双因子并引用 dir-hotspots.sh;新增 glossary 可选步骤;初始化产物写入版本印记与时效戳。**验收**:SKILL.md ≤ 120 行;description 中补充升级触发语(upgrade README First / 升级框架版本)。
- [ ] 2.3 编写三个脚本(check-paths.sh / check-freshness.sh / dir-hotspots.sh),各带 `--help`;在本仓库自测跑通。**验收**:对本仓库运行,check-paths 零误报;人为制造一个坏链接能被捕获。
- [ ] 2.4 修改 maintainer SKILL.md:巡检 1a/1b/1c 改为脚本取数;新增版本差距报告、glossary 巡检、陈旧 handoff 检查、未归档 plans 检查。**验收**:SKILL.md ≤ 180 行;每个新巡检项都有明确的"发现→处理"路径。

### Phase 3 —— 仓库自身收尾

- [ ] 3.1 同步 `.ai/architecture/`:documentation-contracts 加三个扩展组件与证据契约;builder-skill(或合并后的 skills 文档)更新两技能职责;context-map / dependency-boundaries 加新组件流向;current-state 更新 Landed 与 Gaps(移除"无自动化文档检查"缺口)。
- [ ] 3.2 写入 `.ai/decisions/`:D1–D5(可合并为两三份决策文件:版本方案、扩展组件边界、脚本与访谈的归属)。
- [ ] 3.3 在 `.ai/changes/` 记录本次升级(L2,验证证据字段按新格式示范)。
- [ ] 3.4 全量自检:对本仓库运行三个脚本 + 交叉检查(版本号、模板、协议措辞在 README/AGENTS/两技能间一致);更新根 AGENTS.md 首行版本印记为 v2.1.0。**验收**:脚本零发现;`grep -rn "2\.1\.0"` 命中 VERSION、印记、migrations 三处且一致。

---

## 5. 影响面汇总

**修改**:AGENTS.md、README.md、builder(SKILL.md + 两个 references)、maintainer SKILL.md、`.ai/architecture/` 全组、UPGRADE-NOTES.md(并入 migrations)。
**新增**:VERSION、migrations/(2 个文件)、maintainer scripts/(3 个脚本)、`.ai/decisions/` 2–3 份、`.ai/changes/` 1 条;下游项目侧新增 `.ai/plans/`、`.ai/glossary.md`、`.ai/handoff.md` 三个按需占位。

**风险与对策**:重量回潮 → §0 硬约束逐条验收(1.1/1.2 的行数与逐字比对);新组件被 Agent 误当必选 → 所有条款用"如存在则…/命中条件才…"措辞,3.4 自检时 grep 复核;双份 AGENTS.md 模板漂移 → 1.4 diff 验收 + maintainer 常态同步检查(v2 已有);脚本在 Windows 失效 → D5 约束 + maintainer 中注明降级为手工巡检的路径。

---

## 6. 验收总标准

1. 硬约束四条全部满足(行数、零新增必经步骤、最小系统不变、脚本只读)。
2. 九项需求各自的验收点通过(见 §3、§4 任务内标注)。
3. 一个从未见过本仓库的 Agent,仅凭 v2.1 的 AGENTS.md 第 0 节即可正确处理 L0/L1 任务;仅在 L2 大任务时才会接触 plans/访谈/证据的完整要求。
4. 一个 v2.0 的下游项目,可由 builder 升级模式无损升至 v2.1(本地规则零丢失)。
