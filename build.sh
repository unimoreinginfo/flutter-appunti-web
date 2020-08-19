#!/bin/bash

git clone https://github.com/flutter/flutter.git
cd flutter
git checkout beta
git pull
cd ..
flutter/bin/flutter config --enable-web
flutter/bin/flutter doctor
flutter/bin/flutter build web