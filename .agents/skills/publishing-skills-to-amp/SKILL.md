---
name: publishing-skills-to-amp
description: "Creates and maintains GitHub Actions workflows that publish GitHub-hosted Agent Skills to Amp User Skills repositories. Use when creating a skill repository, configuring automated publication, or debugging its sync and authentication."
---

# Publishing GitHub skills to Amp

Keep each skill in its own stable source directory, such as `.agents/skills/<skill-name>`, with a `SKILL.md` whose frontmatter name matches the directory.

An Amp account has one User Skills repository containing multiple skill directories. Never push the source repository's history directly to it: clone the destination with `amp clone user-skills`, then install or overwrite only the intended skill using `amp skill add --target <clone> --name <skill-name> --overwrite <source-directory>`. Commit and push only that skill directory so other skills remain untouched.

For automatic publishing, add a GitHub Actions workflow triggered by pushes to the skill and workflow paths. Install `@ampcode/cli` and store one long-lived Amp access token as a GitHub Actions secret for each destination account. Expose each token as `AMP_API_KEY` only while publishing that account; current tokens use the `sgamp_` prefix. For each destination, use a unique clone path:

```bash
target="$RUNNER_TEMP/user-skills-gmail"
amp clone user-skills "$target"
amp skill add --target "$target" --name "<skill-name>" --overwrite "$GITHUB_WORKSPACE/<skill-source>"
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
