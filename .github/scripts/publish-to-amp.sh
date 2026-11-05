#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 3 ]]; then
  echo "Usage: publish-to-amp.sh <skill-name> <source-directory> <user-skills-clone>" >&2
  exit 2
fi

skill_name=$1
source_dir=$2
target_dir=$3

if [[ ! -f "$source_dir/SKILL.md" ]]; then
  echo "No SKILL.md found in source directory: $source_dir" >&2
  exit 1
fi
case "${AMP_API_KEY-}" in
  sgamp_*) ;;
  *) echo "Set AMP_API_KEY to a long-lived Amp access token (sgamp_...)." >&2; exit 1 ;;
esac

# The exported token lets the CLI clone and push without an interactive login.
amp clone user-skills "$target_dir"
amp skill add --target "$target_dir" --name "$skill_name" --overwrite "$source_dir"
git -C "$target_dir" add -- "$skill_name"

if git -C "$target_dir" diff --cached --quiet; then
  echo "Skill is already current: $skill_name"
  exit 0
fi

git -C "$target_dir" config user.name "Amp skill publisher"
git -C "$target_dir" config user.email "actions@users.noreply.github.com"
git -C "$target_dir" commit -m "Sync $skill_name from GitHub"
git -C "$target_dir" push origin HEAD:main
