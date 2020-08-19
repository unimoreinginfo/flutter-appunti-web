#!/bin/bash

git clone https://github.com/flutter/flutter.git

export FLUTTER_HOME=./flutter
export PATH=$PATH:./flutter/bin
flutter config --enable-web
flutter channel beta
flutter upgrade
flutter pub version
flutter doctor
flutter build web