# lib/record.sh — this part's entry in the upgrade's record.
#
# SOURCED as the last line of a part's setup.sh (POSIX sh: the parts run
# under `sh`), with the part's own variables in scope: `label` (the name
# a reader shows), and for a part that installs a repo, `dir`, `repo`,
# `branch`. Writes {name, label, dir, repo, branch, commit} — the commit
# now checked out in `dir` — for the top-level setup.sh to gather into
# /var/lib/dorna/upgrade.json, which the admin's System page reads. A new
# part is listed by declaring these variables and sourcing this file;
# nothing else knows the list.
#
# Run by hand (no upgrade around it), DORNA_UPGRADE_PARTS is unset and
# this does nothing.
if [ -n "${DORNA_UPGRADE_PARTS:-}" ]; then
python3 - "${DORNA_UPGRADE_PART:-}" "${label:-}" "${dir:-}" "${repo:-}" "${branch:-}" <<'PY'
import json, os, subprocess, sys
name, label, d, repo, branch = sys.argv[1:6]
commit = ""
if d and os.path.isdir(os.path.join(d, ".git")):
    commit = subprocess.run(["git", "-C", d, "rev-parse", "HEAD"],
                            capture_output=True, text=True).stdout.strip()
entry = {"name": name, "label": label or name, "dir": d, "repo": repo,
         "branch": branch, "commit": commit}
with open(os.path.join(os.environ["DORNA_UPGRADE_PARTS"], name + ".json"), "w") as f:
    json.dump(entry, f)
PY
fi
