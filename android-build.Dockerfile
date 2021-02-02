ARG  JDK_VERSION=8
FROM openjdk:${JDK_VERSION}-jdk-alpine
ARG  GRADLE_VERSION="5.6.4"
ARG  BUILD_TOOLS="28.0.3"
ARG  TARGET_SDK=28

ARG APK_GLIBC_VERSION=2.29-r0
ARG APK_GLIBC_FILE="glibc-${APK_GLIBC_VERSION}.apk"
ARG APK_GLIBC_BIN_FILE="glibc-bin-${APK_GLIBC_VERSION}.apk"
ARG APK_GLIBC_BASE_URL="https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${APK_GLIBC_VERSION}"

ENV  GRADLE_HOME="/opt/gradle"
ENV  ANDROID_SDK_ROOT="/opt/sdk"
ENV  ANDROID_HOME=${ANDROID_SDK_ROOT}
ENV  CMDLINE_VERSION="3.0"
ENV  SDK_TOOLS="6858069"
ENV  PATH=$PATH:${ANDROID_SDK_ROOT}/cmdline-tools/${CMDLINE_VERSION}/bin:${ANDROID_SDK_ROOT}/platform-tools:${ANDROID_SDK_ROOT}/extras/google/instantapps
ENV  PATH=$PATH:${ANDROID_SDK_ROOT}/build-tools/${BUILD_TOOLS}

VOLUME /home/gradle/.gradle

RUN apk add --no-cache bash libstdc++ git unzip wget openssl ca-certificates  && \
rm -rf /tmp/* && \
rm -rf /var/cache/apk/*

RUN wget https://dl.google.com/android/repository/commandlinetools-linux-${SDK_TOOLS}_latest.zip -O /tmp/tools.zip && \
mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools && \
unzip -qq /tmp/tools.zip -d ${ANDROID_SDK_ROOT}/cmdline-tools && \
mv ${ANDROID_SDK_ROOT}/cmdline-tools/* ${ANDROID_SDK_ROOT}/cmdline-tools/${CMDLINE_VERSION} && \
rm -v /tmp/tools.zip

RUN wget -O gradle.zip "https://downloads.gradle-dn.com/distributions/gradle-${GRADLE_VERSION}-bin.zip" -O /tmp/gradle.zip && \
unzip -qq /tmp/gradle.zip -d /tmp && \
rm  /tmp/gradle.zip && mv /tmp/gradle* ${GRADLE_HOME} && ln -s "${GRADLE_HOME}/bin/gradle" /usr/bin/gradle


RUN mkdir -p ~/.android/ && touch ~/.android/repositories.cfg && \
yes | sdkmanager --sdk_root=${ANDROID_SDK_ROOT} --licenses && \
sdkmanager --sdk_root=${ANDROID_SDK_ROOT} --install "extras;google;instantapps" "build-tools;${BUILD_TOOLS}" "platforms;android-${TARGET_SDK}" && \
sdkmanager --uninstall emulator

RUN wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub \
    && wget "${APK_GLIBC_BASE_URL}/${APK_GLIBC_FILE}"       \
    && apk --no-cache add "${APK_GLIBC_FILE}"               \
    && wget "${APK_GLIBC_BASE_URL}/${APK_GLIBC_BIN_FILE}"   \
    && apk --no-cache add "${APK_GLIBC_BIN_FILE}"           \
    && rm glibc-*

RUN gradle --version

CMD ["bash"]
