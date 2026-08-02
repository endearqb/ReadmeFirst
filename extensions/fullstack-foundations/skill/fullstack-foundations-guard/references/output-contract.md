# Output Contract

## 1. Review 报告模板

```markdown
# Full-stack Foundations Review

## 1. 结论

- **Verdict**：PASS / PASS WITH CONDITIONS / CHANGES REQUIRED / BLOCK
- **Scope**：审查的 branch、commit、PR、diff、目录和功能
- **Highest risk**：最高风险的一句话结论
- **Evidence quality**：High / Medium / Low
- **Not covered**：本次未覆盖范围

## 2. 请求链路与业务不变量

### 请求链路

`client -> proxy -> route -> validation -> authn -> authz -> service -> transaction -> DB/cache/downstream -> response`

### 关键不变量

1. ...
2. ...

### 主要失败与并发场景

- ...

## 3. Findings

### [P1][Confirmed][Concurrency] 标题

- **Evidence**：`path/file.ts:Lx-Ly`、SQL、配置、测试或复现
- **Trigger**：何种输入、数据量、权限或并发下发生
- **Impact**：数据、安全、性能或可用性后果
- **Root cause**：根因
- **Minimal fix**：与现有架构一致的最小修复
- **Verification**：测试、查询计划、压测或观测
- **Residual risk**：修复后仍存在的风险

## 4. 数据库与查询证据

| Query ID | Shape | Current plan/evidence | Risk | Candidate change | Validation |
|---|---|---|---|---|---|

## 5. 事务、幂等与失败路径

| Use case | Invariant | Concurrency control | Retry | External side effect | Test |
|---|---|---|---|---|---|

## 6. HTTP、缓存与安全边界

- CORS：
- Cookie/session：
- Cache：
- Timeout/retry：
- Authorization：
- Sensitive data：

## 7. 测试与可观测性

- Existing tests：
- Missing tests：
- Required metrics/logs/traces：

## 8. 优先修复顺序

1. P0/P1 correctness/security
2. P1 availability/performance
3. P2 maintainability/coverage

## 9. 残余风险与证据缺口

- ...
```

## 2. Implementation 报告模板

```markdown
# Full-stack Foundations Implementation Report

## 1. 交付结论

- **Status**：COMPLETE / PARTIAL / BLOCKED BY EVIDENCE
- **Goal**：
- **Scope kept**：
- **Assumptions**：

## 2. 业务不变量与设计选择

| Invariant | Mechanism | Why | Test |
|---|---|---|---|

## 3. 修改文件

| File | Change | Risk addressed |
|---|---|---|

## 4. 数据库与迁移

- Schema/constraint：
- Query/index：
- Transaction/isolation：
- Lock/migration risk：
- Rollback/recovery：

## 5. HTTP、缓存与安全

- API contract：
- Timeout/retry/idempotency：
- Authn/authz：
- Sensitive data：
- Cache/CORS/Cookie：

## 6. 验证结果

| Command/Test | Result | Notes |
|---|---|---|

## 7. 未完成与残余风险

- ...
```

## 3. Design / PRD-SPEC-PLAN 模板

```markdown
# <Feature> Full-stack Design

## 1. Problem and outcome

## 2. Scope / Non-goals

## 3. Actors, tenants and trust boundaries

## 4. Business invariants

## 5. Request and data flows

## 6. Data model and constraints

## 7. API contract

## 8. Transaction, concurrency and idempotency

## 9. Query shapes and index plan

## 10. Cache, timeout, retry and overload

## 11. Authentication, authorization and privacy

## 12. Observability and SLO

## 13. Test matrix

## 14. Migration and rollout

## 15. Risks and alternatives

## 16. Milestones and acceptance criteria
```

## 4. Finding 严重等级

| 等级 | 定义 | 典型例子 | 默认处理 |
|---|---|---|---|
| P0 | 已发生或极易造成灾难性安全/数据后果 | 跨租户泄露、认证绕过、公开生产密钥、不可恢复数据破坏 | 立即阻断、止血、轮换、恢复 |
| P1 | 高概率破坏关键正确性、安全或可用性 | 重复扣款、超卖、SQL 注入、无界请求拖垮服务、阻塞生产迁移 | 合并前修复或有明确隔离审批 |
| P2 | 中等风险、规模扩大后会明显恶化 | N+1、低效分页、观测缺失、局部权限不完整、迁移恢复不足 | 当前迭代修复或排入近期计划 |
| P3 | 低风险改进 | 局部可读性、非关键测试、轻微一致性 | 按收益安排 |

## 5. Confidence

| 置信度 | 使用条件 |
|---|---|
| Confirmed | 已有可复现测试、查询计划、明确数据流或直接代码证明 |
| High | 代码路径清晰，触发条件可信，但尚未运行复现 |
| Medium | 依赖配置、数据量或运行时行为，需要补证据 |
| Hypothesis | 仅为排查方向，不得列为已确认缺陷 |

## 6. Verdict

| Verdict | 条件 |
|---|---|
| PASS | 未发现 P0/P1，关键证据充分，测试和迁移基线满足 |
| PASS WITH CONDITIONS | 无 P0，少量明确受控问题需要后续条件 |
| CHANGES REQUIRED | 存在 P1 或关键证据/测试缺失，合并前应修复 |
| BLOCK | 存在 P0，或变更可能造成不可控生产/数据后果 |

## 7. 证据引用规则

- 使用仓库相对路径和准确行号；
- SQL 使用 query ID 或调用路径；
- 查询计划只摘录关键节点，不粘贴无关大段；
- 配置说明环境和覆盖优先级；
- 测试说明命令、数据规模和结果；
- 不复制真实 Token、Cookie、密码、密钥或客户数据；
- 对无法读取的文件和未运行的命令明确说明。

## 8. 报告反模式

禁止：

- 只说“可能有性能问题”而无查询形状；
- 只说“加鉴权”而无主体/资源/动作；
- 把 grep 命中直接当漏洞；
- 把 lint 风格问题排在数据泄露之前；
- 没运行测试却写“全部通过”；
- 没有数据量却承诺具体性能收益；
- 把假设写成确定事实；
- 省略修复验证和残余风险。
