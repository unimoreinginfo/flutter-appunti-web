#!/bin/bash

git clone https://github.com/flutter/flutter.git -b beta

export FLUTTER_HOME=./flutter
export FLUTTER=./flutter/bin/flutter
$FLUTTER channel beta
$FLUTTER upgrade
$FLUTTER pub version
$FLUTTER config --enable-web
$FLUTTER doctor
$FLUTTER build web