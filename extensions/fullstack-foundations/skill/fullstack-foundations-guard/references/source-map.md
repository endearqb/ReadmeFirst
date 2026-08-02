# Authoritative Source Map

> 当结论涉及具体协议、数据库行为、Node.js 运行时或安全基线时，优先查阅这些一手资料。项目代码和真实运行证据仍是当前任务的主要事实来源。

## PostgreSQL

| Topic | Source |
|---|---|
| Index principles | https://www.postgresql.org/docs/current/indexes.html |
| EXPLAIN and actual execution | https://www.postgresql.org/docs/current/using-explain.html |
| EXPLAIN command caution | https://www.postgresql.org/docs/current/sql-explain.html |
| Multicolumn indexes | https://www.postgresql.org/docs/current/indexes-multicolumn.html |
| Partial indexes | https://www.postgresql.org/docs/current/indexes-partial.html |
| Index ordering | https://www.postgresql.org/docs/current/indexes-ordering.html |
| Constraints and FK indexing note | https://www.postgresql.org/docs/current/ddl-constraints.html |
| Transaction isolation | https://www.postgresql.org/docs/current/transaction-iso.html |
| Explicit locking and deadlocks | https://www.postgresql.org/docs/current/explicit-locking.html |
| SQLSTATE error codes | https://www.postgresql.org/docs/current/errcodes-appendix.html |
| CREATE INDEX / CONCURRENTLY | https://www.postgresql.org/docs/current/sql-createindex.html |
| pg_stat_statements | https://www.postgresql.org/docs/current/pgstatstatements.html |
| auto_explain | https://www.postgresql.org/docs/current/auto-explain.html |

## Node.js and TypeScript

| Topic | Source |
|---|---|
| Event loop blocking and resource fairness | https://nodejs.org/learn/asynchronous-work/dont-block-the-event-loop |
| Node.js security baseline | https://nodejs.org/learn/getting-started/security-best-practices |
| AbortController / AbortSignal | https://nodejs.org/api/globals.html#class-abortcontroller |
| HTTP server/client behavior | https://nodejs.org/api/http.html |
| Streams and abort | https://nodejs.org/api/stream.html |
| Child process injection warning | https://nodejs.org/api/child_process.html |
| TypeScript basic strictness | https://www.typescriptlang.org/docs/handbook/2/basic-types.html |
| Type narrowing | https://www.typescriptlang.org/docs/handbook/2/narrowing.html |
| unknown | https://www.typescriptlang.org/docs/handbook/2/functions.html#unknown |

## HTTP and browser

| Topic | Source |
|---|---|
| HTTP semantics and idempotency | https://www.rfc-editor.org/rfc/rfc9110.html |
| 429 and Retry-After | https://datatracker.ietf.org/doc/html/rfc6585 |
| CORS | https://developer.mozilla.org/en-US/docs/Web/HTTP/Guides/CORS |
| Access-Control-Allow-Origin | https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/Access-Control-Allow-Origin |
| Credentialed CORS | https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/Access-Control-Allow-Credentials |
| Cache-Control | https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/Cache-Control |
| Fetch | https://developer.mozilla.org/en-US/docs/Web/API/Fetch_API/Using_Fetch |
| AbortSignal | https://developer.mozilla.org/en-US/docs/Web/API/AbortSignal |
| Cookies | https://developer.mozilla.org/en-US/docs/Web/HTTP/Guides/Cookies |

## OWASP

| Topic | Source |
|---|---|
| REST API security | https://cheatsheetseries.owasp.org/cheatsheets/REST_Security_Cheat_Sheet.html |
| Input validation | https://cheatsheetseries.owasp.org/cheatsheets/Input_Validation_Cheat_Sheet.html |
| Session management | https://cheatsheetseries.owasp.org/cheatsheets/Session_Management_Cheat_Sheet.html |
| Browser storage | https://cheatsheetseries.owasp.org/cheatsheets/HTML5_Security_Cheat_Sheet.html |
| CSRF | https://cheatsheetseries.owasp.org/cheatsheets/Cross-Site_Request_Forgery_Prevention_Cheat_Sheet.html |
| Logging | https://cheatsheetseries.owasp.org/cheatsheets/Logging_Cheat_Sheet.html |
| API Security Top 10 | https://owasp.org/API-Security/editions/2023/en/0x11-t10/ |
| Resource consumption | https://owasp.org/API-Security/editions/2023/en/0xa4-unrestricted-resource-consumption/ |

## Agent Skills

| Topic | Source |
|---|---|
| Open Agent Skills specification | https://agentskills.io/specification |
| OpenAI skill guidance | https://learn.chatgpt.com/docs/build-skills |
