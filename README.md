# publishing-skills-to-amp

An Agent Skill and publisher script for syncing GitHub-hosted skills into an Amp account's User Skills repository. The GitHub Actions workflow in this repository uses the same script to publish this skill itself.

## Configure publishing

Add these repository Actions secrets, using the long-lived Amp access tokens for the corresponding accounts:

- `AMP_API_KEY_GMAIL`
- `AMP_API_KEY_UTAH`

After adding both secrets, run **Publish skill to Amp User Skills** once with `workflow_dispatch` to publish the current version. Later pushes to the skill or publishing workflow paths sync it automatically. Do not paste access tokens into issues, logs, or source files.
