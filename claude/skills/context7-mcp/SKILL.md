---
name: context7-mcp
description: This skill should be used when the user asks about libraries, frameworks, API references, or needs code examples. Activates for setup questions, code generation involving libraries, or mentions of specific frameworks like React, Vue, Next.js, Prisma, Supabase, etc.
---

When the user asks about libraries, frameworks, or needs code examples, use Context7 to fetch current documentation instead of relying on training data.

Context7 is accessed through **Executor** (`mcp__executor__execute`), not a direct MCP server — there is no standalone `context7` MCP connection anymore. Call it from inside the `execute` sandbox using the `context7_mcp.user.context7` connection.

## When to Use This Skill

Activate this skill when the user:

- Asks setup or configuration questions ("How do I configure Next.js middleware?")
- Requests code involving libraries ("Write a Prisma query for...")
- Needs API references ("What are the Supabase auth methods?")
- Mentions specific frameworks (React, Vue, Svelte, Express, Tailwind, etc.)

## How to Fetch Documentation

### Step 1: Resolve the Library ID

Inside `mcp__executor__execute`, call:

```ts
const result = await tools.context7_mcp.user.context7.resolve_library_id({
  libraryName: "<library name from the user's question>",
  query: "<the user's full question>", // improves relevance ranking
});
```

Both `libraryName` and `query` are required.

### Step 2: Select the Best Match

From the resolution results, choose based on:

- Exact or closest name match to what the user asked for
- Higher benchmark scores indicate better documentation quality
- If the user mentioned a version (e.g., "React 19"), prefer version-specific IDs

### Step 3: Fetch the Documentation

```ts
const docs = await tools.context7_mcp.user.context7.query_docs({
  libraryId: "<the selected Context7 library ID, e.g. /vercel/next.js>",
  query: "<the user's specific question>",
});
return docs;
```

### Step 4: Use the Documentation

Incorporate the fetched documentation into your response:

- Answer the user's question using current, accurate information
- Include relevant code examples from the docs
- Cite the library version when relevant

## Guidelines

- **Be specific**: Pass the user's full question as the query for better results
- **Version awareness**: When users mention versions ("Next.js 15", "React 19"), use version-specific library IDs if available from the resolution step
- **Prefer official sources**: When multiple matches exist, prefer official/primary packages over community forks
