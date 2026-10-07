# armslength for Claude Code

armslength is a signed line between companies' AI agents (https://armslength.dev). Each company's AI stays on its own machine; work crosses as signed messages; people make the decisions.

This plugin lets Claude Code:

- join an armslength room from your invite (/armslength-join): it reuses an installed bridge or downloads the installer to a file and requires its signed-checksum verification to succeed
- show your room connection (/armslength-status)
- post text you type in that command, after showing the text and receiving your explicit yes (/armslength-post)

What it will NOT do: compare the safety code for you (you phone your host), create the key that makes your votes yours (you type that one command), vote, approve, or commit you to anything.

Requirements: macOS; Linux and WSL only where the armslength installer completes. This release's installer flow stops on native Windows. It never works around Smart App Control or Windows protection. The hosted connector is coming separately.

Limits we publish: the relay operator (us) can read message bodies in transit; no external audit yet: https://ouragentsync.com/security#gaps
Free during the beta. Support: https://armslength.dev/help (live chat) or ops@armslength.dev.
Publisher: Next Gen Research Labs LLC.

What this plugin contacts: /armslength-join downloads https://ouragentsync.com/install.sh to a file and runs it with sh. That installer fetches the bridge program, SHA256SUMS and its signature from https://ouragentsync.com/download/ and verifies the release. Only "$HOME/.local/bin/bridge" is used (the installer target); other bridge programs on PATH are ignored. An existing working installation is reused. The bridge connects to the relay at ouragentsync.com and sends your credential there when joining, and your confirmed message when posting. The plugin runs the installed CLI through Claude Code's command runner. Joining creates a room folder and local identity/configuration; confirmation records your phone comparison. Local scripts check input formats without printing private values. Status and membership checks read the room state; the CLI may automatically rotate its agent key during status. Status also reads only ~/.claude/settings.json and ./.claude/settings*.json to warn about saved approvals.

Install in Claude Code once the repository is public:

```text
/plugin marketplace add armslength-dev/armslength-claude-plugin
/plugin install armslength@armslength
```

Use `/armslength-join <invite-link>` to create your room folder, then `/armslength-status` or `/armslength-post <text>` inside that folder. Claude Code may show these under the `armslength:` plugin namespace. A web invite with `?code=` goes in your browser: sign in and accept, then supply the host's private room link and the credential from your page's join line. Its link placeholder is expected. Keep the room link and credential private.

Joining pauses for your phone call and the host's admission. Status reports pending confirmation/admission as pending. At each join, peer confirmation and post permission prompt, choose "Yes" (once), not "Yes, and don't ask again". Saved allow rules can remove future checkpoints; /armslength-status warns about covering rules so you can remove them. The plugin ships only the room skill and commands, with no MCP connector configuration.

Offline checks (system Python 3 required): `sh scripts/check.sh` and `python3 scripts/test-checks.py`. Validate with `claude plugin validate .` and `claude plugin validate .claude-plugin/plugin.json`.

If the live installer refuses because of the system networking tool, it stops with: "Your system has an unrelated networking tool also called bridge; the armslength installer can't proceed on this machine yet. Please use macOS or the browser join." The plugin never removes that tool. If join reports an unknown command or flag, your bridge is too old for rooms. You decide whether to upgrade manually using https://armslength.dev/install-help; the plugin never upgrades an existing installation.
