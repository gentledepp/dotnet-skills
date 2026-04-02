---
name: roslyn-mcp
description: >
  Self-installing Roslyn MCP Server skill (41 tools). Compiler-accurate C# code navigation,
  refactoring, analysis, generation, and conversion powered by Microsoft Roslyn.
  ALWAYS trigger when the user asks to: find references/usages, go to definition, resolve
  a type, get symbol info, search symbols by pattern, rename a symbol, extract method/
  interface/variable/base class, move type, change signature, inline variable, find callers,
  find implementations, get type hierarchy, analyze complexity/control flow/data flow,
  generate constructors/overrides/equals/hashcode, implement interface, convert to async/
  pattern matching/LINQ/string interpolation, or any C# code navigation or refactoring task.
  ALWAYS prefer this over grep/ripgrep for C# symbol lookups — Roslyn is semantically
  accurate and won't match comments or strings. When in doubt, trigger this skill.
---

# Roslyn MCP Server — Usage Guide for Claude Code

This skill enables Claude Code to perform **compiler-accurate C# code analysis and refactoring**
via the Roslyn MCP Server (NuGet: `RoslynMcp.Server`, command: `roslyn-mcp`), powered by
Microsoft Roslyn. It loads a `.sln` or `.csproj` and provides deep semantic understanding
of the entire codebase with **41 tools**.

---

## Bootstrap: Auto-Install & Configure

**Before using any Roslyn tool**, ensure the server is installed and the MCP connection
is configured. Follow these steps in order — skip any step that is already satisfied.

### Step 1: Install the dotnet tool (if missing)

Run the bootstrap script bundled with this skill:

```bash
# Linux / macOS / WSL:
bash "$(dirname "$0")/scripts/ensure-roslyn-mcp.sh"

# Windows PowerShell:
powershell -ExecutionPolicy Bypass -File "$(dirname "$0")/scripts/ensure-roslyn-mcp.ps1"
```

**Or equivalently**, run these commands directly:

```bash
# Check if already installed
dotnet tool list -g | grep -i RoslynMcp.Server

# If not found, install it (requires .NET 9.0+ SDK)
dotnet tool install -g RoslynMcp.Server
```

If the `dotnet` command is not found or the SDK version is below 9.0, inform the user
they need to install the .NET 9 SDK from https://dotnet.microsoft.com/download/dotnet/9.0

### Step 2: Ensure MCP server is registered

Check if `roslyn-refactor` (or any Roslyn MCP server) appears in the output of `/mcp`.
If not, register it:

**Per-project** (preferred) — create or update `.mcp.json` in the solution/repo root:

```json
{
  "mcpServers": {
    "roslyn-refactor": {
      "type": "stdio",
      "command": "roslyn-mcp",
      "args": []
    }
  }
}
```

**Or globally** via CLI:

```bash
claude mcp add roslyn-refactor --command "roslyn-mcp" --scope user
```

After adding the config, reconnect with `/mcp` or restart Claude Code.

### Step 3: Verify

Run the `diagnose` tool to confirm everything is working:

```
Use the roslyn-refactor diagnose tool for /absolute/path/to/MySolution.sln
```

A healthy response shows Roslyn version, MSBuild status, and loaded project/document counts.

---

## When to Use Roslyn MCP Tools

Use these tools whenever the task requires **semantic code understanding or compiler-accurate
refactoring** — not just text matching or manual edits.

### Trigger Patterns

**Code Navigation (read-only)**
- "Where is X used?" / "Find all references to X" → `find_references`
- "Go to definition of X" / "Show me where X is defined" → `go_to_definition`
- "What is X?" / "Show me the type info for X" → `get_symbol_info`
- "Find all implementations of IMyInterface" → `find_implementations`
- "Search for classes matching *Service" → `search_symbols`
- "Who calls this method?" → `find_callers`
- "Show me the type hierarchy of X" → `get_type_hierarchy`
- "Give me an outline of this file" → `get_document_outline`

**Analysis & Metrics (read-only)**
- "Show me compiler errors" / "Any warnings?" → `get_diagnostics`
- "What's the complexity of this method?" → `get_code_metrics`
- "Analyze the control flow of lines 10-30" → `analyze_control_flow`
- "What variables flow into this block?" → `analyze_data_flow`

**Refactoring (mutating — always preview first, confirm with user)**
- "Rename X to Y across the solution" → `rename_symbol`
- "Move this class to a new file" → `move_type_to_file`
- "Move this type to namespace X" → `move_type_to_namespace`
- "Extract this code into a method" → `extract_method`
- "Extract a variable / constant" → `extract_variable` / `extract_constant`
- "Extract an interface / base class" → `extract_interface` / `extract_base_class`
- "Inline this variable" → `inline_variable`
- "Change the method signature" → `change_signature`
- "Encapsulate this field as a property" → `encapsulate_field`
- "Add missing usings" / "Remove unused usings" → `add_missing_usings` / `remove_unused_usings`

**Code Generation (mutating)**
- "Generate a constructor" → `generate_constructor`
- "Implement IMyInterface" → `implement_interface`
- "Generate Equals and GetHashCode" → `generate_equals_hashcode`
- "Generate ToString" → `generate_tostring`
- "Add null checks to parameters" → `add_null_checks`
- "Generate override methods" → `generate_overrides`

**Code Conversion (mutating)**
- "Convert to async" → `convert_to_async`
- "Convert to expression body / block body" → `convert_expression_body`
- "Convert to full property / auto-property" → `convert_property`
- "Convert foreach to LINQ" → `convert_foreach_linq`
- "Convert to pattern matching" → `convert_to_pattern_matching`
- "Convert to string interpolation" → `convert_to_interpolated_string`
- "Promote variable to parameter" → `introduce_parameter`

---

## Tool Quick Reference

All tools accept `solutionPath` (absolute path to `.sln` or `.csproj`).
Refactoring/mutation tools also accept `preview` (bool) — **always use `preview: true` first**.

### Code Navigation (read-only)

- `find_references` — All usages of a symbol. Params: `sourceFile`, `symbolName`, `line`, `column`, `maxResults`
- `go_to_definition` — Jump to source definition. Params: `sourceFile`, `symbolName`, `line`, `column`
- `get_symbol_info` — Full metadata (kind, modifiers, base types, interfaces, members, params, docs). Params: `sourceFile`, `symbolName`, `line`, `column`
- `find_implementations` — Interface impls / virtual overrides. Params: `sourceFile`, `symbolName`, `line`, `column`, `maxResults`
- `search_symbols` — Pattern search, filter by kind. Params: `query`, `kindFilter`, `maxResults`
- `find_callers` — All callers of a symbol. Params: `sourceFile`, `symbolName`, `line`, `column`, `maxResults`
- `get_type_hierarchy` — Base/derived type chain. Params: `sourceFile`, `symbolName`, `line`, `column`, `direction`
- `get_document_outline` — Hierarchical file outline. Params: `sourceFile`

### Analysis & Metrics (read-only)

- `get_diagnostics` — Compiler errors/warnings. Params: `sourceFile`, `severityFilter`
- `get_code_metrics` — Complexity, LOC, maintainability, coupling, inheritance depth. Params: `sourceFile`, `symbolName`, `line`
- `analyze_control_flow` — Reachability, return statements, exit points. Params: `sourceFile`, `startLine`, `endLine`
- `analyze_data_flow` — Variables read/written, data in/out, captures. Params: `sourceFile`, `startLine`, `endLine`
- `diagnose` — Server health check. Params: `solutionPath` (optional), `verbose`

### Refactoring (mutating — use preview: true first)

- `rename_symbol` — Rename + update all refs. Params: `sourceFile`, `symbolName`, `newName`, `line`, `column`, `renameOverloads`, `renameFile`
- `move_type_to_file` — Move type to new file. Params: `sourceFile`, `symbolName`, `targetFile`, `createTargetFile`
- `move_type_to_namespace` — Change namespace + update usings. Params: `sourceFile`, `symbolName`, `targetNamespace`, `updateFileLocation`
- `extract_method` — Code region → new method. Params: `sourceFile`, `startLine`, `startColumn`, `endLine`, `endColumn`, `methodName`, `visibility`
- `extract_variable` — Expression → local variable. Params: `sourceFile`, `startLine`..`endColumn`, `variableName`, `useVar`
- `extract_constant` — Literal → named constant. Params: `sourceFile`, `startLine`..`endColumn`, `constantName`, `visibility`, `replaceAll`
- `extract_interface` — Class → interface. Params: `sourceFile`, `typeName`, `interfaceName`, `members`, `targetFile`
- `extract_base_class` — Members → base class. Params: `sourceFile`, `typeName`, `baseClassName`, `members`, `targetFile`, `makeAbstract`
- `inline_variable` — Replace variable with initializer. Params: `sourceFile`, `variableName`, `line`
- `change_signature` — Add/remove/reorder params + update call sites. Params: `sourceFile`, `methodName`, `parameters`, `line`
- `encapsulate_field` — Field → property with backing field. Params: `sourceFile`, `fieldName`, `propertyName`, `readOnly`

### Code Generation (mutating)

- `generate_constructor` — Constructor initializing fields/props. Params: `sourceFile`, `typeName`, `members`, `addNullChecks`
- `generate_overrides` — Override virtual/abstract members. Params: `sourceFile`, `typeName`, `members`, `callBase`
- `implement_interface` — Interface implementation stubs. Params: `sourceFile`, `typeName`, `interfaceName`, `explicitImplementation`, `members`
- `generate_equals_hashcode` — Equals() + GetHashCode(). Params: `sourceFile`, `typeName`, `fields`
- `generate_tostring` — ToString() override. Params: `sourceFile`, `typeName`, `fields`, `format`
- `add_null_checks` — Guard clauses for params. Params: `sourceFile`, `methodName`, `line`, `style`
- `format_document` — Roslyn formatting. Params: `sourceFile`

### Code Conversion (mutating)

- `convert_to_async` — Sync → async/await. Params: `sourceFile`, `methodName`, `line`, `renameToAsync`
- `convert_expression_body` — Expression ↔ block body. Params: `sourceFile`, `direction`, `memberName`, `line`
- `convert_property` — Auto-property ↔ full property. Params: `sourceFile`, `direction`, `propertyName`, `line`
- `convert_foreach_linq` — foreach + Add → LINQ. Params: `sourceFile`, `line`
- `convert_to_pattern_matching` — if/is → switch expression. Params: `sourceFile`, `line`
- `convert_to_interpolated_string` — string.Format/concat → $"...". Params: `sourceFile`, `line`
- `introduce_parameter` — Local variable → method parameter. Params: `sourceFile`, `variableName`, `line`

### Using Directives

- `add_missing_usings` — Add unresolved usings. Params: `sourceFile`, `allFiles`
- `remove_unused_usings` — Remove unused usings. Params: `sourceFile`, `allFiles`
- `sort_usings` — Sort alphabetically. Params: `sourceFile`

---

## How to Use the Tools Effectively

### Preferred Workflow

1. **Determine the solution path first.** Locate the `.sln` file.
   Use `find . -name "*.sln" -maxdepth 3` if unsure. All paths must be **absolute**.

2. **Run `diagnose` if something seems off.** It reports Roslyn version, MSBuild status,
   SDK availability, and whether the solution loads correctly.

3. **Navigate before refactoring.** Use `search_symbols`, `get_symbol_info`, `find_references`,
   and `find_callers` to understand the current state before making changes.

4. **Always preview refactoring first.** Use `preview: true` on the first attempt for any
   mutation tool. Show the user the diff before applying.

5. **Prefer Roslyn over grep/rg for C# analysis.** Never fall back to text search for C#
   symbol references when Roslyn is available.

6. **Use line/column for disambiguation.** If `symbolName` alone is ambiguous, provide
   `line` and `column` to pinpoint the exact occurrence in `sourceFile`.

7. **Combine tools for comprehensive answers.**
   - "How is the auth flow structured?" →
     1. `search_symbols(query: "*Auth*")` — discover types
     2. `get_symbol_info(symbolName: "AuthService")` — inspect
     3. `find_callers(symbolName: "AuthService.Authenticate")` — integration points
     4. `get_type_hierarchy(symbolName: "AuthService")` — inheritance

### Important: Confirm Before Mutating

All refactoring, generation, and conversion tools **modify files on disk**. Always:
- Explain what will change
- Use `preview: true` first when scope is unclear
- Ask the user for confirmation before applying
- Atomic writes with rollback are built in — if any write fails, all changes revert

### Updating the Tool

```bash
dotnet tool update -g RoslynMcp.Server
```

---

## When NOT to Use Roslyn MCP Tools

- Simple text search across non-C# files (use grep/rg)
- Questions about C# syntax or language features (use general knowledge)
- When the user explicitly asks for a text-based search
- Non-.NET projects (JavaScript, Python, etc.)
- Editing non-code files (README, configs, YAML)

## Language

The user communicates in both German and English. Respond in whichever language the user
is currently using. Symbol names in code are always English.
