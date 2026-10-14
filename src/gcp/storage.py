from google.cloud import storage
from src.config.settings import GCP_PROJECT_ID, GCS_BUCKET


def get_storage_client():
    return storage.Client(project=GCP_PROJECT_ID)


def list_raw_files():
    client = get_storage_client()

    blobs = client.list_blobs(GCS_BUCKET, prefix="raw/")
    res = [blob.name for blob in blobs]
    return res
