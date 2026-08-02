# README First v2.2 模板集

> 更新于:2026-08-02

供 `readme-first-builder` 初始化/升级和 `readme-first-maintainer` 补建时使用。

统一规则：**信息不足的节直接删除，不写空泛占位句；所有内容必须来自当前项目事实。**

---

## 1. 目录 README 模板

最小可用版：

```md
# 目录说明：<目录名>

> 更新于:YYYY-MM-DD

## 职责
本目录负责：
本目录不负责：

## 核心文件
| 文件/子目录 | 作用 |
|---|---|

## 测试与验证
修改本目录后运行：
```

完整版：

```md
# 目录说明：<目录名>

> 更新于:YYYY-MM-DD

## 职责
本目录负责：
本目录不负责：

## 核心文件
| 文件/子目录 | 作用 |
|---|---|

## 约定与依赖边界
（命名、导出方式；可以依赖什么、不应依赖什么）

## 相关风险领域
（只列本目录长期稳定命中的领域；没有则删除本节）

## 测试与验证
修改本目录后运行：

## 维护提示
（未来维护者需要知道的长期约定；没有则删除本节）
```

---

## 2. `.ai/architecture/README.md` 起步模板

```md
# 当前架构状态

> 更新于:YYYY-MM-DD

## 系统概览
（一段话：主要模块、数据流和控制流）

## 模块地图
| 模块/目录 | 职责 | 主要对外接口 | 验证入口 |
|---|---|---|---|

## 跨目录边界
（允许和禁止的依赖方向；共享类型/配置的权威位置）

## 风险 Profile 与 Skill
（已安装 Profile、风险领域、Skill 路径；未安装则删除本节）

## 当前接受的缺口
（已知但暂不处理的问题，避免后续 Agent 重复发现）
```

超过约 150 行或出现独立主题时，由 maintainer 拆分为多文件并保留入口。

---

## 3. `.ai/changes/YYYY-MM-DD.md`

L1：

```md
## HH:MM - <标题> [L1]
- 目标与修改：
- 原因：
- 风险领域：（无则写“无”）
- 假设 / 剩余不确定性：（无则写“无”）
- 验证证据：（命令 → 关键输出摘录 → 结论；无法运行写明原因与替代核查）
- 文档更新：（无则写“无”）
```

L2：

```md
## HH:MM - <标题> [L2]
- 用户目标：
- 涉及目录：
- 风险领域：
- 使用的 Profile / Skill：（无则说明原因）
- 业务不变量与信任边界：
- 修改内容与原因：
- 已消除的不确定性：
- 关键假设：
- 剩余不确定性：
- 影响范围 / 风险控制：
- 风险对应证据：
  - 正确性：
  - 性能 / 资源：（不适用则写“不适用”）
  - 并发 / 重复：（不适用则写“不适用”）
  - 安全 / 隐私：（不适用则写“不适用”）
  - 迁移 / 恢复：（不适用则写“不适用”）
- README / Profile 更新：
- 是否新增/更新 `.ai/decisions/`：
```

L0 不写 changes，commit message 足够。

---

## 4. `.ai/decisions/NNNN-<slug>.md`

```md
# NNNN - <决策标题>

## 背景
（是什么问题迫使做选择）

## 决策
（选了什么；考虑但放弃了什么，为什么）

## 影响
（哪些文件、边界、Profile、Skill 或流程需要长期遵守）

## 非目标
（明确不涉及什么，防止过度引申）
```

---

## 5. `.ai/plans/YYYY-MM-DD-<slug>.md`

```md
# 计划：<标题>

> 目标：
> 方式：
> 全局约束：
> 风险领域：
> Profile / Skill：

## 阶段 1
- [ ] 任务 1（文件、步骤、验证命令、完成条件）
- [ ] 任务 2

## 阶段 2
- [ ] 任务 3

## 验收
- [ ] 全部 checkbox 完成
- [ ] 风险对应证据已记录
- [ ] README / Profile / architecture 触发项已核对
```

完成后移入 `.ai/plans/done/`。

---

## 6. `.ai/glossary.md`

```md
# 术语表

| 术语 | 定义 | 别名/易混淆项 |
|---|---|---|
|  |  |  |
```

---

## 7. `.ai/handoff.md`

```md
# 会话交接

> 创建时间:YYYY-MM-DD HH:MM

## 任务目标
## 已完成
## 当前状态
## 下一步
## 关键假设
## 风险领域
## 使用的 Profile / Skill
## 建议先读
（引用路径，不复制其他文档已有内容）

## 注意
（脱敏：不含密钥、密码、会话标识和个人敏感信息）
```

任务完成后清空。

---

## 8. `.ai/profiles/<profile-id>.md`

使用 canonical `extensions/profile-template.md`。最低要求：

```md
---
profile_id: <lowercase-kebab-case>
profile_version: "0.1.0"
status: active
skill_name: <skill-name>
canonical_skill_path: extensions/<pack>/skill/<skill-name>
install_skill_path: skills/<skill-name>
risk_domains:
  - <domain>
---

# <Profile Name>

## 目的
## 触发条件
## 不触发条件
## 必读上下文
## 业务不变量与信任边界
## 执行路由
## 最低验证证据
## 阻断条件
## 项目本地化
## 非目标
```

安装后的 `install_skill_path/SKILL.md` 必须存在。

---

## 9. 根 README 项目地图骨架

只补缺失节：

```md
## 项目是什么
## 技术栈
## 安装 / 启动 / 测试 / 构建
## 顶层目录职责
| 目录 | 职责 |
|---|---|
## AI 协作入口
本项目采用 README First：任务前读 `AGENTS.md` 第 0 节；
变更记录在 `.ai/changes/`，当前架构见 `.ai/architecture/`。
## 已安装风险 Profile
| Profile | 风险领域 | Skill |
|---|---|---|
```

未安装 Profile 时删除最后一节。
