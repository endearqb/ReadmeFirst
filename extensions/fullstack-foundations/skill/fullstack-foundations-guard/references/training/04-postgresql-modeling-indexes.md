# 04. PostgreSQL 建模、SQL、索引与迁移

## 学习目标

- 使用 PK、FK、UNIQUE、CHECK 和 NOT NULL 表达业务不变量；
- 编写参数化、有界且稳定排序的 SQL；
- 识别 N+1、深 OFFSET、`SELECT *` 和应用层过滤；
- 根据真实查询形状和执行计划设计索引；
- 评估迁移锁、表重写、回填和恢复。

## 约束优先

关键唯一性和状态边界不能只放在前端或“先查后写”逻辑中。多租户模型应让 tenant/workspace 进入唯一约束、外键和查询条件，避免全局 ID 被误用。

## 查询必须有界

列表需要最大 `LIMIT`、稳定排序和明确返回字段。深 OFFSET 会扫描并丢弃大量行，且数据变化时容易重复或遗漏；长列表优先考虑 keyset/cursor pagination。

## 索引建议的证据链

1. 写出真实 `WHERE / JOIN / ORDER BY / LIMIT`；
2. 说明数据量、选择性、倾斜和热点；
3. 获取当前 `EXPLAIN`，可控环境优先 `EXPLAIN (ANALYZE, BUFFERS)`；
4. 解释候选索引列顺序、部分条件或 INCLUDE；
5. 评估写放大、存储、VACUUM 和迁移成本；
6. 用相同数据和负载复测。

Seq Scan 不一定错误；小表、低选择性或读取大部分行时可能更合理。

## 迁移

大表索引优先评估 `CREATE INDEX CONCURRENTLY`；破坏性变更采用 expand → migrate/backfill → switch → observe → contract。任何回填都应可重入、分批、有 checkpoint、速率、停止条件和验证查询。

## 练习

生成 10 万至 100 万条带租户倾斜的工作项数据，比较单列索引、复合索引和部分索引的计划、buffer、p95、索引大小和写入成本，并写出为何选择或放弃某个索引。
