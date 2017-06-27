FROM centos:latest
WORKDIR /obm


# 'ifconfig' is a fake tool that simply echos the machines MAC address.
#     This is necessary for the OBM to report local ip.
COPY ifconfig /usr/bin/


# Bootstrap OBM
COPY docker-entrypoint.sh /


# Download the *nix installer directly from ahsay.com (92 MB).
#ADD http://ahsay-dn.ahsay.com/v6/obsr/62900/obm-nix.tar.gz ./
#RUN tar xzf obsr-nix.tar.gz \
#    && rm -f obsr-nix.tar.gz


# Alternative to the above, this copies a nearly-the-same obsr with **only** the
#  following, space-saving (image reduced by 621 MB), exclusions:
#  *  jre32/*
#  *  obm/bin/*.pdf
COPY obm/ ./


ENTRYPOINT ["/docker-entrypoint.sh"]
