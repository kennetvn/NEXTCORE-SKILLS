#!/usr/bin/env node
// skills-deps-graph.cjs — visualize + check skill dependencies
// Usage:
//   node scripts/skills-deps-graph.cjs                    → mermaid (default)
//   node scripts/skills-deps-graph.cjs --format=dot       → graphviz DOT
//   node scripts/skills-deps-graph.cjs --skill nc-cook    → subgraph from one skill
//   node scripts/skills-deps-graph.cjs --check-circular   → exit 1 on cycles
//   node scripts/skills-deps-graph.cjs --json             → machine-readable

const fs = require("fs");
const path = require("path");

const REPO_ROOT = path.resolve(__dirname, "..");
const SKILLS_DIR = path.join(REPO_ROOT, "skills");

const args = process.argv.slice(2);
const opts = {
  format: "mermaid",
  skill: null,
  checkCircular: false,
  json: false
};
for (let i = 0; i < args.length; i++) {
  const a = args[i];
  if (a.startsWith("--format=")) opts.format = a.slice(9);
  else if (a === "--skill") opts.skill = args[++i];
  else if (a === "--check-circular") opts.checkCircular = true;
  else if (a === "--json") opts.json = true;
}

function parseFM(s) {
  const m = s.match(/^---\n([\s\S]*?)\n---/);
  if (!m) return {};
  const fm = {};
  const lines = m[1].split("\n");
  let currentList = null;
  for (const line of lines) {
    const kv = line.match(/^([\w-]+):\s*(.*)$/);
    const item = line.match(/^\s+-\s+(.*)$/);
    if (kv) {
      currentList = null;
      const val = kv[2].replace(/^"|"$/g, "").trim();
      if (val === "" || val === "[]") {
        fm[kv[1]] = [];
        currentList = kv[1];
      } else if (val.startsWith("[") && val.endsWith("]")) {
        fm[kv[1]] = val.slice(1, -1).split(",").map(s => s.trim().replace(/^["']|["']$/g, "")).filter(Boolean);
      } else {
        fm[kv[1]] = val;
      }
    } else if (item && currentList) {
      fm[currentList].push(item[1].replace(/^["']|["']$/g, ""));
    }
  }
  return fm;
}

// Parse Integration section as fallback when frontmatter has no depends_on
function parseIntegrationDeps(body) {
  const m = body.match(/##\s+Integration\s*\n([\s\S]*?)(?=\n##|\Z)/i);
  if (!m) return [];
  const deps = new Set();
  const re = /`(nc-[\w-]+)`/g;
  let match;
  while ((match = re.exec(m[1])) !== null) {
    deps.add(match[1]);
  }
  return Array.from(deps);
}

function loadSkills() {
  const dirs = fs.readdirSync(SKILLS_DIR, { withFileTypes: true })
    .filter(d => d.isDirectory())
    .map(d => d.name)
    .filter(n => fs.existsSync(path.join(SKILLS_DIR, n, "SKILL.md")))
    .sort();

  const skills = {};
  for (const name of dirs) {
    const raw = fs.readFileSync(path.join(SKILLS_DIR, name, "SKILL.md"), "utf8");
    const fm = parseFM(raw);
    const body = raw.replace(/^---\n[\s\S]*?\n---\n/, "");
    const ncName = "nc-" + name.replace(/^nc-/, "");
    const explicit = Array.isArray(fm.depends_on) ? fm.depends_on : [];
    const inferred = explicit.length === 0 ? parseIntegrationDeps(body) : [];
    skills[ncName] = {
      name: ncName,
      depends_on: explicit,
      inferred,
      suggests: Array.isArray(fm.suggests) ? fm.suggests : []
    };
  }
  return skills;
}

function detectCycles(skills) {
  const cycles = [];
  const WHITE = 0, GRAY = 1, BLACK = 2;
  const color = {};
  for (const name of Object.keys(skills)) color[name] = WHITE;

  function dfs(node, path) {
    color[node] = GRAY;
    // Only check explicit depends_on for circular detection; inferred deps from
    // Integration sections are bidirectional mentions, not real dependency cycles.
    const deps = skills[node]?.depends_on || [];
    for (const dep of deps) {
      if (color[dep] === GRAY) {
        const cycleStart = path.indexOf(dep);
        cycles.push(path.slice(cycleStart).concat(dep));
      } else if (color[dep] === WHITE && skills[dep]) {
        dfs(dep, path.concat(dep));
      }
    }
    color[node] = BLACK;
  }
  for (const name of Object.keys(skills)) {
    if (color[name] === WHITE) dfs(name, [name]);
  }
  return cycles;
}

function reachableFrom(skills, start, visited = new Set()) {
  if (visited.has(start)) return visited;
  visited.add(start);
  const deps = (skills[start]?.depends_on || []).concat(skills[start]?.suggests || []);
  for (const d of deps) reachableFrom(skills, d, visited);
  return visited;
}

function emitMermaid(skills, focusSkill) {
  const lines = ["```mermaid", "graph LR"];
  const subset = focusSkill ? Array.from(reachableFrom(skills, focusSkill)) : Object.keys(skills);
  for (const name of subset) {
    const s = skills[name];
    if (!s) continue;
    for (const dep of s.depends_on) {
      lines.push(`  ${name} --> ${dep}`);
    }
    for (const sug of s.suggests) {
      lines.push(`  ${name} -.-> ${sug}`);
    }
  }
  lines.push("```");
  return lines.join("\n");
}

function emitDot(skills) {
  const lines = ["digraph skills {", "  rankdir=LR;", "  node [shape=box];"];
  for (const [name, s] of Object.entries(skills)) {
    for (const dep of s.depends_on) lines.push(`  "${name}" -> "${dep}";`);
    for (const sug of s.suggests) lines.push(`  "${name}" -> "${sug}" [style=dashed];`);
  }
  lines.push("}");
  return lines.join("\n");
}

function main() {
  const skills = loadSkills();

  if (opts.checkCircular) {
    const cycles = detectCycles(skills);
    if (cycles.length === 0) {
      console.log(`OK: ${Object.keys(skills).length} skills, no circular dependencies.`);
      process.exit(0);
    }
    console.error(`FAIL: ${cycles.length} circular dependencies found:`);
    for (const cycle of cycles) console.error("  " + cycle.join(" → "));
    process.exit(1);
  }

  if (opts.json) {
    console.log(JSON.stringify({
      total: Object.keys(skills).length,
      skills: Object.values(skills),
      cycles: detectCycles(skills)
    }, null, 2));
    return;
  }

  const explicit = Object.values(skills).filter(s => s.depends_on.length > 0).length;
  const inferred = Object.values(skills).filter(s => s.depends_on.length === 0 && s.inferred.length > 0).length;
  console.error(`# Skills graph (${Object.keys(skills).length} skills, ${explicit} declared deps, ${inferred} inferred from Integration section)\n`);

  if (opts.format === "dot") {
    console.log(emitDot(skills));
  } else {
    console.log(emitMermaid(skills, opts.skill));
  }
}

main();
