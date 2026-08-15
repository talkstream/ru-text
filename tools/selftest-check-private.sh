#!/bin/sh
# selftest-check-private.sh — proves check-private.sh reds, and reds for the right reason.
#
# A gate nobody has seen fail is a gate nobody knows works. This one guards an irreversible
# event — an identifier of the private contour reaching a public commit — so «it passed on a
# clean tree» is worth nothing on its own: a script that always prints PASS passes too.
#
# Each case plants ONE identifier into a throwaway clone and asserts that the run fails AND
# that the label naming that class appears. Asserting only the exit code would let a single
# over-broad pattern cover for six missing ones.

set -eu
export LC_ALL=C

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
GATE="$ROOT/tools/check-private.sh"
WORK=$(mktemp -d)
trap 'chmod -R u+w "$WORK" 2>/dev/null || true; find "$WORK" -mindepth 1 -delete 2>/dev/null || true' EXIT INT TERM

pass=0
fail=0

# A minimal git tree: the gate walks tracked files, so the fixture must be a repository.
prepare() {
  d="$WORK/case"
  find "$d" -mindepth 1 -delete 2>/dev/null || true
  mkdir -p "$d/tools"
  cp "$GATE" "$d/tools/check-private.sh"
  printf '# ru-text\n\nПравила русского текста.\n' > "$d/README.md"
  ( cd "$d" && git init -q && git add -A && git -c user.email=t@t -c user.name=t commit -qm init )
}

# case <name> <text to plant> <label that must appear>
case_run() {
  name="$1"; text="$2"; want="$3"
  prepare
  printf '%s\n' "$text" >> "$d/README.md"
  ( cd "$d" && git add -A && git -c user.email=t@t -c user.name=t commit -qm plant )
  out=$(sh "$d/tools/check-private.sh" "$d" 2>&1) && rc=0 || rc=$?
  if [ "$rc" = "0" ]; then
    printf 'FAIL  %-34s — gate PASSED with the identifier present\n' "$name"
    fail=$((fail + 1))
    return
  fi
  if printf '%s' "$out" | grep -q "FAIL  $want"; then
    printf 'ok    %-34s — reds as «%s»\n' "$name" "$want"
    pass=$((pass + 1))
  else
    printf 'FAIL  %-34s — red, but not as «%s»\n' "$name" "$want"
    printf '%s\n' "$out" | sed 's/^/        /'
    fail=$((fail + 1))
  fi
}

echo "selftest: check-private.sh"
echo

# The control comes first: without it, every case below could be passing because the gate
# reds on everything.
prepare
if sh "$d/tools/check-private.sh" "$d" >/dev/null 2>&1; then
  printf 'ok    %-34s — clean tree passes\n' "control"
  pass=$((pass + 1))
else
  printf 'FAIL  %-34s — clean tree already reds\n' "control"
  fail=$((fail + 1))
fi

# ⚠ The second control is the one that keeps this gate usable. The public repository
# legitimately talks ABOUT the paid service; if that reddened the gate, the gate would be
# switched off within a week. The deny-list is identifiers, and this case proves it.
prepare
printf 'Этот раздел заморожен ради контракта с платным сервисом ru-text MCP.\n' >> "$d/README.md"
( cd "$d" && git add -A && git -c user.email=t@t -c user.name=t commit -qm topic )
if sh "$d/tools/check-private.sh" "$d" >/dev/null 2>&1; then
  printf 'ok    %-34s — the SUBJECT of the paid service is allowed\n' "topic control"
  pass=$((pass + 1))
else
  printf 'FAIL  %-34s — gate reds on the mere topic\n' "topic control"
  fail=$((fail + 1))
fi

# ⚠ Every planted value below is a STAND-IN, and that is the point of this block. The first
# draft of this file planted the real ones — the actual repository name, the actual service
# host, the actual server address — and a background security review flagged it as
# infrastructure disclosure inside the very commit meant to prevent that. Nothing had been
# pushed. The fix is not «be careful»: the gate's patterns now match shapes, so a fixture can
# prove them with addresses reserved for documentation (RFC 5737) and names that exist nowhere.
case_run "sibling repository"  "git clone git@github.com:talkstream/ru-text-example.git"   "sibling repository under this owner"
case_run "service sub-domain"  "curl https://service.ru-text.org/v1/check"                 "service sub-domain"
case_run "IP address literal"  "ssh root@203.0.113.10"                                    "any IP address literal"
case_run "payment provider"    "оплата через ЮKassa"                                      "payment provider"
# ⚠ Регистр латиницы: до 16.08.2026 образцы шли без -i, и «YooKassa» — как пишет сам
# бренд — проходило насквозь. Случай стоит отдельно от предыдущего, потому что
# кириллическая и латинская руки ловятся разными половинами образца.
case_run "provider, brand casing" "payments via YooKassa"                                 "payment provider"
case_run "provider, upper case"   "хостинг SELECTEL"                                      "hosting provider"
case_run "hosting provider"    "хостинг Selectel, СПб"                                    "hosting provider"
case_run "admin token"         "export ADMIN_TOKEN=stand-in"                              "admin token variable"
case_run "deploy key material" "-----BEGIN OPENSSH PRIVATE KEY-----"                      "deploy key material"

echo
echo "passed $pass, failed $fail"
[ "$fail" -eq 0 ] || exit 1
