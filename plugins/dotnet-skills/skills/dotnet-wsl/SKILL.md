---
name: dotnet-wsl
description: >
  MUST be used whenever running dotnet commands (build, test, restore, run, tool, etc.)
  from a WSL (Windows Subsystem for Linux) environment. The Linux dotnet CLI cannot resolve
  Windows NuGet fallback folders or Windows-native SDK paths, causing build failures.
  Instead, invoke the Windows dotnet.exe binary directly via its full path.
  TRIGGER: any dotnet command when the platform is WSL (check uname -r for "microsoft" or
  "WSL", or when the working directory is under /mnt/c/ or similar Windows mount).
---

# dotnet-wsl -- Running .NET Commands from WSL

When working in WSL with repositories on Windows-mounted drives (`/mnt/c/`, `/mnt/d/`, etc.),
the Linux `dotnet` CLI will fail with errors like:

- `Unable to find fallback package folder 'C:\Program Files\dotnet\sdk\NuGetFallbackFolder'`
- SDK resolution failures or missing workload errors

This happens because the Linux dotnet cannot resolve Windows-specific NuGet cache paths
and SDK locations referenced in `project.assets.json` and `nuget.config`.

## Solution

Use the **Windows dotnet.exe** binary directly:

```bash
"/mnt/c/Program Files/dotnet/dotnet.exe"
```

## Examples

### Build

```bash
"/mnt/c/Program Files/dotnet/dotnet.exe" build MySolution.sln
```

### Run tests

```bash
"/mnt/c/Program Files/dotnet/dotnet.exe" test tests/MyProject.UnitTests --filter "FullyQualifiedName~MyTestClass"
```

### Run tests (no restore)

```bash
"/mnt/c/Program Files/dotnet/dotnet.exe" test tests/MyProject.UnitTests --filter "FullyQualifiedName~MyTestClass" --no-restore
```

### Restore packages

```bash
"/mnt/c/Program Files/dotnet/dotnet.exe" restore
```

### Run a project

```bash
"/mnt/c/Program Files/dotnet/dotnet.exe" run --project src/MyApp
```

### Install/update a global tool

```bash
"/mnt/c/Program Files/dotnet/dotnet.exe" tool install -g SomeTool
```

## Detection

You are in WSL if any of the following are true:

- `uname -r` contains `microsoft` or `WSL`
- The working directory is under `/mnt/c/` (or another Windows drive mount)
- The environment variable `$WSL_DISTRO_NAME` is set

## Important

- Always quote the path because it contains spaces: `"/mnt/c/Program Files/dotnet/dotnet.exe"`
- All other arguments and flags work identically to the Linux `dotnet` CLI
- Paths passed as arguments can use Linux-style `/mnt/c/...` paths -- Windows dotnet.exe handles the translation
- If `dotnet.exe` is not found at the default location, try: `which dotnet.exe` or check `"/mnt/c/Program Files (x86)/dotnet/dotnet.exe"`
