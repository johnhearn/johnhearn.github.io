# John Hearn's Blog — Quarto

Personal website at [johnhearn.github.io](https://johnhearn.github.io/). Built with [Quarto](https://quarto.org/).

## Writing a New Post

1. Create a folder under `posts/` with the date and slug:

   ```
   mkdir posts/2026-03-17-my-new-post
   ```

2. Create `index.qmd` inside it:

   ```yaml
   ---
   title: "My New Post"
   description: "A short summary for the listing page."
   date: "2026-03-17"
   categories: [blog]
   tags: [topic1, topic2]
   ---

   Your content here.
   ```

3. Put images and other assets in the same folder — they'll be co-located with the post.

### Writing a Draft

Add `draft: true` to the frontmatter. The post will render locally but won't appear in feeds or sitemaps.

```yaml
---
title: "Work in Progress"
date: "2026-03-17"
categories: [blog]
draft: true
---
```

### Writing a Note

Same as a post but goes in `notes/` and uses `categories: [notes]`.

## Key Syntax

### Margin Notes (sidenotes)

Use standard footnotes — they render automatically in the margin:

```markdown
Some text[^myid] continues here.

[^myid]: This appears as a numbered margin note.
```

### Unnumbered Margin Notes

```markdown
[This appears in the margin without a number.]{.column-margin}
```

### Margin Figures

```markdown
![Caption text](image.png){.column-margin}
```

### Regular Figures

```markdown
![Caption text](image.png)
```

### Math

Standard LaTeX — rendered at build time (no client-side JS):

```markdown
Inline: $E = mc^2$

Display:
$$\int_0^\infty e^{-x^2} dx = \frac{\sqrt{\pi}}{2}$$
```

### Graphviz Diagrams

````markdown
```{dot}
digraph {
  A -> B -> C
}
```
````

### Small Caps (newthought)

```markdown
[Opening words]{.smallcaps}
```

## Local Preview

```bash
cd quarto
quarto preview
```

This starts a live-reloading server (usually at `http://localhost:4848`). Edit files and the browser refreshes automatically.

For a production-like check of the prerendered site, render first and serve `_site/` as static files:

```bash
cd quarto
quarto render
cd _site
python3 -m http.server 8000
```

Then browse `http://localhost:8000/`. Unlike `quarto preview`, this serves the already-rendered HTML directly, so navigation behaves like the deployed site.

## Build

```bash
quarto render
```

Output goes to `_site/`. The `freeze: auto` setting caches computational outputs so only changed files re-execute.

## Deploy to GitHub Pages

```bash
quarto publish gh-pages
```

This builds the site, commits to the `gh-pages` branch, and pushes. The CNAME for `johnhearn.github.io` is preserved automatically.

## Project Structure

```
quarto/
├── _quarto.yml        # Site config (navbar, theme, layout)
├── custom.scss         # Tufte-inspired theme overrides
├── index.qmd           # Blog listing page
├── notes.qmd           # Notes listing page
├── about.qmd           # About page
├── 404.qmd             # Custom 404 page
├── posts/              # Blog posts (one folder each)
│   └── YYYY-MM-DD-slug/
│       ├── index.qmd
│       └── image.png   # Co-located assets
├── notes/              # Notes (same structure)
├── series/             # Series listing pages
├── _site/              # Build output (git-ignored)
└── _freeze/            # Cached computation results
```

## Tips

- **Images**: Put images in the post or note's own folder.
- **Cross-links**: Link to sibling posts with `../YYYY-MM-DD-slug/` relative paths.
- **Categories**: Used for filtering on listing pages. Use subject categories rather than structural categories such as `blog` or `notes`.
- **Tags**: Free-form, shown in post listings.
- **Date format**: Use `"YYYY-MM-DD"` in frontmatter.
