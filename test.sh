#!/bin/sh

mkdir -p ./test-reports/ 2>/dev/null

flutter clean

flutter test --machine > machine.log
cat machine.log | tojunit --output ./test-reports/TEST-results.xml
echo 'Tests done.'
flutter pub global run dart_dot_reporter machine.log
junit2html ./test-reports/TEST-results.xml ./test-reports/index.html