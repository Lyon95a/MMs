import pandas as pd
import os
import sys
args = sys.argv

if len(args) > 1:
    arg1 = args[1]
    arg2 = args[2]

file_path = arg1
df = pd.read_csv(file_path, sep='\t',header=None)

df1 = pd.DataFrame({})
df1['sample-id'] = ''
df1['forward-absolute-filepath'] = ''
df1['reverse-absolute-filepath'] = ''

path1=arg2
suffix_forw='_1.fastq'
suffix_reverse='_2.fastq'
for i, row in df.iterrows():
    basenames = os.path.basename(row[0]) 
    sample = basenames.split('_')
    df1.loc[i, 'sample-id'] = sample[0]
    full_path_F = path1 + sample[0] + suffix_forw
    full_path_R = path1 + sample[0] + suffix_reverse
    df1.loc[i, 'forward-absolute-filepath'] = full_path_F
    df1.loc[i, 'reverse-absolute-filepath'] = full_path_R

father_path=os.path.dirname(file_path)
out_path=os.path.join(father_path, 'manifest.tsv')
df.to_csv(out_path, sep='\t', index=False)


