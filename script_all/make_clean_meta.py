import sys
import os
import pandas as pd
import numpy as np

args = sys.argv

if len(args) > 1:
    file_path = args[1]
    Data_col_name = args[2]
    sra=args[3]
    forward = args[4]
    reverse = args[5]
    

directory_path = os.path.dirname(file_path)
df = pd.read_csv(file_path)

datasets = np.array([str(x).strip().replace('\t', '') for x in df[Data_col_name].dropna().unique()], dtype=object)

for value in datasets:
    exec(f"{value} = pd.DataFrame()")
    exec(f"{value} = df[df[Data_col_name] == '{value}'].copy()")
    exec(f"{value}_sra={value}[sra]")
    folder_path = f"{directory_path}/{value}/"
    if not os.path.exists(folder_path):
        os.makedirs(folder_path)
        print("folder has been generated")
    else:
        print("folder existed, pass")
    globals()[f"path_{value}"] = folder_path
    exec(f"{value}_sra.to_csv('{folder_path}{value}_sra.txt', header=None, index=None)")

df_unique = df.drop_duplicates(subset=[Data_col_name])
columns_to_keep = [Data_col_name, forward, reverse]
new_df = df_unique[columns_to_keep].copy()
out_path = os.path.join(directory_path, 'primer.tsv')
new_df.to_csv(out_path, sep='\t', header=False, index=False)