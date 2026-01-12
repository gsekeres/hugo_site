---
title: "Marginalia"
description: "Agent-based academic literature management"
---

# Marginalia

An agent-based literature management platform that works with your Claude Code subscription.

**Features:**
- **Find PDFs** automatically from Unpaywall, Semantic Scholar, and NBER
- **Summarize papers** using Claude to generate structured summaries
- **Build citation graphs** with Obsidian-compatible wikilinks

[**Open Dashboard**](/marginalia/dashboard.html)

---

## How It Works

1. Import your BibTeX bibliography
2. Mark papers you want to read
3. Marginalia searches for open-access PDFs
4. Papers that can't be found go to a manual queue with search links
5. Click "Summarize" to generate structured summaries with Claude
6. Browse your library in Obsidian with linked notes

## Technical Details

- Uses **Claude Code CLI** with OAuth for summarization (no separate API credits)
- ~70-85% success rate for finding economics papers
- Summaries include: overview, key contributions, methodology, main results, related work

## Open Source

Marginalia is open source on [GitHub](https://github.com/gsekeres/marginalia).
