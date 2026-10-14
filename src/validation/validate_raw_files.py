from src.config.settings import DATA_PATH, SCHEMA_PATH, SCHEMA_FILES, CONVERTERS
from pathlib import Path
import pandas as pd
import json
import yaml
from src.gcp.storage import list_raw_files


def check_existing_files():
    data_status = {}
    for data_name, schema_file in SCHEMA_FILES.items():
        with open(SCHEMA_PATH / schema_file, encoding="utf-8") as file:
            schema = yaml.safe_load(file)
            data_status[data_name] = {}
            files_exist = []
            not_empty_data = []
            headers_named = []
            data_type_validated = []
            data_len = 0
            files_parsed = []
            for file in schema["files"]:
                file_path = DATA_PATH / file
                if file_path.exists():
                    files_exist.append(True)
                    try:
                        data = pd.read_csv(file_path)
                        files_parsed.append(True)
                    except (
                        pd.errors.ParserError,
                        UnicodeDecodeError,
                        OSError,
                    ) as error:
                        print("FAILED: ", file_path, " : ", error)
                        files_parsed.append(False)
                        continue

                    not_empty_data.append(len(data) != 0)
                    data_len += len(data)
                    headers_named.append(
                        all(
                            str(col).strip() != ""
                            and not str(col).strip().startswith("Unnamed:")
                            for col in data.columns
                        )
                    )
                    for column, rules in schema["columns"].items():
                        try:
                            convert = CONVERTERS[rules["type"]]
                            data[column] = convert(data[column])
                            data_type_validated.append(True)
                        except Exception as e:
                            print(e, " - ", column, " - ", data_name)
                            data_type_validated.append(False)
                            break
                else:
                    files_exist.append(False)
                    not_empty_data.append(False)
                    headers_named.append(False)

            data_status[data_name]["files_exist"] = (
                False if len(files_exist) == 0 else all(files_exist)
            )
            data_status[data_name]["parsing_file_fails"] = (
                False if len(files_parsed) == 0 else all(files_parsed)
            )
            data_status[data_name]["not_empty_data"] = (
                False if len(not_empty_data) == 0 else all(not_empty_data)
            )
            data_status[data_name]["headers_named"] = (
                False if len(headers_named) == 0 else all(headers_named)
            )
            data_status[data_name]["data_type_validated"] = (
                False if len(data_type_validated) == 0 else all(data_type_validated)
            )
            data_status[data_name]["count_rows"] = data_len
    return data_status


data_status = check_existing_files()
d_s = data_status.copy()

for data_name, status in d_s.items():
    if not all(value for key, value in status.items() if key != "count_rows"):
        print(data_name, ": Not Ok")
    else:
        print(data_name, ": Ok")

gcs_files = list_raw_files()
for data_name, schema_file in SCHEMA_FILES.items():
    with open(SCHEMA_PATH / schema_file, encoding="utf-8") as file:
        schema = yaml.safe_load(file)
        for file in schema["files"]:
            if not any(path.endswith(file) for path in gcs_files):
                print(file, " : Not exist in Google gloud Storage")



# print(json.dumps(data_status, indent=2))
