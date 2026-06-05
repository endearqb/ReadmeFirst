# ReadmeFirst Source

Canonical repository: `endearqb/ReadmeFirst`

- Repository URL: https://github.com/endearqb/ReadmeFirst
- `README.md`: explains README First principles, architecture, file responsibilities, and rollout route.
- `AGENTS.md`: contains the executable agent protocol to copy or merge into a target project's root `AGENTS.md` during initialization.
- `.ai/architecture/README.md`: explains the current architecture context layer and how stable architecture knowledge is organized.

Use the GitHub app or raw GitHub URLs to inspect the latest versions when initializing a project:

- https://raw.githubusercontent.com/endearqb/ReadmeFirst/main/README.md
- https://raw.githubusercontent.com/endearqb/ReadmeFirst/main/AGENTS.md
- https://raw.githubusercontent.com/endearqb/ReadmeFirst/main/.ai/architecture/README.md

Initialization intent:

1. Bootstrap the target project with a durable context protocol.
2. Put operational rules in the target project's `AGENTS.md`.
3. Add a current architecture context layer under `.ai/architecture/`.
4. Keep this skill out of normal post-initialization work; future agents should read the target project's `AGENTS.md` directly.
