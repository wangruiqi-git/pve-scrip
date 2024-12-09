#!/bin/bash
 
# 指定包含zip文件的目录
#zip_dir="/path/to/zip/files"
 
# 进入zip文件目录
#cd "$zip_dir" || exit
 
# 批量解压所有zip文件
for zip_file in *.zip; do
  echo "正在解压 ${zip_file} ..."
  unzip "$zip_file"
done
 
echo "所有zip文件解压完毕。"
