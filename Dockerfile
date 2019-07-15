FROM stakater/pipeline-tools:v2.0.1

# Default to UTF-8 file.encoding
ENV LANG C.UTF-8

# Setup JAVA vars
ENV JAVA_HOME /usr/lib/jvm/java-1.8.0-openjdk-1.8.0.191.b12-1.el7_6.x86_64
ENV PATH $PATH:${JAVA_HOME}/jre/bin:/usr/lib/jvm/${JAVA_HOME}/bin
ENV JAVA_VERSION 8u191
ENV JAVA_YUM_VERSION 1.8.0.191.b12

# Install JDK
RUN yum install -y java-1.8.0-openjdk-devel-${JAVA_YUM_VERSION}

# Setup Group/User Permissions
ENV GRADLE_HOME /opt/gradle

RUN set -o errexit -o nounset \
    && echo "Adding gradle user and group" \
    && groupadd --system --gid 1000 gradle \
    && useradd --system --gid gradle --uid 1000 --shell /bin/bash --create-home gradle \
    && mkdir /home/gradle/.gradle \
    && chown --recursive gradle:gradle /home/gradle \
    \
    && echo "Symlinking root Gradle cache to gradle Gradle cache" \
    && ln -s /home/gradle/.gradle /root/.gradle

VOLUME /home/gradle/.gradle

WORKDIR /home/gradle

# Set Gradle version to 3.4.1 or 3.5(commented below),
ENV GRADLE_VERSION 3.4.1
# Download and Install Gradle 
ARG GRADLE_DOWNLOAD_SHA256=db1db193d479cc1202be843f17e4526660cfb0b21b57d62f3a87f88c878af9b2

# Uncomment below 2 lines to set Gradle version 3.5
# ENV GRADLE_VERSION 3.5
#ARG GRADLE_DOWNLOAD_SHA256=0b7450798c190ff76b9f9a3d02e18b33d94553f708ebc08ebe09bdf99111d110

RUN set -o errexit -o nounset \
    && echo "Downloading Gradle" \
    && wget --no-verbose --output-document=gradle.zip "https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip" \
    \
    && echo "Checking download hash" \
    && echo "${GRADLE_DOWNLOAD_SHA256} *gradle.zip" | sha256sum --check - \
    \
    && echo "Installing Gradle" \
    && unzip gradle.zip \
    && rm gradle.zip \
    && mv "gradle-${GRADLE_VERSION}" "${GRADLE_HOME}/" \
    && ln --symbolic "${GRADLE_HOME}/bin/gradle" /usr/bin/gradle \
    \
    && echo "Testing Gradle installation" \
    && gradle --version

CMD ["gradle"]