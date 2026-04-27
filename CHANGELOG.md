# Changelog

## 0.1.3

- Check minimum Bash version on startup; exit with a clear error on Bash 3 instead of a cryptic `declare -A` / `${array[@]}` syntax failure (common on stock macOS). (#4, thanks @ellieayla)
- Add `.pre-commit-hooks.yaml` so git-leash can be installed via the [pre-commit](https://pre-commit.com) framework alongside other hooks. (#3, thanks @ellieayla)

## 0.1.2

- Replace `$RANDOM` with `/dev/urandom` for better randomness in bark/noun selection.
- Data-driven tone system: 6 built-in tones (`default`, `puppy`, `wolf`, `cat`, `bunny`, `fox`, `robot`), customizable via `[tone "name"]` sections, with configurable nouns.
- Bug fixes: hook chaining when blocked, global `core.hooksPath` clobber, hardcoded hooks dir, `&` corruption in messages.
- Nix flake.

## 0.1.1

- Initial tagged release.
