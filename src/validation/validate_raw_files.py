from src.config.settings import DATA_PATH, EXPECTED_DATA_FILES
from pathlib import Path
import pandas as pd
import json

data_path = DATA_PATH
files_name = EXPECTED_DATA_FILES


def check_existing_files():
    exist = True
    for file in files_name.values():
        if isinstance(file, str):
            file_path = data_path / file
            exist &= file_path.exists()
        else:
            for part in file:
                file_path = data_path / part
                exist &= file_path.exists()
    return exist


def check_data(file):
    data = pd.read_csv(data_path / file)
    return {
        "empty_data": len(data) != 0,
        "headers_named": all(
            str(col).strip() != "" and not str(col).strip().startswith("Unnamed:")
            for col in data.columns
        ),
    }


def check_headers_and_data():
    success_check = True
    data_status = {}
    for data_name, file in files_name.items():
        if isinstance(file, str):
            data_status[data_name] = check_data(file)
            if (
                not data_status[data_name]["empty_data"]
                or not data_status[data_name]["headers_named"]
            ):
                success_check = False
        else:
            data_status[data_name] = []
            d = {}
            for v in file:
                d = {v: check_data(v)}
                if not d[v]["empty_data"] or not d[v]["headers_named"]:
                    success_check = False
                data_status[data_name].append(d)
    return data_status, success_check


existing_files = check_existing_files()
if existing_files:
    data_status, success_check = check_headers_and_data()
    if success_check:
        print(json.dumps(data_status, indent=2))
