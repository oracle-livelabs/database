#!/usr/bin/env bash
set -u

failures=0

check() {
  local description="$1"
  shift
  if "$@"; then
    printf 'PASS: %s\n' "$description"
  else
    printf 'FAIL: %s\n' "$description"
    failures=$((failures + 1))
  fi
}

check "httpd is active" systemctl is-active --quiet httpd
check "httpd is enabled" systemctl is-enabled --quiet httpd
check "workload marker is returned" bash -c "curl --fail --silent http://127.0.0.1/ | grep -q MIGRATION_WORKLOAD_OK"
check "SELinux is enforcing" bash -c "test \"$(getenforce)\" = Enforcing"
check "firewalld exposes HTTP" bash -c "sudo firewall-cmd --query-service=http >/dev/null"

if (( failures > 0 )); then
  printf '%d health check(s) failed.\n' "$failures"
  exit 1
fi

echo "All workshop health checks passed."

