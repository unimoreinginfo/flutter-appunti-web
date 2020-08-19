#!/bin/bash

git clone https://github.com/flutter/flutter.git
cd flutter
git checkout beta
git pull
cd ..
alias flbin="flutter/bin/flutter"
flbin config --enable-web
flbin doctor
flbin build web