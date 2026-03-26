#!/bin/bash
set -e
echo "=== PARAMANT DEPLOY ==="
rm -rf dist && mkdir dist
cp index.html download.html privacy.html invite.html relay-feed.html _headers dist/
cat > dist/wrangler.toml << 'TOML'
name = "paramant"
compatibility_date = "2025-09-27"
compatibility_flags = ["nodejs_compat"]
[assets]
directory = "."
TOML
cd dist && npx wrangler deploy && cd ..
git add -A
git commit -m "deploy: $(date +%Y-%m-%d)" 2>/dev/null || true
git push
echo "✅ Deployed + pushed"
