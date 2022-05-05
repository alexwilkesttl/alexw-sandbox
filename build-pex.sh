#!/usr/bin/env bash

REPO=$1
COMMIT=$2
PEX="${REPO}_${COMMIT}.pex"


if [[ ! $(python --version) =~ ^(Python 3\.7\.[0-9]+) ]];
then
    echo "ERROR - Wrong Python version, must be 3.7 but it's $(python --version)"
    exit 1
fi


echo "######################"
echo "BUILDING:"
echo $PEX
echo "PYTHON:"
echo $(python --version)
echo "######################"
echo ""


echo "DOWNLOADING REQUIREMENTS..."
pip download -r requirements.txt \
    --dest ./build/wheelhouse \
    --trusted-host artifactory.trainline.tools \
    --extra-index-url https://artifactory.trainline.tools/artifactory/api/pypi/pypi-internal-master/simple \
    --timeout 120


echo "BUILDING PEX..."
pex . \
    -r requirements.txt \
    -o ./dist/${PEX} \
    --find-links ./build/wheelhouse \
    --no-index

echo "BUILT PEX FILES (if successful):"
ls -la ./dist