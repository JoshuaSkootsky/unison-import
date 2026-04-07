# @skootsky/unison-import

```
The file was here, and then it moved —
but still the code is what it was.
We called it by where it had been,
but names are lies, and paths descend
from accidents of where we placed
the letters, not what they comprised.

What if we named the thing itself?
Not where it lives, but what it is —
a hash that stays when files are renamed,
when directories are reorganized,
when AI agents reshape the code
and leave no broken imports behind.

The name is not the thing.
The path is not the truth.
Only the hash remains unchanged,
the mathematical fingerprint
of what the code actually does.
```

**Content-addressed imports for JavaScript.** Import by what code *is*, not where it *lives*.

Inspired by [Unison](https://www.unison-lang.org/)—a language where code is content-addressed by default—this brings the same property to TypeScript and Vite. Rename files, split modules, refactor freely: your imports stay stable because they're tied to the *hash of the code*, not the *path of the file*.

## The Problem

Vite (and all bundlers) is path-based:
```tsx
import { Button } from './components.tsx'  // brittle — rename the file, break all imports
```

The "name" (file path) is a lie about where the actual value lives. Refactoring breaks imports.

## The Solution

Content addressing: import by hash of the code itself.

```tsx
// Import by content identity, not file path
import { Button } from 'content:Button@1b366dbb7e75031a'
```

Move `components.tsx` anywhere — the hash stays the same, imports keep working.

## Status

| Feature | State | Notes |
|:---|:---|:---|
| Core hashing | ✅ Stable | AST-normalized, collision-detected |
| Vite resolution | ✅ Stable | Virtual module pattern |
| TypeScript IDE | ⚠️ Partial | Ambient declarations (`--types` flag) |
| Watch mode | 🚧 Planned | Chokidar integration |
| Build caching | 🚧 Planned | Content-hash as cache key |

**Current best for:** AI-assisted refactoring, library development, experiments in content-addressing.

**Not yet for:** Production apps requiring watch-mode DX.

## Installation

```bash
npm install @skootsky/unison-import-vite
npm install --save-dev @skootsky/unison-import-cli @skootsky/unison-import-ast
```

## Quick Start

### 1. Configure Vite

```ts
// vite.config.ts
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import { contentAddressedPlugin } from '@skootsky/unison-import-vite'

export default defineConfig({
  plugins: [
    react(),
    contentAddressedPlugin({ registryPath: './content-registry.json' }),
  ],
})
```

### 2. Generate Registry

```bash
# Scan src/ and generate content-registry.json
unison-import scan

# Also generate TypeScript ambient declarations
unison-import scan --types ./src/content-types.d.ts
```

### 3. Use Content Imports

```tsx
// Instead of: import { Button } from './components'
import { Button } from 'content:Button@1b366dbb7e75031a'
```

## CLI Options

```bash
unison-import scan [options]

Options:
  --types <path>    Generate ambient type declarations
  --registry <path> Custom registry output path (default: ./content-registry.json)
  --src <dir>       Source directory (default: src)
```

## Packages

| Package | Purpose |
|---------|---------|
| `@skootsky/unison-import-ast` | AST normalization + per-export hashing |
| `@skootsky/unison-import-cli` | CLI for scanning exports → registry |
| `@skootsky/unison-import-vite` | Vite plugin for resolving content: imports |

## How It Works

1. **AST Hasher** — Parse each export, normalize identifiers (rename user vars to `a, b, c...`), strip types, hash: `SHA256(exportName + ":" + canonicalCode)`
2. **CLI Scanner** — Scan `src/`, extract exports, generate `content-registry.json`
3. **Vite Plugin** — Intercept `content:Name@hash`, resolve to actual file via registry

## Why This Matters

This is the "Unison-style" content addressing applied to 2026 frontend tooling. For AI-agent refactoring:

- Rename a file → imports don't break (hash is content, not path)
- Move components to new directory → imports don't break
- AI agent refactors code → updates registry, not 47 import statements

The "name" is a lie. The hash is the truth.

## License

MIT

## Publishing

This monorepo uses [Changesets](https://github.com/changesets/changesets) for version management and publishing.

### Workflow

```bash
# Step 1: After making changes, document what changed
npm run change

# Step 2: When ready to release, bump versions and generate CHANGELOGs
npm run version-packages

# Step 3: Build and publish to npm (requires OTP from your authenticator app)
npx changeset publish --otp=123456
```

### How it works

1. **`npm run change`** — Interactive command. Select which packages changed, choose semver bump type (patch/minor/major), and provide a summary. Creates a changeset file in `.changeset/`.

2. **`npm run version-packages`** — Reads all changeset files, updates versions in `package.json`, auto-updates internal dependencies (e.g., if `ast` is bumped, `cli`'s dependency on `ast` updates automatically), and generates/updates `CHANGELOG.md` for each package.

3. **`npx changeset publish`** — Publishes only packages that had their versions bumped. You'll need to provide an OTP (one-time password) from your authenticator app if your npm account has 2FA enabled.

### Notes

- The `.changeset/` folder should be committed to git (contains your changeset files)
- The generated `CHANGELOG.md` files should be committed
- If you only changed one package, only that package gets version-bumped and published
- Use `--dry-run` to preview what would be published without actually publishing
