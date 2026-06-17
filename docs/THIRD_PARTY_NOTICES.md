# Third-Party Notices

This repository does not vendor third-party source trees, release archives, binaries, or runtime payloads. Bootstrap/setup scripts download or clone external projects into ignored local folders.

## Core Toolchain

| Component | Upstream | License / notice |
|---|---|---|
| IDA Professional | Hex-Rays | Proprietary commercial software. User must provide a licensed install. Not redistributed. |
| idaxex / xex1tool | `https://github.com/emoose/idaxex` | BSD 3-Clause. Preserve upstream notices. |
| xbox-reversing | `https://github.com/emoose/xbox-reversing` | BSD 3-Clause. |
| Ghidra | `https://github.com/NationalSecurityAgency/ghidra` | Apache License 2.0. Not redistributed in this repo. |
| XEXLoaderWV | `https://github.com/zeroKilo/XEXLoaderWV` | Upstream checkout did not include a top-level license file at time of review. Keep attribution: X360 XEX Loader for Ghidra by Warranty Voider. Verify licensing before redistributing modified binaries. |
| LaurieWired GhidraMCP | `https://github.com/LaurieWired/GhidraMCP` | Apache License 2.0. |
| Model Context Protocol servers | `https://github.com/modelcontextprotocol/servers` | Upstream licensing transition from MIT to Apache-2.0; see upstream LICENSE. |

## Reference Sources

| Component | Upstream | License / notice |
|---|---|---|
| reverse-engineering-skill | `https://github.com/meirm/reverse-engineering-skill` | No license file found at time of review. Treat as reference only unless license is clarified. |
| claude-skills | `https://github.com/alirezarezvani/claude-skills` | MIT. |
| awesome-mcp-servers | `https://github.com/punkpeye/awesome-mcp-servers` | MIT. |
| awesome-mcp-servers-2 | `https://github.com/patriksimek/awesome-mcp-servers-2` | No license file found at time of review. Treat as reference only unless license is clarified. |
| win-cli-mcp-server | `https://github.com/SimonB97/win-cli-mcp-server` | MIT. |

## Redistribution Rules

- Do not commit downloaded archives, extracted runtimes, cloned third-party repos, IDA databases, XEX binaries, decrypted modules, or console assets.
- Preserve all upstream licenses and notices when modifying or redistributing third-party code.
- This repository's own scripts and documentation are MIT licensed unless stated otherwise.
