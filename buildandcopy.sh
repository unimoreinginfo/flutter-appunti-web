#!/bin/sh
flutter build web --release --dart-define=FLUTTER_WEB_USE_SKIA=true
scp -r -i ~/appunti.key build/web inginfo@appunti.me:/home/inginfo/flutter-appunti-web/build/