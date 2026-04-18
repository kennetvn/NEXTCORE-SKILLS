#!/usr/bin/env node
// validate-skills.cjs — static checks for all SKILL.md files
// Usage: node scripts/validate-skills.cjs [--json]
// Exit code: 0 = all pass, 1 = any errors, 2 = warnings only

const fs = require("fs");
const path = require("path");

const REPO_ROOT = path.resolve(__dirname, "..");
const SKILLS_DIR = path.join(REPO_ROOT, "skills");

const jsonMode = process.argv.includes("--json");

function parseFM(content) {
  const m = content.match(/^---\n([\s\S]*?)\n---\n?([\s\S]*)?$/);
  if (!m) return { fm: null, body: content };
  const fm = {};
  for (const line of m[1].split("\n")) {
    const kv = line.match(/^([\w-]+):\s*(.*)$/);
    if (kv) fm[kv[1]] = kv[2].replace(/^"|"$/g, "");
  }
  return { fm, body: m[2] || "" };
}

function validateSkill(name) {
  const dir = path.join(SKILLS_DIR, name);
  const skillPath = path.join(dir, "SKILL.md");
  const errors = [];
  const warnings = [];

  if (!fs.existsSync(skillPath)) {
    errors.push("missing SKILL.md");
    return { name, errors, warnings };
  }

  const raw = fs.readFileSync(skillPath, "utf8");
  const { fm, body } = parseFM(raw);

  // Frontmatter checks
  if (!fm) {
    errors.push("no frontmatter");
    return { name, errors, warnings };
  }
  if (!fm.name) errors.push("frontmatter missing 'name'");
  if (!fm.description) errors.push("frontmatter missing 'description'");
  if (!fm.license) warnings.push("frontmatter missing 'license' (recommended: MIT)");

  // Name consistency
  if (fm.name) {
    const expected = "nc:" + name.replace(/^nc-/, "");
    const expectedPlain = name;
    if (fm.name !== expected && fm.name !== expectedPlain) {
      warnings.push(`frontmatter name '${fm.name}' should match dir '${name}' (expected '${expected}')`);
    }
  }

  // Description quality
  if (fm.description) {
    if (fm.description.length < 30) warnings.push("description too short (<30 chars)");
    if (fm.description.length > 400) warnings.push("description too long (>400 chars)");
    if (!/use when|when to use|activates? when/i.test(fm.description)) {
      warnings.push("description should include 'Use when ...' trigger phrasing");
    }
  }

  // Body checks
  if (!body || body.trim().length < 100) {
    errors.push("body too short (<100 chars)");
  }
  if (body && !/^#\s+/m.test(body)) {
    warnings.push("body should start with H1 heading");
  }

  // Reference link integrity
  const refsDir = path.join(dir, "references");
  const refsExist = fs.existsSync(refsDir);
  const referenced = new Set();
  const refRegex = /references\/([\w\-\/.]+\.md)/g;
  let match;
  while ((match = refRegex.exec(body)) !== null) {
    referenced.add(match[1]);
  }
  for (const ref of referenced) {
    const refPath = path.join(refsDir, ref);
    if (!fs.existsSync(refPath)) {
      errors.push(`broken reference: references/${ref}`);
    }
  }
  if (refsExist && referenced.size === 0) {
    const refFiles = fs.readdirSync(refsDir).filter(f => f.endsWith(".md"));
    if (refFiles.length > 0) {
      warnings.push(`has references/ with ${refFiles.length} files but body doesn't link any`);
    }
  }

  // Integration section recommended
  if (!/##\s+Integration/im.test(body)) {
    warnings.push("missing '## Integration' section (recommended for skill discoverability)");
  }

  return { name, errors, warnings };
}

function main() {
  const skillNames = fs.readdirSync(SKILLS_DIR, { withFileTypes: true })
    .filter(d => d.isDirectory())
    .map(d => d.name)
    .filter(n => fs.existsSync(path.join(SKILLS_DIR, n, "SKILL.md")))
    .sort();

  const results = skillNames.map(validateSkill);
  const totalErrors = results.reduce((s, r) => s + r.errors.length, 0);
  const totalWarnings = results.reduce((s, r) => s + r.warnings.length, 0);
  const okSkills = results.filter(r => r.errors.length === 0 && r.warnings.length === 0).length;

  if (jsonMode) {
    console.log(JSON.stringify({
      total: skillNames.length,
      pass: okSkills,
      errors: totalErrors,
      warnings: totalWarnings,
      results: results.filter(r => r.errors.length || r.warnings.length)
    }, null, 2));
  } else {
    console.log(`NEXTCORE-SKILLS validator — ${skillNames.length} skills checked\n`);
    for (const r of results) {
      if (r.errors.length === 0 && r.warnings.length === 0) continue;
      const tag = r.errors.length > 0 ? "FAIL" : "warn";
      console.log(`[${tag}] ${r.name}`);
      for (const e of r.errors) console.log(`  ✗ ${e}`);
      for (const w of r.warnings) console.log(`  ! ${w}`);
    }
    console.log(`\nSummary: ${okSkills}/${skillNames.length} clean, ${totalErrors} errors, ${totalWarnings} warnings`);
  }

  if (totalErrors > 0) process.exit(1);
  if (totalWarnings > 0) process.exit(2);
  process.exit(0);
}

main();
