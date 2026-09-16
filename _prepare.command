#!/bin/bash
set -e
filepath=$(cd "$(dirname "$0")"; pwd)
cd "$filepath"

echo Creating build directory...
# rm -r build
mkdir -p build
cp -r src/. build
cd build

# echo 正在备份文件...
# mkdir tmp
mkdir -p __Hash
# python3 tools/_backup.py xlsx/xlsxList.txt xlsx/ 0 2

chmod +x ./_importBuild.sh
if [[ "$OSTYPE" == "darwin"* ]]; then
	xattr -d com.apple.quarantine ./_importBuild.sh
fi
./_importBuild.sh
