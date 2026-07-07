#!/usr/bin/env node
/**
 * Wrap a diagram body fragment (the inner HTML you author per-project) into a
 * complete, self-contained HTML document using the shared felipego.com
 * diagram kit (../assets/diagram-style.css) — so every diagram across every
 * project looks like one consistent system, not bespoke CSS each time.
 *
 * Usage:
 *   node wrap-diagram.mjs <bodyFile> [--out <outFile>]
 *   cat body.html | node wrap-diagram.mjs --out out.html
 *
 * The body fragment should use the kit's classes (.node, .arrow, .step, .num,
 * .tool, .grid, .route, .mono, .center, .row, button.kit) — see
 * references/html-diagrams.md for the three standard shapes and full class
 * reference. Never add hard-coded colors/fonts; the site injects the design
 * tokens these classes reference.
 */
import fs from "node:fs"
import path from "node:path"
import { fileURLToPath } from "node:url"

const __dirname = path.dirname(fileURLToPath(import.meta.url))
const STYLE_PATH = path.join(__dirname, "..", "assets", "diagram-style.css")

function readStdin() {
  return fs.readFileSync(0, "utf8")
}

function parseArgs(argv) {
  const args = { _: [] }
  for (let i = 0; i < argv.length; i++) {
    const a = argv[i]
    if (a === "--out") args.out = argv[++i]
    else args._.push(a)
  }
  return args
}

const args = parseArgs(process.argv.slice(2))
const bodyFile = args._[0]

if (!bodyFile && process.stdin.isTTY) {
  console.error(
    "Usage: node wrap-diagram.mjs <bodyFile> [--out <outFile>]\n" +
      "       cat body.html | node wrap-diagram.mjs --out out.html",
  )
  process.exit(1)
}

const body = bodyFile ? fs.readFileSync(bodyFile, "utf8") : readStdin()
const style = fs.readFileSync(STYLE_PATH, "utf8")

const doc = `<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><style>${style}</style></head><body>${body}</body></html>`

if (args.out) {
  fs.writeFileSync(args.out, doc)
  console.log(`wrote ${args.out} (${doc.length} chars)`)
} else {
  process.stdout.write(doc)
}
