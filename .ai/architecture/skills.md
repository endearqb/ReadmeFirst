# README First Skills Architecture

> 更新于:2026-08-02

README First 有两类 Skill：Core 生命周期 Skill 和可选专业能力 Skill。

## 1. Core 生命周期 Skill

### `readme-first-builder`

负责：

- 初始化或升级协议；
- 合并而不覆盖本地规则；
- 建立最小 `.ai/` 和 P0 README；
- 使用自带热点脚本，保持离线自包含；
- 从项目事实发现风险 Profile 候选；
- 在明确选择且能力包可用时安装 Profile / Skill。

不负责日常任务、完整代码审计、编造技术栈或静默安装能力包。

### `readme-first-maintainer`

负责：

- 路径、新鲜度和覆盖巡检；
- changes 压缩与知识沉淀；
- L0/L1/L2 校准；
- Profile/Skill 引用、触发和证据治理；
- canonical 模板同步和验证。

不修改业务代码，不替代专业 Skill，不未经确认停用能力包。

## 2. 专业能力 Skill

由 canonical `extensions/` 发布，安装到目标项目后由 `.ai/profiles/` 路由。

负责：

- 某专业领域的失败模型、工作流和证据；
- Review、Implementation、Design、Mentor 等模式；
- 按需 references、scripts 和 examples。

不负责：

- 决定项目是否需要它（由 Profile 和项目事实决定）；
- 覆盖本地更严格规则；
- 把扫描候选包装为确认 finding；
- 默认加载全部材料。

## 3. Canonical Sync

Core 变化时检查：

- `AGENTS.md`；
- Builder `agents-md-template.md`；
- 根 README、VERSION、migrations；
- architecture；
- Builder 和 Maintainer。

Profile Schema 变化时检查：

- `extensions/profile-template.md`；
- `profiles-and-extensions.md`；
- `check-profiles.py`；
- `tests/validate_repository.py`；
- 当前能力包 PROFILE。

热点算法变化时，Builder 和 Maintainer 的 `dir-hotspots.sh` 必须保持字节一致。

## 4. 验证

```bash
bash tests/test-maintainer-scripts.sh
python3 tests/validate_repository.py
```
