FROM ypcs/debian:bullseye

ARG APT_PROXY

ENV JAVA_VERSION 11

RUN /usr/lib/docker-helpers/apt-setup && \
    /usr/lib/docker-helpers/apt-upgrade && \
    apt-get --assume-yes install \
        build-essential \
        curl \
        file \
        openjdk-${JAVA_VERSION}-jdk-headless \
        openjdk-${JAVA_VERSION}-jre-headless \
        unzip && \
    /usr/lib/docker-helpers/apt-cleanup

RUN adduser --disabled-password --gecos "user,,," user

USER user
WORKDIR /home/user
# https://dl.google.com/android/repository/commandlinetools-linux-6858069_latest.zip
ENV ANDROID_HOME /home/user/android/sdk
ENV ANDROID_VERSION 29
ENV ANDROID_TOOLS_VERSION 6858069
ENV ANDROID_BUILD_TOOLS_VERSION 29.0.2

# <https://medium.com/@AndreSand/building-android-with-docker-8dbf717f54d4>
RUN mkdir -p android/sdk && \
    cd android/sdk && \
    curl -fSL -o sdk-tools.zip "https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_TOOLS_VERSION}_latest.zip" && \
    unzip sdk-tools.zip && \
    rm sdk-tools.zip

RUN yes |./android/sdk/cmdline-tools/bin/sdkmanager --licenses --sdk_root="${ANDROID_HOME}"
RUN ./android/sdk/cmdline-tools/bin/sdkmanager --update --sdk_root="${ANDROID_HOME}"
RUN ./android/sdk/cmdline-tools/bin/sdkmanager --list --sdk_root="${ANDROID_HOME}"

RUN ./android/sdk/cmdline-tools/bin/sdkmanager --sdk_root="${ANDROID_HOME}" "build-tools;${ANDROID_BUILD_TOOLS_VERSION}" "platforms;android-${ANDROID_VERSION}" "platform-tools"

ENV PATH="${PATH}:${ANDROID_HOME}/cmdline-tools/bin"
