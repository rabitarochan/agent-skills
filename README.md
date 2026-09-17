# agent-skills

A self-contained Claude Code plugin marketplace.

日本語のドキュメントは [README-ja.md](README-ja.md) を参照してください。

## Plugins

| Plugin | What it does | Docs |
|---|---|---|
| `skdd` | **Skill Driven Development** — crystallize reusable work patterns into Skills and grow them with their **Why** attached. Installs a harvest engine into each project. | [plugins/skdd](plugins/skdd/README.md) |
| `design-docs` | Work a design out in dialogue — a new project, a feature, or a single architectural decision — then write it up as a design document or an ADR. | [plugins/design-docs](plugins/design-docs/README.md) |

## Install

```
claude plugin marketplace add rabitarochan/agent-skills
claude plugin install skdd@agent-skills
claude plugin install design-docs@agent-skills
```

Install only the plugins you want — the two are independent.

For local development:

```
claude plugin marketplace add /path/to/agent-skills
```

> The repository is being renamed from `agent-skdd` to `agent-skills`. Until the
> rename lands, `claude plugin marketplace add rabitarochan/agent-skdd` still
> resolves; the marketplace it registers is already named `agent-skills`, so the
> `<plugin>@agent-skills` install commands above are correct either way.

## Repository layout

- `.claude-plugin/marketplace.json` — the marketplace manifest
- `plugins/<name>/` — one directory per plugin, each with its own
  `.claude-plugin/plugin.json` and README
- `README-ja.md` — Japanese documentation for everything here

Each plugin is versioned independently in its own `plugin.json`.

## License

MIT
