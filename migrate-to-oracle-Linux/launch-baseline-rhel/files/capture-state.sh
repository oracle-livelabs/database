#!/usr/bin/env bash
set -u

label="${1:-state}"
timestamp="$(date -u +%Y%m%dT%H%M%SZ)"
out="${HOME}/ol-migration-evidence/${label}-${timestamp}"
mkdir -p "$out"

run_capture() {
  local name="$1"
  shift
  "$@" >"${out}/${name}.txt" 2>&1 || true
}

run_capture os-release cat /etc/os-release
run_capture kernel uname -a
run_capture repositories sudo dnf repolist --enabled
run_capture packages rpm -qa --qf '%{NAME}\t%{EPOCHNUM}:%{VERSION}-%{RELEASE}.%{ARCH}\t%{VENDOR}\n'
run_capture failed-services systemctl --failed --no-pager
run_capture httpd-status systemctl status httpd --no-pager
run_capture enabled-services systemctl list-unit-files --state=enabled --no-pager
run_capture listening-ports sudo ss -lntup
run_capture addresses ip address show
run_capture routes ip route show
run_capture selinux getenforce
run_capture firewall sudo firewall-cmd --list-all
run_capture application curl --fail --silent --show-error http://127.0.0.1/
run_capture application-sha256 sha256sum /var/www/html/index.html

tar -C "$(dirname "$out")" -czf "${out}.tar.gz" "$(basename "$out")"
echo "Evidence directory: $out"
echo "Evidence archive: ${out}.tar.gz"

