#!/usr/bin/env bash

GEN_REPO_LOCATION="$PWD/generated_apk"

if [[ ! -d ${GEN_REPO_LOCATION} ]]
then
  mkdir -p ${GEN_REPO_LOCATION};
fi

flutter build apk --split-per-abi

if ls $PWD/build/app/outputs/apk/release/app-arm64-*-release.apk 1> /dev/null 2>&1;
then
    cp $PWD/build/app/outputs/apk/release/app-arm64-*-release.apk $PWD/generated_apk
    echo "Apk successfully generated, you can find it here : $(ls ${GEN_REPO_LOCATION}/app-arm64-*-release.apk)";
else
    echo "Cannot find the generated apk, it should normally be generated here $PWD/build/app/outputs/apk/release/";
fi
