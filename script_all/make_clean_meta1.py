import sys
import os
import pandas as pd
import numpy as np

args = sys.argv

if len(args) > 1:
    file_path = args[1]
    Datasets_ID = args[2]
    Bioproject = args[3]
    SRA_Number= args[4]
    Biosample = args[5]
    region = args[6]
    
    
directory_path = os.path.dirname(file_path)
df = pd.read_csv(file_path)
df[Bioproject] = df[Bioproject].str.replace(' ', '', regex=True).str.replace('\n', '', regex=True).str.replace('\t', '', regex=True)
df[SRA_Number] = df[SRA_Number].str.replace(' ', '', regex=True).str.replace('\n', '', regex=True).str.replace('\t', '', regex=True)
df[Biosample] = df[Biosample].str.replace(' ', '', regex=True).str.replace('\n', '', regex=True).str.replace('\t', '', regex=True)
df[Datasets_ID] = df[Datasets_ID].str.replace(' ', '', regex=True).str.replace('\n', '', regex=True).str.replace('\t', '', regex=True)
df[region] = df[region].str.replace(' ', '', regex=True).str.replace('\n', '', regex=True).str.replace('\t', '', regex=True)
datasets = np.array([str(x).strip().replace('\t', '') for x in df[Datasets_ID].dropna().unique()], dtype=object)
print(f"{directory_path}/datasets_ID.txt")
print(directory_path)
np.savetxt(f"{directory_path}/datasets_ID.txt", datasets, fmt="%s")
df["rename"]= df[Datasets_ID] + '_' + df[Bioproject] + '_' + df[SRA_Number] + '_' + df[Biosample]

for value in datasets:
    exec(f"{value} = pd.DataFrame()")
    exec(f"{value} = df[df[Datasets_ID] == '{value}'].copy()")
    exec(f"{value}_sra={value}[SRA_Number]")
    exec(f"{value}_rename={value}['rename']")
    exec(f"{value}_region={value}[region]")
    exec(f"{value}_1 = pd.DataFrame()")
    exec(f"{value}_1 = pd.concat([{value}_sra, {value}_rename, {value}_region], axis=1)")
    folder_path = f"{directory_path}/{value}/"
    if not os.path.exists(folder_path):
        os.makedirs(folder_path)
        print("folder has been generated")
    else:
        print("folder existed, pass")
    globals()[f"path_{value}"] = folder_path
    exec(f"{value}_1.to_csv('{folder_path}{value}_sra.txt', sep='\t',  header=None, index=None)")
    