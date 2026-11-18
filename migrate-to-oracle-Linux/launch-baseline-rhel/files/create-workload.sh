#!/usr/bin/env bash
set -euo pipefail

sudo dnf install -y httpd firewalld curl policycoreutils

sudo install -d -m 0755 /opt/ol-migration-lab
sudo tee /var/www/html/index.html >/dev/null <<'EOF'
<!doctype html>
<html lang="en">
<head><meta charset="utf-8"><title>Oracle Linux Migration Workshop</title></head>
<body>
<h1>Oracle Linux Migration Workshop</h1>
<p id="status">MIGRATION_WORKLOAD_OK</p>
<p>This page must remain available before and after the operating system migration.</p>
</body>
</html>
EOF

sudo systemctl enable --now firewalld
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --reload
sudo restorecon -Rv /var/www/html
sudo systemctl enable --now httpd

curl --fail --silent http://127.0.0.1/ | grep -q MIGRATION_WORKLOAD_OK
echo "Workload created successfully."

