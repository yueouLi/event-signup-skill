# event-signup-skill

A reusable event signup page — attendees scan a QR code, fill in what food/drink they're bringing, and everyone sees the live list in real time. No server needed.

**Built for:** potluck picnics, house parties, any gathering where you want to avoid 10 people bringing chips.

**First used:** Munich English Garden picnic, June 2026, ~40 people.

**[→ Live Demo](https://yueouli.github.io/event-signup-skill/)**

---

## How it works

**Stack:** Pure HTML + [Supabase](https://supabase.com) (free tier) — one single file, no build tools, no CDN dependencies.

- Form submissions go straight to Supabase via `fetch()` + REST API
- Page auto-refreshes every 5 seconds so everyone sees live updates
- Images are base64-inlined — share the HTML file directly, no hosting required for the file itself
- Deploy to [tiiny.host](https://tiiny.host) for a shareable link → QR code → WeChat group

---

## Files

| File | Description |
|------|-------------|
| `活动报名-模板.html` | Template with placeholders — edit this for each new event |
| `数据库建表.sql` | Supabase table setup script |
| `SKILL.md` | Claude Code skill — type `/event-signup` to auto-generate a new page |

---

## Quick start (manual)

### 1. Set up Supabase (once)
1. Create a project at [supabase.com](https://supabase.com)
2. Go to **SQL Editor** → paste `数据库建表.sql` → Run
3. Go to **Project Settings → API Keys → Legacy keys** tab
4. Copy your **Project URL** and **anon key** (`eyJ...`)

> ⚠️ Use the Legacy anon key (`eyJ...`), not the new `sb_publishable_*` format — the REST API doesn't accept the new format.

### 2. Edit the template
Open `活动报名-模板.html` and fill in the `<script>` block at the top:

```js
const URL_BASE = "https://YOUR_PROJECT.supabase.co";
const KEY      = "eyJ...your anon key...";
```

Also update the event title, date, capacity, and item categories (search for `hero-title`, `hero-meta`, `CATS`).

### 3. Deploy
Drag the HTML file to [tiiny.host](https://tiiny.host) → get a link → convert to QR code → share.

> For local testing, you need a local server (CORS blocks `file://`):
> ```bash
> python3 -m http.server 8888
> ```

---

## Claude Code skill

If you use [Claude Code](https://claude.ai/code), you can auto-generate customized pages:

1. Copy `SKILL.md` to `~/.claude/skills/event-signup/SKILL.md`
2. In any Claude Code session, type `/event-signup`
3. Answer the prompts (event name, date, capacity, Supabase credentials)
4. Get a ready-to-deploy HTML file

---

## Gotchas

- **Don't use `@supabase/supabase-js` via CDN** — it fails behind certain firewalls. Direct `fetch()` is more reliable.
- **Legacy anon key only** — the new `sb_publishable_*` key doesn't work with direct REST calls.
- **`file://` + CORS** — always test via a local HTTP server, not by double-clicking the file.
- **Inline `onclick` with quotes** — if you add custom JS, use `data-*` attributes + event delegation instead of inline `onclick="..."` to avoid quote-escaping bugs that silently break the entire script.
