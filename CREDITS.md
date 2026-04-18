# Credits

## Architecture inspiration

General patterns in the Claude Code ecosystem (YAML-frontmatter skills, file-based hooks, configuration-driven behavior) were popularized by [prior ecosystem work](https://prior ecosystem work). We acknowledge prior ecosystem work contribution to normalizing these conventions.

**No code is derived** from prior ecosystem work. See [ATTRIBUTION.md](./ATTRIBUTION.md) for the clean-room audit.

## NEXTCORE-SKILLS own contributions

### Framework

- Install system with IDE-aware branches supporting 5 IDEs
- Cross-IDE adapter layer with single-source + derived pattern
- Converter script auto-transforming Claude Code skills
- Directory structure + naming conventions (nc: prefix, .nc.json config)

### Domain skills (NextCore-authored)

- nextcore-design, nextjs-api, prisma-helper
- facebook-dom, chrome-extension-dev
- deploy-vps (VPS <YOUR_VPS_IP> + your hosting panel)
- payment-integration (SePay, Stripe, Paddle, Polar, Creem)

### Commands (NextCore-authored)

- /pair, /standup, /ux-audit, /tm, /team-stop, /website, /extensions

### Hooks + infrastructure

- Session init, privacy filter, scout block, skill dedup
- Self-improvement hub + agent board + retrospective
- NextCore-branded statusline
