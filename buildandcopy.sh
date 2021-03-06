#!/bin/sh
flutter build web --release
scp -r -i $KEY_LOCATION build/web inginfo@appunti.me:/home/inginfo/flutter-appunti-web/build/
