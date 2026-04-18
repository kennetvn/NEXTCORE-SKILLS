#!/usr/bin/env node
// Converter: Claude Code skill -> Antigravity workflow
// Writes nc-{name}.md + copies references/ as nc-{name}/references/*.md

var fs = require("fs");
var path = require("path");

var REPO_ROOT = path.resolve(__dirname, "../..");
var SKILLS_DIR = path.join(REPO_ROOT, "skills");
var OUT_DIR = path.join(REPO_ROOT, "adapters/antigravity/workflows");

var ALLOWLIST = [
  "docs","docs-seeker","mermaidjs-v11","copywriting",
  "nc-security","nc-scenario","preview","ai-multimodal",
  "backend-development","frontend-development","react-best-practices",
  "ui-ux-pro-max","ui-styling","web-design-guidelines",
  "media-processing","tanstack","databases","payment-integration",
  "llms","web-testing",
  "nc-persona","nc-memory","nc-clarify","nc-explain","nc-mirror","nc-sentiment",
  "nc-skill-announce","nc-contribute","nc-install-tweaks","nc-company-os","nc-response-format",
  "nc-onboard"
];

function parseFrontmatter(content) {
  var m = content.match(/^---\n([\s\S]*?)\n---\n([\s\S]*)$/);
  if (!m) return { frontmatter: {}, body: content };
  var fm = {};
  var lines = m[1].split("\n");
  for (var i = 0; i < lines.length; i++) {
    var kv = lines[i].match(/^(\w[\w-]*):\s*(.*)$/);
    if (kv) fm[kv[1]] = kv[2].replace(/^"|"$/g, "");
  }
  return { frontmatter: fm, body: m[2] };
}

function convertBody(body, skillName) {
  var out = body;
  var refsPrefix = "nc-" + skillName.replace(/^nc-/, "") + "/references/";

  out = out.replace(/`Skill` tool/g, "workflow invocation");
  out = out.replace(/\bactivate\s+`?nc:([\w-]+)`?\s+skill/gi, "follow the `nc-$1` workflow");
  out = out.replace(/\binvoke\s+`?\/?nc:([\w-]+)`?\s+skill/gi, "follow the `nc-$1` workflow");
  out = out.replace(/\buse\s+`?nc:([\w-]+)`?\s+skill/gi, "follow the `nc-$1` workflow");
  out = out.replace(/`nc:([\w-]+)`\s+skill/g, "`nc-$1` workflow");
  out = out.replace(/\/nc:([\w-]+)/g, "/nc-$1");
  out = out.replace(/`nc:([\w-]+)`/g, "`nc-$1`");

  out = out.replace(/\binvoke\s+"?\/?([\w\-:]+)"?\s+skill/gi, "follow the `$1` workflow");
  out = out.replace(/\bactivate\s+"?\/?([\w\-:]+)"?\s+skill/gi, "follow the `$1` workflow");

  out = out.replace(/Use\s+`AskUserQuestion`\s+tool\s+to\s+/gi, "");
  out = out.replace(/`AskUserQuestion`\s+tool/g, "chat questions");
  out = out.replace(/use\s+`AskUserQuestion`/gi, "ask the user in chat");
  out = out.replace(/`AskUserQuestion`/g, "chat question");

  out = out.replace(/`WebSearch`\s+tool/g, "web search");
  out = out.replace(/`WebSearch`/g, "web search");

  var agentMap = {
    "researcher": "`ai-developer` workflow (research mode)",
    "planner": "`nc-plan` workflow",
    "debugger": "`nc-debug` workflow",
    "tester": "`ai-tester` workflow",
    "code-reviewer": "`ai-ux-reviewer` workflow",
    "fullstack-developer": "`ai-developer` workflow",
    "docs-manager": "`nc-docs` workflow",
    "brainstormer": "`nc-brainstorm` workflow"
  };
  out = out.replace(/\b(researcher|planner|debugger|tester|code-reviewer|fullstack-developer|docs-manager|brainstormer)\s+agent\b/g,
    function (_, a) { return agentMap[a] || ("`" + a + "` workflow"); });

  out = out.replace(/`\.claude\/\.nc\.json`/g, "`.agent/.nc.json` (or `.claude/.nc.json` fallback)");
  out = out.replace(/`\.claude\/rules\//g, "`<repo>/agent-rules/");

  if (/## Naming\b/.test(out) || /`Report:`\s*path/.test(out)) {
    out = out.replace(/`## Naming` section/gi, "`## Naming` section (if injected; otherwise fallback: `plans/reports/{type}-{YYMMDD}-{HHMM}-{slug}.md`)");
    out = out.replace(/`Report:`\s*path from .*?Naming.*?section/gi, "`Report:` path (fallback: `plans/reports/{type}-{YYMMDD}-{HHMM}-{slug}.md`)");
  }

  out = out.replace(/`TaskCreate\([^)]*\)`/g, "(track in markdown checklist)");
  out = out.replace(/`TaskUpdate\([^)]*\)`/g, "(update checklist item)");

  out = out.replace(/`references\/([\w\-\/\.]+\.md)`/g, "`" + refsPrefix + "$1`");
  out = out.replace(/\(references\/([\w\-\/\.]+\.md)\)/g, "(" + refsPrefix + "$1)");
  out = out.replace(/See\s+references\/([\w\-\/\.]+\.md)/gi, "See " + refsPrefix + "$1");

  return out;
}

function copyDir(src, dst) {
  if (!fs.existsSync(dst)) fs.mkdirSync(dst, { recursive: true });
  var entries = fs.readdirSync(src, { withFileTypes: true });
  for (var i = 0; i < entries.length; i++) {
    var e = entries[i];
    var s = path.join(src, e.name);
    var d = path.join(dst, e.name);
    if (e.isDirectory()) copyDir(s, d);
    else fs.copyFileSync(s, d);
  }
}

function convertSkill(skillName, dryRun) {
  var srcDir = path.join(SKILLS_DIR, skillName);
  var srcPath = path.join(srcDir, "SKILL.md");
  if (!fs.existsSync(srcPath)) { console.error("[skip] " + skillName); return false; }
  var src = fs.readFileSync(srcPath, "utf8");
  var parsed = parseFrontmatter(src);
  var desc = (parsed.frontmatter.description || ("Workflow: " + skillName)).replace(/^"|"$/g, "");
  var body = convertBody(parsed.body, skillName).trim();
  var baseName = "nc-" + skillName.replace(/^nc-/, "");
  var out = "---\ndescription: " + desc + "\n---\n\n" + body + "\n";
  var outPath = path.join(OUT_DIR, baseName + ".md");
  if (dryRun) { console.log("=== " + baseName + ".md ===\n" + out.slice(0, 400)); return true; }
  fs.writeFileSync(outPath, out, "utf8");
  var refsSrc = path.join(srcDir, "references");
  var refCount = 0;
  if (fs.existsSync(refsSrc)) {
    var refsDst = path.join(OUT_DIR, baseName, "references");
    copyDir(refsSrc, refsDst);
    refCount = fs.readdirSync(refsDst).length;
  }
  console.log("[ok] " + skillName + " -> " + baseName + ".md" + (refCount ? " + " + refCount + " refs" : ""));
  return true;
}

var args = process.argv.slice(2);
if (args.length === 0) {
  console.log("Usage: node converter.cjs <skill>|--all|--list a,b|--dry-run <skill>");
  console.log("Allowlist (" + ALLOWLIST.length + "): " + ALLOWLIST.join(", "));
  process.exit(0);
}

var targets = [];
var dryRun = false;
for (var i = 0; i < args.length; i++) {
  var a = args[i];
  if (a === "--all") targets = ALLOWLIST.slice();
  else if (a === "--dry-run") dryRun = true;
  else if (a === "--list") targets = args[++i].split(",").map(function (s) { return s.trim(); }).filter(Boolean);
  else targets.push(a);
}
if (!fs.existsSync(OUT_DIR)) fs.mkdirSync(OUT_DIR, { recursive: true });
var ok = 0, fail = 0;
for (var j = 0; j < targets.length; j++) {
  if (convertSkill(targets[j], dryRun)) ok++; else fail++;
}
console.log("\nDone: " + ok + " converted, " + fail + " skipped");
