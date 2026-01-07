# Claude Code Rules Directory

This directory contains modular, topic-specific instructions for Claude Code.

## Structure

All `.md` files in this directory are automatically loaded into Claude's context.

### Current Rules

- **`web-environment.md`** - Guidelines for Claude Code web instances
- **`local-environment.md`** - Guidelines for Claude Code CLI
- (Add more topic-specific rules as needed)

## Creating New Rules

Rules files can optionally include frontmatter to scope their applicability:

```markdown
---
paths: src/**/*.ts
---

# TypeScript Guidelines
...
```

Without frontmatter, rules apply to the entire project.

## Rule Organization

Organize by topic:
- Environment-specific (web vs CLI)
- Language-specific (TypeScript, Ruby, etc.)
- Domain-specific (testing, deployment, etc.)
- Tool-specific (git, docker, etc.)

## Benefits

- **Modular**: Each file focuses on one topic
- **Maintainable**: Easier to update specific guidelines
- **Discoverable**: Clear file names make intent obvious
- **Scalable**: Add rules without cluttering main CLAUDE.md
