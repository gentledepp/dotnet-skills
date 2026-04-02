# dotnet-skills

A curated collection of **.NET / C# skills** for [Claude Code](https://code.claude.com) — compiler-accurate code analysis, refactoring, and more.

## Installation

run claude code in your bash.

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
| **ilspy-mcp** | 8 tools for decompiling and analyzing compiled .NET assemblies (DLLs). Inspect NuGet packages, framework libraries, and third-party DLLs without source code. Decompile types/methods, list types, analyze architecture, find hierarchies, and search members. | `ILSpyMcp.Server` (.NET 9 global tool) |
| **dotnet-wsl** | Ensures dotnet commands (build, test, restore, run, tool, etc.) work correctly in WSL by routing them through the Windows `dotnet.exe` binary. Prevents NuGet fallback folder and SDK resolution failures on Windows-mounted drives. | — |
| **unit-tests** | Guided workflow for creating verified unit tests with a strict red/green cycle. One test per behavior, each verified to fail before the implementation and pass after. | — |

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
├── ilspy-mcp/           # ILSpy assembly decompilation
│   ├── SKILL.md
│   └── scripts/
├── dotnet-wsl/          # WSL dotnet command routing
│   └── SKILL.md
├── unit-tests/          # Guided unit test creation
│   └── SKILL.md
└── your-new-skill/      # ← add yours here
    └── SKILL.md
```

Then update the marketplace version in `.claude-plugin/marketplace.json` and push.

## License

MIT
