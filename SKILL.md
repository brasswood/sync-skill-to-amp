---
name: sync-skill-to-amp
description: "Syncs GitHub-hosted Agent Skills to Amp User Skills repositories with GitHub Actions. Use when configuring automated publication for one or more skills, or debugging sync and authentication."
license: CC0-1.0
---

# Sync GitHub skills to Amp

For each skill, pass `amp skill add` the directory containing its `SKILL.md`, never the file path. Do not assume a fixed location for the file. When a source repository has multiple `SKILL.md` files, repeat the install for each file using its containing directory and frontmatter `name`.

An Amp account has one User Skills repository containing multiple skill directories. Never push the source repository's history directly to it: clone the destination with `amp clone user-skills`, then install or overwrite only the intended skill using `amp skill add --target <clone> --name <skill-name> --overwrite <source-directory>`. Commit and push only that skill directory so other skills remain untouched.

For automatic publishing, add a GitHub Actions workflow triggered by pushes to the source directory or directories containing the skills and to the workflow paths. Install `@ampcode/cli` and store one long-lived Amp access token as a GitHub Actions secret for each destination account. Expose each token as `AMP_API_KEY` only while publishing that account; current tokens use the `sgamp_` prefix. In this repository, the secrets are `AMP_API_KEY_GMAIL` and `AMP_API_KEY_UTAH`. For each skill and destination, use the directory containing that skill's `SKILL.md` and a unique clone path:

```bash
source_dir="<directory-containing-SKILL.md>"
skill_name="<skill-name>"
target="$RUNNER_TEMP/user-skills-gmail"
amp clone user-skills "$target"
amp skill add --target "$target" --name "$skill_name" --overwrite "$source_dir"
git -C "$target" add -- "$skill_name"
if ! git -C "$target" diff --cached --quiet; then
  git -C "$target" config user.name "Amp skill publisher"
  git -C "$target" config user.email "actions@users.noreply.github.com"
  git -C "$target" commit -m "Sync $skill_name from GitHub"
  git -C "$target" push origin HEAD:main
fi
```

Repeat the install for each skill directory, then repeat with each account's secret and a separate clone path. Use path filters covering the source directory or directories and workflow; a `workflow_dispatch` trigger makes it possible to seed the destination after secrets are configured.

Do not run `amp login` in CI: it starts an interactive device-login flow. Do not put access tokens in source, command output, or commit history. GitHub repository secrets are not readable or transferable between repositories, so configure them separately on each source repository.

Do not commit when the skill directory has no staged changes. Run the workflow after secrets are configured and confirm that a no-change run succeeds without creating a commit.
