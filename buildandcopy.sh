#!/bin/sh
flutter build web --release --dart-define=FLUTTER_WEB_USE_SKIA=true
scp -r -i $KEY_LOCATION build/web $USERNAME@appunti.me:/home/inginfo/flutter-appunti-web/build/