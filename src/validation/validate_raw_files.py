from src.config.settings import DATA_PATH, SCHEMA_PATH, SCHEMA_FILES
from pathlib import Path
import pandas as pd
import json
import yaml

def check_existing_files():
    data_status = {}
    for data_name, schema_file in SCHEMA_FILES.items():
        with open(SCHEMA_PATH / schema_file, encoding="utf-8") as file:
            schema = yaml.safe_load(file)
            data_status[data_name] = {}
            files_exist = []
            not_empty_data = []
            headers_named = []
            for file in schema["files"]:
                file_path = DATA_PATH / file
                if file_path.exists():
                    files_exist.append(True)
                    data = pd.read_csv(file_path)
                    not_empty_data.append(len(data) != 0)
                    headers_named.append(
                        all(
                            str(col).strip() != ""
                            and not str(col).strip().startswith("Unnamed:")
                            for col in data.columns
                        )
                    )
                else:
                    files_exist.append(False)
                    not_empty_data.append(False)
                    headers_named.append(False)

            data_status[data_name]["files_exist"] = all(files_exist)
            data_status[data_name]["not_empty_data"] = all(not_empty_data)
            data_status[data_name]["headers_named"] = all(headers_named)

    return data_status


data_status = check_existing_files()
print(json.dumps(data_status, indent=2))
