import pandas as pd
import os
import sys
args = sys.argv

if len(sys.argv) < 4:
    print("Usage: script.py <file_path> <path1> <dataset_name>")
    sys.exit(1)

file_path, path1, dataset_name = sys.argv[1], sys.argv[2], sys.argv[3]

print(dataset_name)

try:
    df = pd.read_csv(file_path, sep='\t', header=None)
except Exception as e:
    print(f"Failed to read the file: {e}")
    sys.exit(1)

df1 = pd.DataFrame({})
df1['sample-id'] = ''
df1['forward-absolute-filepath'] = ''
df1['reverse-absolute-filepath'] = ''

suffix_forw='_1.fastq'
suffix_reverse='_2.fastq'
for i, row in df.iterrows():
    basenames = os.path.basename(row[0]) 
    sample = basenames.rsplit('_', 1)[0]
    df1.loc[i, 'sample-id'] = sample
    full_path_F = path1 + sample + suffix_forw
    full_path_R = path1 + sample + suffix_reverse
    df1.loc[i, 'forward-absolute-filepath'] = full_path_F
    df1.loc[i, 'reverse-absolute-filepath'] = full_path_R

df_unique = df1.drop_duplicates(subset=['sample-id'])

father_path=os.path.dirname(file_path)
out_path=os.path.join(father_path, f"{dataset_name}_manifest.tsv")
print(out_path)
df_unique.to_csv(out_path, sep='\t', index=False)


