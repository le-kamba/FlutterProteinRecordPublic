#!/bin/sh

rm ./test_driver/screenshots/*.png 2>/dev/null

flutter clean
flutter drive --target=test_driver/update.dart
flutter drive --target=test_driver/main.dart
