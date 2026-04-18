#!/usr/bin/env node
// Generate a static HTML catalog page from skills/catalog.json
// Usage: node scripts/generate-catalog-html.cjs
// Output: skills/catalog.html (self-contained, no external deps)

const fs = require("fs");
const path = require("path");

const REPO_ROOT = path.resolve(__dirname, "..");
const CATALOG = path.join(REPO_ROOT, "skills/catalog.json");
const OUTPUT = path.join(REPO_ROOT, "skills/catalog.html");

if (!fs.existsSync(CATALOG)) {
  console.error("Missing catalog.json. Run catalog generator first.");
  process.exit(1);
}

const catalog = JSON.parse(fs.readFileSync(CATALOG, "utf8"));

const ideOrder = ["claude-code","antigravity","cursor","windsurf","copilot","continue","aider","zed","jetbrains","void"];
const ideIcons = {
  "claude-code": "Claude Code",
  "antigravity": "Antigravity",
  "cursor": "Cursor",
  "windsurf": "Windsurf",
  "copilot": "Copilot",
  "continue": "Continue",
  "aider": "Aider",
  "zed": "Zed",
  "jetbrains": "JetBrains",
  "void": "Void"
};

function escapeHtml(s) {
  return String(s).replace(/[&<>"']/g, (c) => ({
    "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;"
  }[c]));
}

function ideBadges(skill) {
  return ideOrder.filter(i => skill.ideSupport.includes(i))
    .map(i => `<span class="ide-badge" data-ide="${i}">${ideIcons[i]}</span>`)
    .join(" ");
}

const rows = catalog.skills.map(s => `
  <tr data-search="${escapeHtml(s.name + " " + s.description)}">
    <td class="skill-name"><code>nc-${escapeHtml(s.name.replace(/^nc-/, ""))}</code></td>
    <td class="skill-desc">${escapeHtml(s.description)}</td>
    <td class="ide-list">${ideBadges(s)}</td>
    <td class="meta">${s.loc} LOC${s.referenceFiles ? ` · ${s.referenceFiles} refs` : ""}</td>
  </tr>
`).join("");

const html = `<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<title>NEXTCORE-SKILLS Catalog — ${catalog.totalSkills} skills × ${catalog.supportedIdes.length} IDEs</title>
<meta name="viewport" content="width=device-width,initial-scale=1">
<style>
  body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; margin: 0; background: #0e1117; color: #e6edf3; }
  header { padding: 2rem; background: linear-gradient(135deg, #1a1d24, #0e1117); border-bottom: 1px solid #30363d; }
  header h1 { margin: 0 0 0.5rem; font-size: 1.8rem; }
  header p { margin: 0; color: #8b949e; }
  .controls { padding: 1rem 2rem; background: #161b22; display: flex; gap: 1rem; align-items: center; flex-wrap: wrap; border-bottom: 1px solid #30363d; }
  .controls input { flex: 1; min-width: 200px; padding: 0.5rem 0.75rem; background: #0d1117; color: #e6edf3; border: 1px solid #30363d; border-radius: 6px; font-size: 0.95rem; }
  .controls select { padding: 0.5rem 0.75rem; background: #0d1117; color: #e6edf3; border: 1px solid #30363d; border-radius: 6px; }
  .stats { display: flex; gap: 2rem; padding: 1.5rem 2rem; background: #161b22; }
  .stat { flex: 0; }
  .stat-num { font-size: 2rem; font-weight: bold; color: #7ee787; }
  .stat-label { color: #8b949e; font-size: 0.85rem; text-transform: uppercase; }
  table { width: 100%; border-collapse: collapse; }
  thead { background: #161b22; position: sticky; top: 0; }
  th, td { text-align: left; padding: 0.75rem 1rem; border-bottom: 1px solid #21262d; }
  th { color: #8b949e; font-weight: 600; font-size: 0.85rem; text-transform: uppercase; }
  tbody tr:hover { background: #161b22; }
  .skill-name code { color: #79c0ff; font-size: 0.95rem; }
  .skill-desc { color: #c9d1d9; font-size: 0.9rem; max-width: 40%; }
  .ide-badge { display: inline-block; padding: 0.15rem 0.5rem; margin: 0.1rem; background: #21262d; color: #8b949e; border-radius: 4px; font-size: 0.75rem; }
  .ide-badge[data-ide="claude-code"] { background: #cc785c; color: #fff; }
  .ide-badge[data-ide="antigravity"] { background: #4285f4; color: #fff; }
  .ide-badge[data-ide="cursor"] { background: #000; color: #fff; border: 1px solid #444; }
  .meta { color: #8b949e; font-size: 0.85rem; }
  footer { padding: 2rem; text-align: center; color: #8b949e; font-size: 0.9rem; border-top: 1px solid #30363d; }
  footer a { color: #79c0ff; }
</style>
</head>
<body>

<header>
  <h1>NEXTCORE-SKILLS Catalog</h1>
  <p>${catalog.totalSkills} skills · ${catalog.supportedIdes.length} IDEs supported · MIT licensed · generated ${new Date(catalog.generatedAt).toISOString().slice(0, 10)}</p>
</header>

<div class="stats">
  <div class="stat"><div class="stat-num">${catalog.totalSkills}</div><div class="stat-label">Skills</div></div>
  <div class="stat"><div class="stat-num">${catalog.supportedIdes.length}</div><div class="stat-label">IDEs</div></div>
  <div class="stat"><div class="stat-num">${catalog.skills.reduce((s, sk) => s + sk.ideSupport.length, 0)}</div><div class="stat-label">Total Coverage</div></div>
  <div class="stat"><div class="stat-num">${catalog.skills.reduce((s, sk) => s + sk.referenceFiles, 0)}</div><div class="stat-label">Reference Files</div></div>
</div>

<div class="controls">
  <input type="text" id="search" placeholder="Search skills by name or description..." />
  <select id="ide-filter">
    <option value="">All IDEs</option>
    ${ideOrder.map(i => `<option value="${i}">${ideIcons[i]}</option>`).join("")}
  </select>
</div>

<table>
  <thead>
    <tr><th>Skill</th><th>Description</th><th>IDE Support</th><th>Stats</th></tr>
  </thead>
  <tbody id="skill-rows">${rows}</tbody>
</table>

<footer>
  <p><a href="https://github.com/kennetvn/NEXTCORE-SKILLS">github.com/kennetvn/NEXTCORE-SKILLS</a> · <a href="../README.md">README</a> · <a href="../CONTRIBUTING.md">Contributing</a></p>
</footer>

<script>
  const search = document.getElementById('search');
  const ideFilter = document.getElementById('ide-filter');
  const rows = document.querySelectorAll('#skill-rows tr');

  function filter() {
    const q = search.value.toLowerCase();
    const ide = ideFilter.value;
    rows.forEach(row => {
      const matchText = !q || row.dataset.search.toLowerCase().includes(q);
      const matchIde = !ide || row.querySelector(\`[data-ide="\${ide}"]\`);
      row.style.display = (matchText && matchIde) ? '' : 'none';
    });
  }

  search.addEventListener('input', filter);
  ideFilter.addEventListener('change', filter);
</script>
</body>
</html>`;

fs.writeFileSync(OUTPUT, html, "utf8");
console.log(`catalog.html: ${html.length} bytes, ${catalog.totalSkills} skills`);
