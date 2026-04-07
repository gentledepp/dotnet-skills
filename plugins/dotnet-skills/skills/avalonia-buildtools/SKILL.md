---
name: avalonia-buildtools
description: >
  Avalonia Build MCP Server skill (5 tools + 4 prompts). Remote server providing direct
  access to Avalonia documentation, API references, expert development rules, and migration
  guidance. Free — no license key or local installation required.
  TRIGGER when the user asks to: search Avalonia documentation, look up an Avalonia API
  (class, property, method, event), get Avalonia development best practices or rules,
  create a new Avalonia project, migrate from WPF to Avalonia/XPF, migrate from deprecated
  Avalonia.Diagnostics to current DevTools, design an Avalonia UI from a screenshot,
  understand AXAML syntax, learn about Avalonia property systems, styling, binding, MVVM,
  custom controls, or get guidance on common Avalonia mistakes.
  ALWAYS use this skill before answering Avalonia-related questions from general knowledge —
  the documentation tools provide up-to-date, authoritative answers.
---

# Avalonia Build MCP Server — Usage Guide for Claude Code

This skill enables Claude Code to access **Avalonia documentation, API references, expert
development rules, and migration guidance** via the Avalonia Build MCP Server — a remote
HTTP server at `https://docs-mcp.avaloniaui.net/mcp`.

**Free to use** — no license key or local dotnet tool installation required.

---

## Bootstrap: Configure MCP Connection

**Before using any Build MCP tool**, ensure the MCP connection is configured. No tool
installation is needed — this is a remote server.

### Step 1: Ensure MCP server is registered

Check if `avalonia-docs` appears in the output of `/mcp`.
If not, register it:

**Per-project** (preferred) — create or update `.mcp.json` in the solution/repo root:

```json
{
  "mcpServers": {
    "avalonia-docs": {
      "type": "http",
      "url": "https://docs-mcp.avaloniaui.net/mcp"
    }
  }
}
```

**Or globally** via CLI:

```bash
claude mcp add --transport http avalonia-docs https://docs-mcp.avaloniaui.net/mcp
```

After adding the config, reconnect with `/mcp` or restart Claude Code.

### Step 2: Verify

Test with a simple documentation query:

```
Use the avalonia-docs search_avalonia_docs tool to search for "data binding"
```

---

## Tool Quick Reference

### Documentation & API

- `search_avalonia_docs` — Search the full Avalonia documentation including API references,
  tutorials, and guides. Use this as the **first step** for any Avalonia question.

- `lookup_avalonia_api` — Look up a specific Avalonia class, property, method, or event.
  More targeted than `search_avalonia_docs` — use when you know the exact API name.
  Examples: `TextBlock`, `Window.Show`, `StyledProperty`, `Button.Click`

- `get_avalonia_expert_rules` — Returns comprehensive development rules covering AXAML
  syntax, property systems, styling, binding, MVVM, custom controls, and common mistakes.
  Use this before writing Avalonia code to ensure best practices.

### Migration

- `migrate_diagnostics` — Step-by-step guidance for setting up current Developer Tools
  packages and removing the deprecated `Avalonia.Diagnostics` package.

- `migrate_to_xpf` — Walks through WPF-to-Avalonia migration via XPF, including NuGet
  configuration and license setup.

---

## Available Prompts

The Build MCP server also provides prompts for guided workflows:

- **`init`** — Initialize an expert session for an existing Avalonia project. Use when
  starting work on an existing codebase.

- **`new`** — Guided new Avalonia app creation. Accepts an optional `app_name` parameter.
  Use when the user wants to create a new Avalonia project from scratch.

- **`recreate-ui`** — Iterative UI design workflow from screenshots. Accepts a `theme`
  parameter. **Note:** Requires a paid Avalonia Accelerate license and the DevTools MCP
  server (see the `avalonia-devtools` skill).

- **`wpf-migration`** — Analyzes WPF projects and recommends migration paths. Use as a
  starting point before `migrate_to_xpf`.

---

## How to Use the Tools Effectively

### Before Writing Any Avalonia Code

1. **Get the expert rules first:** Call `get_avalonia_expert_rules` to load best practices
   before writing AXAML, controls, styles, or bindings. This prevents common mistakes.

2. **Search docs for unfamiliar APIs:** Use `search_avalonia_docs` before relying on
   general knowledge — Avalonia APIs differ from WPF in subtle but important ways.

3. **Look up specific APIs:** Use `lookup_avalonia_api` when you need precise details
   about a class, property, or event (e.g., signatures, inheritance, usage examples).

### Answering Avalonia Questions

Always prefer Build MCP tools over general knowledge for Avalonia-specific questions:

- "How does data binding work in Avalonia?" → `search_avalonia_docs("data binding")`
- "What properties does TextBlock have?" → `lookup_avalonia_api("TextBlock")`
- "What are the best practices for styling?" → `get_avalonia_expert_rules`
- "How do I migrate from WPF?" → `migrate_to_xpf` or the `wpf-migration` prompt

### Creating New Projects

Use the `new` prompt for guided project creation:

1. Call the `new` prompt with the desired app name
2. Follow the guided workflow to select project template and options
3. Use `get_avalonia_expert_rules` to ensure the generated code follows best practices

### Combining with Other Skills

- **With `avalonia-devtools`:** Use Build MCP for documentation and rules, then DevTools
  to verify the UI at runtime (inspect tree, take screenshots, test interactions).
- **With `roslyn-mcp`:** Use Build MCP for Avalonia-specific guidance, then Roslyn for
  C# code analysis and refactoring of the code-behind.

---

## When NOT to Use Avalonia Build MCP

- **Runtime UI inspection** — use `avalonia-devtools` instead (requires running app)
- **C# code analysis or refactoring** — use `roslyn-mcp`
- **Decompiling DLLs** — use `ilspy-mcp`
- **Non-Avalonia frameworks** (WPF-only questions without migration intent, WinForms, MAUI)
- **General .NET questions** unrelated to Avalonia

## Language

The user communicates in both German and English. Respond in whichever language the user
is currently using. Symbol names in code are always English.
