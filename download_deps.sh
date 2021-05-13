#!/bin/bash

cd android/src/main || exit
git clone https://github.com/uber/h3

mkdir jniLibs || echo "Build folder exists"
cd jniLibs
cmake ..
make h3
