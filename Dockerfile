FROM centos:latest
WORKDIR /obm


# Download the *nix installer directly from ahsay.com (92 MB).
#ADD http://ahsay-dn.ahsay.com/v6/obsr/62900/obm-nix.tar.gz ./
#RUN tar xzf obsr-nix.tar.gz \
#    && rm -f obsr-nix.tar.gz


# Alternative to the above, this copies a nearly-the-same obm with **only** the
#  following, space-saving exclusions:
#  *  jre32/*
#  *  obm/bin/*.pdf
COPY obm/ ./


# bootstrap contains Entrypoint (SIGTERM receiver), Ahsay v7 license counter,
#  pseudo ifconfig, etc
COPY bootstrap/ /bootstrap


# Symlink pseudo ifconfig.
RUN ln -sf /bootstrap/ifconfig /usr/bin/ifconfig


CMD ["bash", "/bootstrap/docker-entrypoint.sh"]
