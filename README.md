docker 构建android 28 环境

``
ARG  JDK_VERSION=8
FROM openjdk:${JDK_VERSION}-jdk-alpine
ARG  GRADLE_VERSION="5.6.4"
ARG  BUILD_TOOLS="28.0.3"
ARG  TARGET_SDK=28
ARG APK_GLIBC_VERSION=2.29-r0
```
