import os

try:
    from dotenv import load_dotenv
    load_dotenv()
except Exception:
    pass

from oracle_vecdb import Configuration, OracleVecDB


def make_client():
    rest_url = os.environ["VECDB_REST_URL"]
    access_token = os.environ.get("VECDB_ACCESS_TOKEN", "").strip() or None
    username = os.environ.get("VECDB_USERNAME", "").strip() or None
    password = os.environ.get("VECDB_PASSWORD", "").strip() or None

    kwargs = {"rest_url": rest_url}
    if access_token:
        kwargs["access_token"] = access_token
    else:
        kwargs["username"] = username
        kwargs["password"] = password

    try:
        return OracleVecDB(Configuration(**kwargs))
    except TypeError:
        kwargs["host"] = kwargs.pop("rest_url")
        return OracleVecDB(Configuration(**kwargs))


def as_dict(value):
    if hasattr(value, "to_dict"):
        return value.to_dict()
    return value


def print_items(label, value):
    print(f"\n{label}")
    data = as_dict(value)
    if isinstance(data, dict) and "items" in data:
        for item in data["items"]:
            print(item)
    else:
        print(data)
