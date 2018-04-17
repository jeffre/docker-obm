FROM centos:latest
ENV PATH="${PATH}:/obm/bin:/bootstrap" \
    APP=obm \
    APP_HOME=/obm
WORKDIR ${APP_HOME}


# Download the *nix installer directly from ahsay.com (92 MB).
#ADD https://ahsay-dn.ahsay.com/v6/obsr/62900/obm-nix.tar.gz ./
#RUN tar xzf obsr-nix.tar.gz \
#    && rm -f obsr-nix.tar.gz


# Alternative to the above, this extraction is much lighter.
# See .gitignore for the full list of what is excluded.
COPY ${APP}/ ./


# bootstrap contains Entrypoint (SIGTERM receiver), Ahsay v7 license counter,
#  pseudo ifconfig, etc
COPY bootstrap/ /bootstrap



RUN \
#
#
# Symlink pseudo ifconfig.
  ln -sf "/bootstrap/ifconfig" "/usr/bin/ifconfig" && \
#
#
# Prevent Scheduler from daemonizing
  sed -i "bin/Scheduler.sh" \
      -e 's|> "\${APP_HOME}/log/Scheduler/console.log" 2>&1 &||g' && \
#
#
# Remove actions involving jre32
# Remove unneeded and error causing chmod Lotus
  sed -i "bin/config.sh" \
      -e "s@\(echo\|ln\|chmod\) .*jre32.*@:@g" \
      -e "/LotusBM/d"


ENTRYPOINT ["/bootstrap/docker-entrypoint.sh"]
