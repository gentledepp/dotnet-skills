# dotnet-skills

A curated collection of **.NET / C# skills** for [Claude Code](https://code.claude.com) — compiler-accurate code analysis, refactoring, and more.

## Installation

```bash
# 1. Add the marketplace
/plugin marketplace add Gentledepp/dotnet-skills

# 2. Install the plugin (includes all skills)
/plugin install dotnet-skills@dotnet-skills
```

That's it. Skills auto-trigger when relevant and auto-install required tools on first use.

## Included Skills

| Skill | Description | Auto-installs |
|-------|-------------|---------------|
| **roslyn-mcp** | 41 Roslyn-powered tools for C# code navigation, refactoring, code generation, and syntax conversion. Find references, go to definition, rename symbols, extract methods, convert to async, and much more — all compiler-accurate. | `RoslynMcp.Server` (.NET 9 global tool) |

## Prerequisites

- [Claude Code](https://code.claude.com) CLI
- [.NET 9.0 SDK](https://dotnet.microsoft.com/download/dotnet/9.0) or later

## Updating

```bash
/plugin marketplace update
```

## Adding Your Own Skills

Fork this repo and add a new folder under `plugins/dotnet-skills/skills/`:

```
plugins/dotnet-skills/skills/
├── roslyn-mcp/          # Roslyn code analysis & refactoring
│   ├── SKILL.md
│   └── scripts/
└── your-new-skill/      # ← add yours here
    └── SKILL.md
```

Then update the marketplace version in `.claude-plugin/marketplace.json` and push.

## License

MIT
