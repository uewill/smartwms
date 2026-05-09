#!/bin/bash
export PATH="/opt/flutter/bin:$PATH"
export ANDROID_HOME=/opt/android-sdk
export ANDROID_SDK_ROOT=/opt/android-sdk
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
cd /workspace/smartwms/app
flutter build apk --debug
