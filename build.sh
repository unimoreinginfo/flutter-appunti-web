#!/bin/bash

git clone https://github.com/flutter/flutter.git

export FLUTTER_HOME=./flutter
export PATH=$PATH:./flutter/bin
flutter channel beta
flutter upgrade
flutter pub version
flutter config --enable-web

flutter doctor
flutter build web