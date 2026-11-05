---
name: sync-skill-to-amp
description: "Syncs GitHub-hosted Agent Skills to Amp User Skills repositories with GitHub Actions. Use when creating a one-skill GitHub repository, configuring automated publication, or debugging sync and authentication."
license: CC0-1.0
---

# Sync GitHub skills to Amp

For a repository dedicated to one skill, keep its source file at the repository root as `SKILL.md`. Set the frontmatter `name` to the destination skill-directory name. For a repository containing multiple skills, keep each skill in its own directory. `amp skill add` takes the directory containing `SKILL.md`, not the file itself, so pass the repository root for this layout.

An Amp account has one User Skills repository containing multiple skill directories. Never push the source repository's history directly to it: clone the destination with `amp clone user-skills`, then install or overwrite only the intended skill using `amp skill add --target <clone> --name <skill-name> --overwrite <source-directory>`. Commit and push only that skill directory so other skills remain untouched.

For automatic publishing, add a GitHub Actions workflow triggered by pushes to `SKILL.md` and the workflow paths. Install `@ampcode/cli` and store one long-lived Amp access token as a GitHub Actions secret for each destination account. Expose each token as `AMP_API_KEY` only while publishing that account; current tokens use the `sgamp_` prefix. In this repository, the secrets are `AMP_API_KEY_GMAIL` and `AMP_API_KEY_UTAH`. Use a unique clone path for each destination:

```bash
source="$GITHUB_WORKSPACE" # This directory contains the root SKILL.md.
target="$RUNNER_TEMP/user-skills-gmail"
amp clone user-skills "$target"
amp skill add --target "$target" --name "<skill-name>" --overwrite "$source"
git -C "$target" add -- "<skill-name>"
if ! git -C "$target" diff --cached --quiet; then
  git -C "$target" config user.name "Amp skill publisher"
  git -C "$target" config user.email "actions@users.noreply.github.com"
  git -C "$target" commit -m "Sync <skill-name> from GitHub"
  git -C "$target" push origin HEAD:main
fi
```

Repeat with each account's secret and a separate clone path. Use a path filter covering the skill and workflow; a `workflow_dispatch` trigger makes it possible to seed the destination after secrets are configured.

Do not run `amp login` in CI: it starts an interactive device-login flow. Do not put access tokens in source, command output, or commit history. GitHub repository secrets are not readable or transferable between repositories, so configure them separately on each source repository.

Do not commit when the skill directory has no staged changes. Run the workflow after secrets are configured and confirm that a no-change run succeeds without creating a commit.
