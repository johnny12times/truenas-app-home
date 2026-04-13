#!/bin/sh
set -e
: "${DEFAULT_HOST:?DEFAULT_HOST env var must be set}"
: "${APPS:?APPS env var must be set}"

OUTPUT=/usr/share/nginx/html/index.html

# Sort apps alphabetically (case-insensitive)
SORTED=$(printf '%s' "$APPS" | tr ',' '\n' | sort -f)

# Write HTML head + opening tags
cat > "$OUTPUT" << 'HTMLEOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>// apps</title>
  <style>
    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

    :root {
      --bg: #080c0a;
      --border: #1a2e1f;
      --text: #a3c4a8;
      --text-dim: #4a6b4e;
      --accent: #3dffa0;
      --accent-glow: rgba(61, 255, 160, 0.15);
      --font: 'Consolas', 'Monaco', 'Lucida Console', 'Courier New', monospace;
    }

    html, body {
      min-height: 100vh;
      background: var(--bg);
      color: var(--text);
      font-family: var(--font);
      font-size: 15px;
      line-height: 1.6;
    }

    body::after {
      content: '';
      position: fixed;
      inset: 0;
      background: repeating-linear-gradient(
        0deg,
        transparent,
        transparent 2px,
        rgba(0, 0, 0, 0.07) 2px,
        rgba(0, 0, 0, 0.07) 4px
      );
      pointer-events: none;
      z-index: 100;
    }

    main {
      max-width: 640px;
      margin: 0 auto;
      padding: 4rem 2rem;
    }

    h1 {
      font-size: 0.75rem;
      letter-spacing: 0.25em;
      text-transform: uppercase;
      color: var(--text-dim);
      margin-bottom: 2.5rem;
      padding-bottom: 1rem;
      border-bottom: 1px solid var(--border);
    }

    h1::before {
      content: '// ';
      color: var(--accent);
    }

    ul { list-style: none; }

    li {
      opacity: 0;
      animation: fadeIn 0.4s ease forwards;
    }

    li:nth-child(1)  { animation-delay: 0.05s; }
    li:nth-child(2)  { animation-delay: 0.10s; }
    li:nth-child(3)  { animation-delay: 0.15s; }
    li:nth-child(4)  { animation-delay: 0.20s; }
    li:nth-child(5)  { animation-delay: 0.25s; }
    li:nth-child(6)  { animation-delay: 0.30s; }
    li:nth-child(7)  { animation-delay: 0.35s; }
    li:nth-child(8)  { animation-delay: 0.40s; }
    li:nth-child(9)  { animation-delay: 0.45s; }
    li:nth-child(10) { animation-delay: 0.50s; }
    li:nth-child(11) { animation-delay: 0.55s; }
    li:nth-child(12) { animation-delay: 0.60s; }
    li:nth-child(13) { animation-delay: 0.65s; }
    li:nth-child(14) { animation-delay: 0.70s; }
    li:nth-child(15) { animation-delay: 0.75s; }
    li:nth-child(16) { animation-delay: 0.80s; }
    li:nth-child(17) { animation-delay: 0.85s; }
    li:nth-child(18) { animation-delay: 0.90s; }
    li:nth-child(19) { animation-delay: 0.95s; }
    li:nth-child(20) { animation-delay: 1.00s; }

    @keyframes fadeIn {
      from { opacity: 0; transform: translateX(-8px); }
      to   { opacity: 1; transform: translateX(0); }
    }

    a {
      display: flex;
      align-items: center;
      gap: 0.75rem;
      padding: 0.65rem 0.75rem;
      color: var(--text);
      text-decoration: none;
      border: 1px solid transparent;
      border-radius: 2px;
      transition: color 0.15s ease, background-color 0.15s ease, border-color 0.15s ease, text-shadow 0.15s ease;
      margin-bottom: 2px;
    }

    a::before {
      content: '>';
      color: var(--accent);
      font-weight: bold;
      flex-shrink: 0;
      transition: transform 0.15s ease;
    }

    a:hover {
      color: var(--accent);
      background: var(--accent-glow);
      border-color: var(--border);
      text-shadow: 0 0 12px rgba(61, 255, 160, 0.4);
    }

    a:hover::before {
      transform: translateX(4px);
    }
  </style>
</head>
<body>
  <main>
    <h1>apps</h1>
    <ul>
HTMLEOF

# Append one <li> per app
printf '%s\n' "$SORTED" | while IFS= read -r app; do
  [ -z "$app" ] && continue
  name="${app%%=*}"
  value="${app#*=}"
  # Port-only value → build URL from DEFAULT_HOST; otherwise use verbatim
  if printf '%s' "$value" | grep -qE '^[0-9]+$'; then
    url="http://${DEFAULT_HOST}:${value}"
  else
    url="$value"
  fi
  printf '      <li><a href="%s" target="_blank" rel="noopener noreferrer">%s</a></li>\n' "$url" "$name" >> "$OUTPUT"
done

# Close HTML
cat >> "$OUTPUT" << 'HTMLEOF'
    </ul>
  </main>
</body>
</html>
HTMLEOF

exec nginx -g 'daemon off;'
