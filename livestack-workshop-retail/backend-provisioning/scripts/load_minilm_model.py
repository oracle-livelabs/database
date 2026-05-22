#!/usr/bin/env python3
"""Load all_MiniLM_L12_v2.onnx into an Oracle AI Database schema.

Use this when the backend provisioner has the ONNX file locally and does not
want to stage it in DATA_PUMP_DIR. Run after Stage 1 creates the schema owner
and before Stage 2 runs schema/04_vector_schema.sql. If the model already exists,
this script exits cleanly.
"""
import argparse
import getpass
from pathlib import Path
import sys

try:
    import oracledb
except ImportError as exc:
    raise SystemExit('Install python-oracledb first: python3 -m pip install oracledb') from exc

METADATA = '{"function":"embedding","embeddingOutput":"embedding","input":{"input":["DATA"]}}'


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--onnx', required=True, help='Path to all_MiniLM_L12_v2.onnx')
    parser.add_argument('--user', default='RETAILDB')
    parser.add_argument('--dsn', default='pats26aiadb_medium')
    parser.add_argument('--config-dir', help='Wallet / network admin directory')
    parser.add_argument('--wallet-location', help='Wallet directory for python-oracledb thin mode')
    parser.add_argument('--wallet-password', help='Wallet password. Omit to prompt.')
    parser.add_argument('--password', help='Database password. Omit to prompt.')
    args = parser.parse_args()

    onnx = Path(args.onnx).expanduser().resolve()
    if not onnx.exists():
        raise SystemExit(f'ONNX file not found: {onnx}')

    db_password = args.password or getpass.getpass(f'{args.user} password: ')
    wallet_password = args.wallet_password
    if args.wallet_location and wallet_password is None:
        wallet_password = getpass.getpass('Wallet password: ')

    connect_kwargs = {
        'user': args.user,
        'password': db_password,
        'dsn': args.dsn,
    }
    if args.config_dir:
        connect_kwargs['config_dir'] = args.config_dir
    if args.wallet_location:
        connect_kwargs['wallet_location'] = args.wallet_location
    if wallet_password:
        connect_kwargs['wallet_password'] = wallet_password

    with oracledb.connect(**connect_kwargs) as conn:
        with conn.cursor() as cur:
            cur.execute("select count(*) from user_mining_models where model_name = 'ALL_MINILM_L12_V2'")
            if cur.fetchone()[0]:
                print('Model ALL_MINILM_L12_V2 already exists; skipping load.')
                return

            print(f'Loading {onnx.name} ({onnx.stat().st_size} bytes) into {args.user}...')
            blob = conn.createlob(oracledb.DB_TYPE_BLOB)
            offset = 1
            with onnx.open('rb') as f:
                while True:
                    chunk = f.read(1024 * 1024)
                    if not chunk:
                        break
                    blob.write(chunk, offset)
                    offset += len(chunk)

            cur.execute("""
                BEGIN
                    DBMS_VECTOR.LOAD_ONNX_MODEL(
                        model_name => 'ALL_MINILM_L12_V2',
                        model_data => :model_blob,
                        metadata   => JSON(:metadata)
                    );
                END;
            """, model_blob=blob, metadata=METADATA)
            conn.commit()
            print('Model ALL_MINILM_L12_V2 loaded.')

            cur.execute("select model_name, mining_function from user_mining_models where model_name = 'ALL_MINILM_L12_V2'")
            for row in cur:
                print(row)


if __name__ == '__main__':
    main()
