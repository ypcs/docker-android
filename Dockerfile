FROM ypcs/debian:buster

ENV JAVA_VERSION 8

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

ENV ANDROID_HOME /home/user/android/sdk
ENV ANDROID_VERSION 28
ENV ANDROID_BUILD_TOOLS_VERSION 28.0.3
ENV ANDROID_SDK_TOOLS_VERSION 4333796

# <https://medium.com/@AndreSand/building-android-with-docker-8dbf717f54d4>
RUN mkdir -p android/sdk && \
    cd android/sdk && \
    curl -fSL -o sdk-tools.zip "https://dl.google.com/android/repository/sdk-tools-linux-${ANDROID_SDK_TOOLS_VERSION}.zip" && \
    unzip sdk-tools.zip && \
    rm sdk-tools.zip

RUN yes |./android/sdk/tools/bin/sdkmanager --licenses
RUN ./android/sdk/tools/bin/sdkmanager --update

RUN ./android/sdk/tools/bin/sdkmanager "build-tools;${ANDROID_BUILD_TOOLS_VERSION}" "platforms;android-${ANDROID_VERSION}" "platform-tools"
