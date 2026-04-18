#!/usr/bin/env node
// build-all.cjs - Regenerate all IDE adapters from skills/ source of truth.
// Usage: node adapters/build-all.cjs [--ide=<name>] [--clean]

var fs = require("fs");
var path = require("path");
var cp = require("child_process");

var REPO_ROOT = path.resolve(__dirname, "..");
var SKILLS_DIR = path.join(REPO_ROOT, "skills");
var ADAPTERS_DIR = path.join(REPO_ROOT, "adapters");

var args = process.argv.slice(2);
var targetIde = null;
var clean = false;
for (var i = 0; i < args.length; i++) {
  if (args[i] === "--clean") clean = true;
  else if (args[i].indexOf("--ide=") === 0) targetIde = args[i].slice(6);
}

// IDE adapter config
var ADAPTERS = {
  antigravity: { dir: "workflows", ext: ".md", note: "// auto_execution_mode NOT added (Antigravity default)" },
  cursor:      { dir: "commands",  ext: ".md", transform: "cursor" },
  windsurf:    { dir: "workflows", ext: ".md", transform: "cursor", frontmatter: "auto_execution_mode: 1" },
  copilot:     { dir: "prompts",   ext: ".prompt.md", transform: "cursor", frontmatter: "mode: agent" },
  continue:    { dir: "prompts",   ext: ".md", transform: "cursor" },
  aider:       { dir: "prompts",   ext: ".md", transform: "cursor" },
  codeium:     { dir: "prompts",   ext: ".md", transform: "cursor" },
  zed:         { dir: "prompts",   ext: ".md", transform: "cursor" },
  jetbrains:   { dir: "prompts",   ext: ".md", transform: "cursor" },
  "void":      { dir: "prompts",   ext: ".md", transform: "cursor" }
};

function log(msg) { console.log("[build] " + msg); }

function runAntigravityConverter() {
  log("Running Antigravity converter (source of Cursor/others)...");
  var converter = path.join(ADAPTERS_DIR, "antigravity/converter.cjs");
  cp.execSync("node " + converter + " --all", { stdio: "inherit" });
}

function applyCursorTransforms(srcFile, dstFile, extra) {
  var c = fs.readFileSync(srcFile, "utf8");
  // Strip ai-team references (Antigravity-specific)
  c = c.replace(/`ai-developer` workflow \(research mode\)/g, "a focused research pass (web + docs + codebase)");
  c = c.replace(/`ai-developer` workflow/g, "the coding agent");
  c = c.replace(/`ai-tester` workflow/g, "the testing agent (write + run tests)");
  c = c.replace(/`ai-ux-reviewer` workflow/g, "the code review agent");
  c = c.replace(/`ai-team\//g, "`agent-team/");

  // Insert extra frontmatter field if specified
  if (extra && extra.frontmatter) {
    c = c.replace(/^(---\ndescription:[^\n]*\n)/, "$1" + extra.frontmatter + "\n");
  }

  fs.writeFileSync(dstFile, c, "utf8");
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

function buildAdapter(ide) {
  var cfg = ADAPTERS[ide];
  if (!cfg) { console.error("Unknown IDE: " + ide); return; }

  var srcAG = path.join(ADAPTERS_DIR, "antigravity/workflows");
  var dstAdapter = path.join(ADAPTERS_DIR, ide, cfg.dir);

  if (clean) {
    log("[" + ide + "] cleaning " + cfg.dir + "/");
    if (fs.existsSync(dstAdapter)) fs.rmSync(dstAdapter, { recursive: true });
  }

  if (!fs.existsSync(dstAdapter)) fs.mkdirSync(dstAdapter, { recursive: true });

  if (ide === "antigravity") {
    log("[antigravity] source (no transform needed)");
    return;
  }

  // For other IDEs: copy + transform from Antigravity
  var entries = fs.readdirSync(srcAG, { withFileTypes: true });
  var count = 0;
  for (var i = 0; i < entries.length; i++) {
    var e = entries[i];
    var srcPath = path.join(srcAG, e.name);
    if (e.isDirectory()) {
      // references folder — copy as-is
      copyDir(srcPath, path.join(dstAdapter, e.name));
    } else if (e.name.endsWith(".md") && e.name.startsWith("nc-")) {
      var dstName = e.name;
      if (cfg.ext === ".prompt.md") dstName = e.name.replace(/\.md$/, ".prompt.md");
      applyCursorTransforms(srcPath, path.join(dstAdapter, dstName), cfg);
      count++;
    }
  }
  log("[" + ide + "] built " + count + " workflows");
}

// Main
log("Building all IDE adapters...");

// Always rebuild Antigravity first (source for others)
runAntigravityConverter();

var idesToBuild = targetIde ? [targetIde] : Object.keys(ADAPTERS);
for (var j = 0; j < idesToBuild.length; j++) {
  buildAdapter(idesToBuild[j]);
}

log("All done.");
