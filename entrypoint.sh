#!/bin/sh
set -e

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
  <title>My Apps</title>
</head>
<body>
  <main>
    <h1>My Apps</h1>
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
  printf '      <li><a href="%s" target="_blank">%s</a></li>\n' "$url" "$name" >> "$OUTPUT"
done

# Close HTML
cat >> "$OUTPUT" << 'HTMLEOF'
    </ul>
  </main>
</body>
</html>
HTMLEOF

exec nginx -g 'daemon off;'
