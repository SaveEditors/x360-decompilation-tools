# Tool Inventory

This repo tracks installers, setup glue, and workflow scripts. It does not redistribute third-party binaries or proprietary inputs.

## Core Stack

| Tool | Purpose | Source / requirement |
|---|---|---|
| IDA Professional | Primary decompiler host for full pseudocode output | User-provided commercial install |
| idaxex | IDA XEX/XBE loader and `xex1tool` helper | `https://github.com/emoose/idaxex` |
| Ghidra | Secondary analysis/decompiler and headless automation | `https://github.com/NationalSecurityAgency/ghidra` |
| XEXLoaderWV | Ghidra XEX loader rebuilt locally for the selected Ghidra/JDK version | `https://github.com/zeroKilo/XEXLoaderWV` |
| LaurieWired GhidraMCP | Ghidra MCP bridge/plugin | `https://github.com/LaurieWired/GhidraMCP` |
| JDK 21 | Ghidra runtime/build dependency | User-installed distribution such as Adoptium |
| Maven | Java build dependency | `https://maven.apache.org` |

## Reference Sources

| Source | Use |
|---|---|
| `https://github.com/emoose/xbox-reversing` | Xbox 360 imports, templates, and analysis helpers |
| `https://github.com/modelcontextprotocol/servers` | MCP server examples and references |
| `https://github.com/SimonB97/win-cli-mcp-server` | Windows CLI MCP reference |
| `https://github.com/punkpeye/awesome-mcp-servers` | MCP server catalog |
| `https://github.com/patriksimek/awesome-mcp-servers-2` | MCP server catalog |
| `https://github.com/meirm/reverse-engineering-skill` | Reverse-engineering workflow reference |
| `https://github.com/alirezarezvani/claude-skills` | Agent workflow reference |

## Local Install Folders

Bootstrap/setup uses ignored folders under the selected workspace root:

```text
downloads/
repos/
runtime/
ghidra/
venvs/
workspace/
xbox360/bin/
```

Use `docs/THIRD_PARTY_NOTICES.md` before redistributing any third-party code or binaries.
