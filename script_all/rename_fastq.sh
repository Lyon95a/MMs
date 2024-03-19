# find $fastq_path -type f -name "*.fastq"| while read -r file; do
    
#     filename=$(basename "$file")

#     if [[ $filename =~ ^(.+)_([12])\.fastq ]]; then
        
#         new_filename="${BASH_REMATCH[1]}_R${BASH_REMATCH[2]}.fastq"
#         mv $file $fastq_path$new_filename
#         echo "Renamed $filename to $new_filename"

#     elif [[ $filename =~ ^.+_R[12]\.fastq ]]; then
#         echo "No need to modify $filename"

#     else
#         echo "Invalid filename structure. Exiting script."
#         exit 1
#     fi
# done