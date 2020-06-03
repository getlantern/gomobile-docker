FROM ubuntu:18.04
MAINTAINER Lantern Team <admin@getlantern.org>

RUN apt-get update && apt-get install -y build-essential curl git apt-utils openjdk-8-jdk curl wget unzip file pkg-config lsof libpcap-dev libappindicator3-dev libwebkit2gtk-4.0-dev

# The fpm packer. (https://rubygems.org/gems/fpm)
RUN apt-get install -y ruby ruby-dev
RUN gem install bundler -v '1.16.1'

# Packages for Windows.
RUN apt-get install -y mingw-w64 osslsigncode nsis

# Environment variables
ENV GOPATH /usr/local/gocode/
ENV PATH $PATH:/usr/local/go/bin
ENV PATH $PATH:$GOPATH/bin

# Environment variables
ENV GRADLE_VERSION 6.4.1
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64
ENV GRADLE_HOME /usr/local/gradle
ENV PATH $PATH:$ANDROID_HOME/tools
ENV PATH $PATH:$ANDROID_HOME/platform-tools
ENV PATH $PATH:/usr/local/go/bin
ENV PATH $PATH:$ANDROID_HOME/ndk-bundle
ENV PATH $PATH:/usr/local/gradle/bin

# Expect the $WORKDIR volume to be mounted.
ENV WORKDIR /lantern
VOLUME [ "$WORKDIR" ]
WORKDIR $WORKDIR

ENV ANDROID_HOME /usr/local/android-sdk-tools
ENV ANDROID_BIN /usr/local/android-sdk-tools/tools/bin

# Get the latest version from https://developer.android.com/studio/index.html
ENV ANDROID_SDK_TOOLS_VERSION="4333796"

# Get the latest version from https://developer.android.com/ndk/downloads/index.html
ENV ANDROID_NDK_VERSION="r21c"

# Install Android SDK
RUN echo "Installing sdk tools ${ANDROID_SDK_TOOLS_VERSION}" && \
    wget --quiet --output-document=sdk-tools.zip \
        "https://dl.google.com/android/repository/sdk-tools-linux-${ANDROID_SDK_TOOLS_VERSION}.zip" && \
    mkdir --parents "$ANDROID_HOME" && \
    unzip -q sdk-tools.zip -d "$ANDROID_HOME" && \
    rm --force sdk-tools.zip

# Install Android tools
RUN yes | $ANDROID_BIN/sdkmanager --licenses
RUN yes | $ANDROID_BIN/sdkmanager tools
RUN yes | $ANDROID_BIN/sdkmanager platform-tools
RUN yes | $ANDROID_BIN/sdkmanager ndk-bundle
RUN $ANDROID_BIN/sdkmanager platforms\;android-28

# Install Gradle
RUN cd /usr/local/ && \
wget https://downloads.gradle.org/distributions/gradle-$GRADLE_VERSION-bin.zip && \
unzip gradle-$GRADLE_VERSION-bin.zip && \
mv gradle-$GRADLE_VERSION gradle && \
rm gradle-$GRADLE_VERSION-bin.zip

ENV GO_VERSION 1.14.4

RUN curl -sSL https://storage.googleapis.com/golang/go$GO_VERSION.linux-__GOARCH__.tar.gz | tar -xvzf - -C /usr/local

# Install gomobile
RUN go get golang.org/x/mobile/cmd/gomobile
RUN go get golang.org/x/mobile/cmd/gobind
RUN gomobile init
