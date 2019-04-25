import os
from logging import getLogger

import hvac
from airflow.operators.postgres_operator import PostgresOperator

SECRET_DIR = os.path.join(
    os.path.dirname(os.path.dirname(os.path.realpath(__file__))),
    'secrets')
logger = getLogger('util')


def read_file(fp):
    with open(fp, 'r') as f:
        data = f.read()
    return data


def vault_auth(role_id=os.getenv("VAULT_ROLE_ID"),
               secret_id=os.getenv("VAULT_SECRET_ID")):
    client = hvac.Client(os.environ["VAULT_ENDPOINT"])
    client.auth_approle(role_id, secret_id)
    return client


def vault_read(secret_key,
               client,
               secret_path=os.getenv("VAULT_SECRET_PATH")):
    if secret_key is None:
        raise OSError("secret_key is missing")
    if secret_path is None:
        raise OSError("secret_path is missing")
    try:
        return str(client.read(secret_path)["data"][secret_key]).rstrip()
    except Exception:
        raise OSError(f"Unable to read {secret_path}:{secret_key} from Vault.")


def local_read(secret_key):
    try:
        return read_file(os.path.join(SECRET_DIR, secret_key)).rstrip()
    except FileNotFoundError:
        try:
            return os.environ[secret_key].rstrip()
        except KeyError:
            raise OSError(f"{secret_key} environment variable is not set.")


def read_secret(secret_key, client=None, vault_secret_path=None):
    if client and vault_secret_path:
        return vault_read(secret_key, client, vault_secret_path)
    if client:
        return vault_read(secret_key, client)
    return local_read(secret_key)


def log_exception_and_return_none(exception_type: BaseException):
    """
    Decorator which wraps a function and causes it to return none and logs when it raises exception of exception_type
    :param exception_type: Specific Exception type or a list of Exceptions
    :return:
    """

    def actual_decorator(decorated_function):

        def decorated(*args, **kwargs):
            try:
                return decorated_function(*args, **kwargs)
            except exception_type as e:
                logger.exception(e)
                return None

        return decorated

    return actual_decorator
