-- Lab 1/5/6 helper: prints YOUR fully-substituted commands so you never edit
-- a URL or credential by hand. Run in SQLcl or the SQL worksheet after
-- filling the three DEFINEs from your reservation page.
DEFINE adb_host    = 'HOST.adb.REGION.oraclecloudapps.com'
DEFINE schema_user = 'USERNAME'
DEFINE schema_pass = 'PASSWORD'

SELECT 'mongosh ''mongodb://&schema_user:&schema_pass@&adb_host:27017/&schema_user'
       || '?authMechanism=PLAIN&authSource=$external&tls=true'
       || '&retryWrites=false&loadBalanced=true''' AS mongosh_command
FROM dual;

SELECT 'curl -s -u ''&schema_user:&schema_pass'' https://&adb_host/ords/'
       || LOWER('&schema_user') || '/store_menu_dv/s_100' AS rest_read_command
FROM dual;

SELECT 'export ORDS_BASE="https://&adb_host/ords/' || LOWER('&schema_user') || '"'
       || CHR(10) || 'export ORDS_USER="&schema_user"'
       || CHR(10) || 'export ORDS_PASS="&schema_pass"' AS etag_lab_exports
FROM dual;
