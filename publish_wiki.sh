#!/bin/bash
# docs/wiki/publish_wiki.sh
# Run from qc-agent repo root. Requires qc-agent-wiki to be cloned at the path below.

WIKI_REPO="C:/Users/rober/OneDrive/Documents/Personal Projects/qc-agent-wiki"

# Sync docs/wiki/ -> wiki repo using Python (cross-platform; rsync not on Windows)
python - <<'PYEOF'
import os, sys, shutil

source = os.path.join(os.getcwd(), "docs", "wiki")
dest   = "C:/Users/rober/OneDrive/Documents/Personal Projects/qc-agent-wiki"
# Items in the wiki repo root that we never touch
exclude = {'.git', '.github', 'Gemfile', 'Gemfile.lock'}

if not os.path.isdir(dest):
    print(f"ERROR: wiki repo not found at {dest}", file=sys.stderr)
    sys.exit(1)

# Delete dest items absent from source (mirrors rsync --delete)
for item in list(os.listdir(dest)):
    if item in exclude:
        continue
    dest_path = os.path.join(dest, item)
    src_path  = os.path.join(source, item)
    if not os.path.exists(src_path):
        if os.path.isdir(dest_path):
            shutil.rmtree(dest_path)
        else:
            os.remove(dest_path)
        print(f"  deleted: {item}")

# Copy everything from source -> dest
for root, dirs, files in os.walk(source):
    dirs[:] = [d for d in dirs if d not in exclude]
    rel = os.path.relpath(root, source)
    dest_dir = dest if rel == '.' else os.path.join(dest, rel)
    os.makedirs(dest_dir, exist_ok=True)
    for f in files:
        if f in exclude:
            continue
        shutil.copy2(os.path.join(root, f), os.path.join(dest_dir, f))
        print(f"  copied: {os.path.join(rel, f) if rel != '.' else f}")

print("Sync complete.")
PYEOF

if [ $? -ne 0 ]; then
    echo "Sync failed. Aborting."
    exit 1
fi

cd "$WIKI_REPO"
git add .
git commit -m "Wiki update $(date +%Y-%m-%d)" || echo "Nothing to commit."
git push