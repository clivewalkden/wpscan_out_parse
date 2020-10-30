#! /bin/bash

title="WPScan Output Parser"
module_folder="wpscan_out_parse"
version="$(python3 setup.py -V)"

rm -rf ./dist
rm -fr ./build
rm -fr ./wpscan_out_parse.egg-info

# Ask to format code and push it
echo "[QUESTION] Do you want to format code with black ?"
read REPLY < /dev/tty
if [ "$REPLY" = "y" ] || [ "$REPLY" = "yes" ] || [ "$REPLY" = "Y" ] || [ "$REPLY" = "Yes" ]; then
    black "${module_folder}/"
    # git add "${module_folder}"
    # git commit -m "Format code"
    # git push
fi

# Ask to generate classes image
echo "[QUESTION] Do you want to generate the classes images ?"
read REPLY < /dev/tty
if [ "$REPLY" = "y" ] || [ "$REPLY" = "yes" ] || [ "$REPLY" = "Y" ] || [ "$REPLY" = "Yes" ]; then
    pyreverse -s 1 -f PUB_ONLY -o png -m y "${module_folder}"
    # git add ./packages.png
    # git add ./classes.png
    # git commit -m "Generate classes image"
    # git push
fi

# Ask to publish
echo "[QUESTION] Do you want to build and publish this version (${version}) to PyPi ?"
read REPLY < /dev/tty
if [ "$REPLY" = "y" ] || [ "$REPLY" = "yes" ] || [ "$REPLY" = "Y" ] || [ "$REPLY" = "Yes" ]; then
    python3 setup.py build check sdist bdist_wheel
    python3 -m twine upload --verbose dist/*
    python3 setup.py clean
    rm -rf ./dist
    rm -fr ./build
    rm -fr ./wpscan_out_parse.egg-info
fi

# Ask to Tag ?
echo "[QUESTION] Do you want to tag this version ${version}? You'll be asked to write the tag message. [y/n]"
read REPLY < /dev/tty
if [ "$REPLY" = "y" ] || [ "$REPLY" = "yes" ] || [ "$REPLY" = "Y" ] || [ "$REPLY" = "Yes" ]; then

    # Tag
    touch ./tmp_tag.txt
    echo "${title} ${version}" > ./tmp_tag.txt
    echo >> ./tmp_tag.txt
    echo "New features: " >> ./tmp_tag.txt
    echo >> ./tmp_tag.txt
    echo "Fixes:" >> ./tmp_tag.txt
    vi ./tmp_tag.txt
    tag_msg=`cat ./tmp_tag.txt`
    echo "${tag_msg}"
    echo "[QUESTION] Are you sure, tag this version with the message? [y/n]"
    read REPLY < /dev/tty
    if [ "$REPLY" = "y" ] || [ "$REPLY" = "yes" ] || [ "$REPLY" = "Y" ] || [ "$REPLY" = "Yes" ]; then
        echo "[RUNNING] git tag -a ${version} -m ${tag_msg} && git push --tags"
        git tag -a ${version} -F ./tmp_tag.txt && git push --tags
        echo "[SUCCESS] Version ${version} tagged and pushed"
        echo "[INFO] You still need to create the realease from github"
    fi
    rm ./tmp_tag.txt
fi

echo "[END]"