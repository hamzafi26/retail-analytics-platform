from src.config.settings import DATA_PATH, EXPECTED_DATA_FILES
from pathlib import Path
import pandas as pd

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


# def check_files_not_empty():
#     not_empty = True
#     for file in files_name.values():
#         if isinstance(file, str):
#             data = pd.read_csv(data_path / file)
#             print([d != "" for d in data.head()])
#             header_is_not_empty = data.head().apply(lambda x: x != "")
#             not_empty &= header_is_not_empty.all()
#             if data.empty:
#                 not_empty = False
