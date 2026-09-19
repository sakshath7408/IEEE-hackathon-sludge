# IEEE Hackathon - Shared Context (GRIDPOINT SLUDGE)

Shared context repo so Sakshath's Claude and Tejas's Claude each know what
the other has been working on. Two humans, two AI sessions, one memory.

**This repo holds context only** - notes, logs, decisions, specs.
The actual project code lives in its own separate repo.

> **This repo is PUBLIC** (so hackathon organisers can see it). Never commit
> secrets, API keys, `.env` files, tokens, credentials, or private data.
> Deleting a file later does NOT remove it from git history.

## Structure

| Path | What it is | Who writes to it |
|---|---|---|
| `CONTEXT.md` | Current state of the project. Single source of truth. | Both, carefully |
| `logs/sakshath.md` | Append-only work log. | Sakshath only |
| `logs/tejas.md` | Append-only work log. | Tejas only |
| `decisions/` | One file per decision affecting the other side. | Both |
| `shared/` | Artifacts: specs, schemas, sample data. | Both |

## Protocol - both Claudes follow this

**Start of every session**

1. `git pull`
2. Read `CONTEXT.md` and the *other* person's log.
3. Summarise in 2-3 lines what changed on the other side.

**During work**

- Any decision affecting the other side - API shape, data format, naming,
  dependency, scope change - gets a dated file in `decisions/` immediately.
- Shared artifacts go in `shared/`.

**End of every session**

1. Append a dated entry to your own log.
2. Update `CONTEXT.md` if overall project state changed.
3. Run `./sync.sh "what changed"`

## Hard rules

- Write only to your own log file. The other person's log is read-only.
- Always `git pull` immediately before editing `CONTEXT.md`, and push
  immediately after. It is the only file both sides touch.
- Write for a reader with zero context. The other Claude cannot see your
  chat - only what is in these files.
- No secrets. Check before every push.
