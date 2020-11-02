# CREATE OBM APP
ARG VERSION="latest"
FROM jeffre/cbs:$VERSION as builder
RUN mkdir -p /tmp/obm/jvm
WORKDIR /tmp/obm

# Assemble OBM from its many components
RUN tar -xzvf /cbs/download/jvm/jre-std-linux-amd64.tar.gz \
    -C ./jvm \
    --anchored \
    --exclude="lib/amd64/libfontmanager.so" \
    --exclude="lib/amd64/libglib-lite.so" \
    --exclude="lib/amd64/libgstreamer-lite.so" \
    --exclude="lib/amd64/libjfxmedia.so" \
    --exclude="lib/amd64/libjfxwebkit.so" \
    --exclude="lib/amd64/libsplashscreen.so" \
    --exclude="lib/ext/jfxrt.jar" \
    --exclude="lib/ext/nashorn.jar" \
    --exclude="lib/fonts" \
    --exclude="lib/images"
RUN tar -xzvf /cbs/download/component/app-common.tar.gz \
    --anchored \
    --exclude="bin/help" \
    --exclude="bin/"
RUN tar -xzvf /cbs/download/component/app-native-nix-x64.tar.gz \
    --anchored \
    --exclude="bin/snappy/FreeBSD" \
    --exclude="bin/snappy/SunOS" \
    --exclude="bin/sqlite/FreeBSD" \
    --exclude="bin/sqlite/SunOS" \
    --exclude="bin/libFileSysUtilFbdX64.so" \
    --exclude="bin/libFileSysUtilLinP64.so" \
    --exclude="bin/libFileSysUtilObdX64.so" \
    --exclude="bin/libFileSysUtilSosX64.so" \
    --exclude="bin/libNixUtilFbdX64.so" \
    --exclude="bin/libNixUtilLinP64.so" \
    --exclude="bin/libNixUtilObdX64.so" \
    --exclude="bin/libNixUtilSosX64.so"
RUN tar -xzvf /cbs/download/component/app-nix-obm.tar.gz
RUN tar -xzvf /cbs/download/component/aua-common.tar.gz
RUN tar -xzvf /cbs/download/component/aua-native-nix-x64.tar.gz \
    --anchored \
    --exclude="aua/lib/snappy/FreeBSD" \
    --exclude="aua/lib/snappy/SunOS" \
    --exclude="aua/lib/sqlite/FreeBSD" \
    --exclude="aua/lib/sqlite/SunOS" \
    --exclude="aua/lib/libFileSysUtilFbdX64.so" \
    --exclude="aua/lib/libFileSysUtilLinP64.so" \
    --exclude="aua/lib/libFileSysUtilObdX64.so" \
    --exclude="aua/lib/libFileSysUtilSosX64.so" \
    --exclude="aua/lib/libNixUtilFbdX64.so" \
    --exclude="aua/lib/libNixUtilLinP64.so" \
    --exclude="aua/lib/libNixUtilObdX64.so" \
    --exclude="aua/lib/libNixUtilSosX64.so"
RUN tar -xzvf /cbs/download/component/aua-nix-obm.tar.gz
RUN tar -xzvf /cbs/download/component/util-common.tar.gz
RUN tar -xzvf /cbs/download/component/app-inst-nix-obm.tar.gz \
    --anchored \
    --exclude="bin/*.png"
RUN tar -xzvf /cbs/download/component/aua-inst-nix-obm.tar.gz \
    "aua/lib/AuaRes_en.properties" \
    --anchored \
    --exclude="aua/lib"
RUN cp /cbs/build/engine-framework/custom-obm/app/common/bin/*_en.properties \
    /tmp/obm/bin
RUN find ./bin -type f -iname "*.sh" -exec chmod +x {} \;
RUN cd jvm/bin; ln -s java bJW; ln -s java bschJW; ln -s java javau

# Add optional hotfix
ARG HOTFIX
RUN if [[ -n $HOTFIX ]]; then \
  echo "Downloading $HOTFIX"; \
  curl -sSL -o hotfix.zip "$HOTFIX"; \
  unzip -o hotfix.zip; \
  rm hotfix.zip; \
fi

RUN sed -i /tmp/obm/bin/Scheduler.sh \
    -re 's|\Wsu root .*|exec $JAVA_EXE $JAVA_OPTS $JNI_PATH -cp $CLASSPATH $MAIN_CLASS $APP_HOME|g'

RUN sed -i /tmp/obm/bin/RunBackupSet.sh \
    -re 's|CLEANUP_MODE="DISABLE-CLEANUP"|CLEANUP_MODE="ENABLE-CLEANUP"|g'

RUN echo "/root/.obm" > /tmp/obm/home.txt


# CREATE FINAL IMAGE
FROM centos:latest
LABEL com.ahsay.product=obm \
      com.ahsay.product.version=8.3.6.30
ARG APP_HOME="/obm"
ENV PATH="${APP_HOME}/bin:${PATH}"
WORKDIR "${APP_HOME}"
COPY --from=builder "/tmp/obm" "${APP_HOME}"
ADD docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["Scheduler.sh"]

#HEALTHCHECK --interval=1m --timeout=1m --start-period=2m \
#  CMD healthcheck.sh
