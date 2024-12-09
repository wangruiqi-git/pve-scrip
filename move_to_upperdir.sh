#!/bin/bash
wkdir=`pwd`
for file in *; do
	if [[ -d "$file" ]]; then
		echo "移动 $file"
		cd "$file"
		for file2 in *; do
			mv "$file2" "$wkdir/"
		done
		cd "$wkdir"
	fi
done
echo "所有文件move到上一层完毕。"
