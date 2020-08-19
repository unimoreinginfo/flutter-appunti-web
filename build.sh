#!/bin/bash

git clone https://github.com/flutter/flutter.git -b beta

export FLUTTER_HOME=./flutter
export FLUTTER=./flutter/bin/flutter
$FLUTTER config --enable-web
$FLUTTER pub version
$FLUTTER doctor
$FLUTTER build web