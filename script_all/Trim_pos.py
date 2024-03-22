import numpy as np
import sys
args = sys.argv

if len(args) > 1:
    arg1 = args[1]

with open(arg1, 'r') as file:
    tsv_data = file.readlines()
    
row_name = tsv_data[4].split('\t')[0]
row_values = list(map(float, tsv_data[4].strip().split('\t')[1:]))
row_values1 = ['NA' if value < 20 else value for value in row_values]

mid=100
na_indices = [i for i, value in enumerate(row_values1) if value == 'NA']

before = [i for i in na_indices if i < mid]
after = [i for i in na_indices if i >= mid]

start = max(before) + 2 if before else 1
end = min(after) if after else len(row_values)

print(f"{start},{end}")



