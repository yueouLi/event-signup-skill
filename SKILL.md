# /event-signup — 活动报名网页生成器

从可复用模板快速生成新活动的报名页。纯前端 HTML + Supabase，单文件，扫码即用。

## How to trigger
User types `/event-signup`

## 文件路径
- 模板：`/Users/yueouli/Desktop/活动报名-可复用项目/活动报名-模板.html`
- 建表 SQL：`/Users/yueouli/Desktop/活动报名-可复用项目/数据库建表.sql`
- 输出目录：`/Users/yueouli/Desktop/活动报名-可复用项目/`

---

## Workflow

### Step 1 — 收集活动基本信息

Use **AskUserQuestion** with these 3 questions at once:

**Q1** — 活动名称
- Header: "活动名称"
- Question: "活动叫什么？（显示在页面大标题）"
- Options: ["野餐 · 英国花园", "BBQ 聚会", "家庭聚餐", "自定义"]
- multiSelect: false

**Q2** — 日期和人数（单行文本，让用户输入 "Other"）
- Header: "日期"
- Question: "活动日期是？（如：7月20日（周日））"
- Options: (4 common options like upcoming Sundays, plus "Other")

**Q3** — 预计人数
- Header: "人数"
- Question: "预计多少人？"
- Options: ["约 20 人", "约 30 人", "约 40 人", "约 50 人以上"]

After collecting, ask two text-input follow-ups:
- "Supabase Project URL？（直接粘贴，或输入 `skip` 之后再填）"
- "Supabase anon key？（eyJ 开头那串，或 `skip`）"

---

### Step 2 — 确认分类（可选修改）

Use **AskUserQuestion**:
- Header: "携带物分类"
- Question: "携带物品的分类想改吗？默认是：主食 / 饮料 / 零食水果 / 甜点蛋糕"
- Options:
  - "保持默认（主食 / 饮料 / 零食水果 / 甜点蛋糕）"
  - "我来自定义（下一步输入）"

If "我来自定义": ask user to type comma-separated category names, e.g. `主食,饮料,啤酒,甜点`.

Build `cats` list and `cat_icons` dict:
- Default icons map: `{"主食":"🍱","饮料":"🥤","零食水果":"🍎","甜点蛋糕":"🍰","啤酒":"🍺","酒":"🍷","甜点":"🍰","水果":"🍎","零食":"🍿","蛋糕":"🎂","汤":"🍲","沙拉":"🥗"}`
- For unrecognized categories, use `✨`

---

### Step 3 — 生成 hero 标题 HTML

Split event name for two-line display:
- If name has space or `·` or `/`, split at first occurrence: first part = plain, second part = `<em>...</em>`
  - Example: "英国花园 野餐" → `英国花园<br><em>野餐</em>`
  - Example: "野餐 · 英国花园" → `野餐<br><em>· 英国花园</em>`
- If no natural split point, use name as-is (no em/br)

---

### Step 4 — 用 Python 替换并写出文件

Generate output filename from event name (strip spaces/special chars): e.g. `活动报名-TUM聚会.html`

Run this Python script via Bash (inline, do NOT write a .py file):

```python
import re, json

template_path = "/Users/yueouli/Desktop/活动报名-可复用项目/活动报名-模板.html"
# Fill these variables before running:
event_name    = "..."      # full event name
event_date    = "..."      # e.g. "7月20日（周日）"
capacity      = "..."      # e.g. "约 30 人"
supabase_url  = "..."      # or "你的_SUPABASE_URL" if skipped
supabase_key  = "..."      # or "你的_ANON_KEY" if skipped
cats          = [...]      # list of category strings
cat_icon      = {...}      # dict of category -> emoji
hero_title_html = "..."    # the <br><em> version
outfile       = "/Users/yueouli/Desktop/活动报名-可复用项目/活动报名-XXX.html"

with open(template_path, 'r', encoding='utf-8') as f:
    html = f.read()

# 1. Page <title>
html = html.replace('<title>英国花园野餐 · 6月14日</title>',
                    f'<title>{event_name} · {event_date}</title>')

# 2. Supabase URL
html = html.replace('const URL_BASE = "你的_SUPABASE_URL";',
                    f'const URL_BASE = "{supabase_url}";')

# 3. Supabase key
html = html.replace('const KEY      = "你的_ANON_KEY";',
                    f'const KEY      = "{supabase_key}";')

# 4. Categories
html = html.replace('const CATS     = ["主食","饮料","零食水果","甜点蛋糕"];',
                    f'const CATS     = {json.dumps(cats, ensure_ascii=False)};')
html = html.replace('const CAT_ICON = {"主食":"🍱","饮料":"🥤","零食水果":"🍎","甜点蛋糕":"🍰"};',
                    f'const CAT_ICON = {json.dumps(cat_icon, ensure_ascii=False)};')

# 5. Hero title (h1 content)
html = re.sub(
    r'(class="hero-title">)[^<]*(?:<br>)?(?:<em>[^<]*</em>)?(</h1>)',
    lambda m: m.group(1) + hero_title_html + m.group(2),
    html
)

# 6. Date in hero-meta
html = re.sub(r'<span>6月14日[^<]*</span>', f'<span>{event_date}</span>', html)

# 7. Capacity in hero-meta
html = html.replace('<span>40 人</span>', f'<span>{capacity}</span>')

with open(outfile, 'w', encoding='utf-8') as f:
    f.write(html)

print(f"Written: {outfile} ({len(html):,} chars)")
```

Fill in all variables from the info collected in Steps 1–3, then run the script.

---

### Step 5 — 验证

Check file was written:
```bash
ls -lh "/Users/yueouli/Desktop/活动报名-可复用项目/活动报名-*.html" | tail -5
```

Confirm the key replacements landed correctly:
```bash
python3 -c "
import re
with open('OUTFILE', 'r') as f: html = f.read()
print('title:', re.search(r'<title>(.*?)</title>', html).group(1))
print('url:', re.search(r'URL_BASE = \"(.*?)\"', html).group(1)[:40])
print('cats:', re.search(r'CATS\s*=\s*(\[.*?\])', html).group(1))
print('hero:', re.search(r'class=\"hero-title\">(.*?)</h1>', html).group(1)[:60])
"
```

---

### Step 6 — 完成提示

Tell the user:

```
✅ 已生成：活动报名-{NAME}.html

📋 下一步：
  1. 打开 tiiny.host → 拖入 HTML → 复制链接
  2. 链接转二维码（qr-code-generator.com）→ 发微信群

🖥️  本地预览（file:// 会 CORS，需起服务器）：
     cd ~/Desktop/活动报名-可复用项目
     python3 -m http.server 8888
     → 浏览器打开 http://localhost:8888/活动报名-{NAME}.html
```

If Supabase URL or key was `skip`'d, add:
```
⚠️  记得打开文件补上 Supabase 凭证：
     URL_BASE = "你的_SUPABASE_URL"
     KEY      = "你的_ANON_KEY"
    （在文件开头 <script> 块里）
```

Use **AskUserQuestion**:
- Header: "预览"
- Question: "现在在浏览器里预览？"
- Options:
  - "是，起本地服务器" — run `cd ~/Desktop/活动报名-可复用项目 && python3 -m http.server 8888` then `open http://localhost:8888/活动报名-{NAME}.html`
  - "不用，稍后自己看"

---

## 技术说明（背景知识，供参考）

- HTML 文件约 590KB，大部分是内嵌 base64 图片，所以用 Python str.replace 而非全文读取
- Supabase REST API 用 Legacy anon key（`eyJ` 开头），不是新格式 `sb_publishable_*`
- 本地 `file://` 会被 CORS 拦截，测试必须用 `python3 -m http.server`
- 分类改完后 `CAT_ICON` 也要同步更新，否则图标显示为 undefined
