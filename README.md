# git-leash

*Helps you stay focused on what you're supposed to be doing.*

A git pre-commit hook that blocks commits during configured focus windows. Overridable when you genuinely need to ship. Stealth-installable so it doesn't pollute your repo.

By a puppygirl.

## Install

```bash
cp leash ~/.local/bin/ && chmod +x ~/.local/bin/leash
# or install directly from GitHub
# curl -s https://raw.githubusercontent.com/SiteRelEnby/git-leash/refs/heads/main/leash > ~/.local/bin/leash && \
  chmod +x ~/.local/bin/leash
```

Make sure `~/.local/bin` is in your `PATH`.

Then, in any repo:

```bash
# install the hook to this repo
leash install

# or install globally (all repos)
leash install --global
```

`leash install` automatically adds `.leash` and `.leash-slip` to `.git/info/exclude` — no `.gitignore` modifications, nothing tracked, pure stealth.

## Config

Place at `~/.leash` (global) or `.leash` in your repo root (project-local overrides global).

```ini
[schedule "work-hours"]
days=mon,tue,wed,thu,fri
start=09:00
end=17:00
timezone=local

# only block personal repos — work repos are fine
block=remote:github.com/myuser/*
block=dir:side-project
task=finish the auth refactor

[schedule "go-to-bed"]
days=mon,tue,wed,thu,sun
start=23:00
end=06:00
task=go to sleep you disaster
# no filter = block everything. go to sleep.

[task]
# global fallback when a schedule doesn't have its own
current=you're supposed to be doing something else

[messages]
tone=puppy

[override]
env_var=UNLEASH
slip_file=.leash-slip
```

Run `leash example` for a fully commented config.

### Schedules

Named blocks that define when commits are restricted. Multiple schedules stack — if **any** match, the commit is blocked.

- `days` — comma-separated, lowercase (default: `mon,tue,wed,thu,fri`)
- `start` / `end` — 24h time. Overnight windows work (`23:00` to `06:00`)
- `timezone` — `local` or IANA zone like `America/New_York`

### Repo filters

Without filters, a schedule blocks **all** repos. Add filters to be selective.

**`allow=`** (allowlist) — only matching repos can commit during this window, everything else is blocked. This is the one you probably want for "let me commit to work repos during work hours":

```ini
[schedule "work-hours"]
days=mon,tue,wed,thu,fri
start=09:00
end=17:00
allow=remote:github.com/company/*
allow=path:/home/user/work/*
allow=dir:work-project
```

**`block=`** (denylist) — only matching repos are blocked, everything else is fine:

```ini
block=remote:github.com/myuser/*
block=dir:side-project
```

**Pick one per schedule.** If both `allow=` and `block=` are present, `allow=` wins and `block=` is ignored (leash will warn you about this). Set `suppress_warnings=true` in `[messages]` to silence the warning if you know what you're doing.

**Prefixes (required):**
| Prefix | Matches against |
|---|---|
| `remote:` | All remote URLs (not just origin) — protocol and `.git` suffix stripped |
| `path:` | Repo root absolute path |
| `dir:` | Repo directory name (basename) |

Multiple lines of the same type stack as OR — any match counts.

### Task

Optional reminder shown in the block message. Can be set per-schedule or globally as a fallback:

```ini
[schedule "work-hours"]
task=finish the auth refactor

[schedule "go-to-bed"]
task=go to sleep you disaster

[task]
# fallback when a schedule doesn't have its own
current=you're supposed to be doing something else
```

Set the global task from the CLI:

```bash
leash task "finish the auth refactor"
```

### Message tone

```ini
[messages]
tone=default   # normal focus-helper vibes
tone=puppy     # i know what you are
```

## Overrides

When you genuinely need to commit during a focus window:

```bash
# environment variable (configurable name)
UNLEASH=1 git commit -m "it's fine"

# one-time pass — auto-deleted after one commit
leash slip

# nuclear option (skips all git hooks)
git commit --no-verify
```

## Commands

```
leash install [--global]    Install the pre-commit hook
leash uninstall [--global]  Remove the pre-commit hook
leash slip                  Create a one-time commit pass
leash status                Show config, schedule, and block status
leash task [description]    Show or set the current task reminder
leash check                 Run the hook check manually
leash example               Print a fully commented example config
leash help                  Show help
leash version               Show version
```

## How it works

`leash install` writes a pre-commit hook that calls back to the `leash` script. On each `git commit`:

1. Check overrides (env var, slip file) — fast exit if set
2. Read config (`~/.leash` + `.leash`, project wins)
3. Check each schedule: day, time, repo filters
4. If blocked: bark, show task, print override hints, exit 1

The hook remembers where `leash` was installed from, but also checks `PATH` as a fallback. If `leash` can't be found at all, it warns but allows the commit — it won't silently break your workflow.

## Stealth

The whole point is that this doesn't leave traces in your repo:

- `.leash` and `.leash-slip` are added to `.git/info/exclude` (repo-local gitignore, untracked)
- The hook lives in `.git/hooks/` (not tracked)
- Nothing touches `.gitignore`

If there's an existing pre-commit hook, it gets backed up to `pre-commit.leash-backup` and chained — leash runs first, then your original hook.

## Requirements

Bash 4+ and coreutils. That's it.

## License

BSD 3-Clause
