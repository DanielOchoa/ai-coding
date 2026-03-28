#!/usr/bin/env bash
# Symlink personal rules, skills, and agents into ~/.cursor/ so they're available globally.
#
# Rules:  symlinks ~/.cursor/rules -> this repo's rules directory
# Skills: symlinks each skill into ~/.cursor/skills-cursor/ alongside existing meta-skills
# Agents: symlinks each agent into ~/.cursor/agents/ alongside existing agents
#
# Safe to re-run. Skips existing targets. Use --force to replace stale symlinks.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
USER_CURSOR="$(cd "${SCRIPT_DIR}/../.cursor" && pwd)"
GLOBAL_CURSOR="${HOME}/.cursor"

FORCE=false
DRY_RUN=false

for arg in "$@"; do
  case "$arg" in
    --force) FORCE=true ;;
    --dry-run) DRY_RUN=true ;;
    -h|--help)
      echo "Usage: $0 [--force] [--dry-run]"
      echo ""
      echo "Symlinks personal rules, skills, and agents into ~/.cursor/"
      echo ""
      echo "  --force    Replace existing symlinks (won't touch non-symlink files)"
      echo "  --dry-run  Show what would be done without making changes"
      exit 0
      ;;
    *)
      echo "Unknown option: $arg" >&2
      exit 1
      ;;
  esac
done

log() { echo "  $1"; }
ok()  { echo "  [ok] $1"; }
skip() { echo "  [skip] $1"; }
err() { echo "  [error] $1" >&2; }

link_target() {
  local src="$1" dest="$2" label="$3"

  if [[ -L "$dest" ]]; then
    local current
    current="$(readlink "$dest")"
    if [[ "$current" == "$src" ]]; then
      skip "$label (already linked)"
      return 0
    fi
    if [[ "$FORCE" == true ]]; then
      if [[ "$DRY_RUN" == true ]]; then
        log "$label -> $src (would replace, was -> $current)"
        return 0
      fi
      rm -f "$dest"
    else
      skip "$label (symlink exists -> $current, use --force to replace)"
      return 0
    fi
  elif [[ -e "$dest" ]]; then
    err "$label: $dest exists and is not a symlink. Remove it manually."
    return 1
  fi

  if [[ "$DRY_RUN" == true ]]; then
    log "$label -> $src (would create)"
    return 0
  fi

  ln -s "$src" "$dest"
  ok "$label -> $src"
}

# --- Rules ---
echo "Rules:"
RULES_SRC="${USER_CURSOR}/rules"
RULES_DEST="${GLOBAL_CURSOR}/rules"

if [[ ! -d "$RULES_SRC" ]]; then
  err "Source not found: $RULES_SRC"
  exit 1
fi

link_target "$RULES_SRC" "$RULES_DEST" "rules"

# --- Skills ---
echo "Skills:"
SKILLS_SRC="${USER_CURSOR}/skills"
SKILLS_DEST="${GLOBAL_CURSOR}/skills-cursor"

if [[ ! -d "$SKILLS_SRC" ]]; then
  skip "No skills directory at $SKILLS_SRC"
  exit 0
fi

if [[ ! -d "$SKILLS_DEST" ]]; then
  mkdir -p "$SKILLS_DEST"
fi

for skill_dir in "$SKILLS_SRC"/*/; do
  [[ -d "$skill_dir" ]] || continue
  name="$(basename "$skill_dir")"
  link_target "$skill_dir" "${SKILLS_DEST}/${name}" "skill: $name"
done

# --- Agents ---
echo "Agents:"
AGENTS_SRC="${USER_CURSOR}/agents"
AGENTS_DEST="${GLOBAL_CURSOR}/agents"

if [[ ! -d "$AGENTS_SRC" ]]; then
  skip "No agents directory at $AGENTS_SRC"
else
  if [[ ! -d "$AGENTS_DEST" ]]; then
    mkdir -p "$AGENTS_DEST"
  fi

  for agent_file in "$AGENTS_SRC"/*.md; do
    [[ -f "$agent_file" ]] || continue
    name="$(basename "$agent_file")"
    link_target "$agent_file" "${AGENTS_DEST}/${name}" "agent: $name"
  done
fi

# --- References ---
echo "References:"
REFS_SRC="${USER_CURSOR}/references"
REFS_DEST="${GLOBAL_CURSOR}/references"

if [[ ! -d "$REFS_SRC" ]]; then
  skip "No references directory at $REFS_SRC"
else
  link_target "$REFS_SRC" "$REFS_DEST" "references"
fi

# --- Projects ---
# ~/.cursor/projects/ is Cursor-internal (workspace index). Use review-projects/ instead.
echo "Projects:"
PROJECTS_SRC="${USER_CURSOR}/projects"
PROJECTS_DEST="${GLOBAL_CURSOR}/review-projects"

if [[ ! -d "$PROJECTS_SRC" ]]; then
  skip "No projects directory at $PROJECTS_SRC"
else
  link_target "$PROJECTS_SRC" "$PROJECTS_DEST" "review-projects"
fi

echo ""
echo "Done. Restart Cursor to pick up changes."
