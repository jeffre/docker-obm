FROM centos:latest
EXPOSE 8080 8443 9444-9464
WORKDIR /obm


# Bootstrap OBM and SIGTERM receiver
COPY docker-entrypoint.sh /


# Download the *nix installer directly from ahsay.com (92 MB).
#ADD http://ahsay-dn.ahsay.com/v6/obsr/62900/obm-nix.tar.gz ./
#RUN tar xzf obsr-nix.tar.gz \
#    && rm -f obsr-nix.tar.gz


# Alternative to the above, this copies a nearly-the-same obsr with **only** the
#  following, space-saving (image reduced by 621 MB), exclusions:
#  *  java-linux-x86
#  *  webapps/obs/liveUpdate
#  *  webapps/obs/doc
#  *  webapps/obs/download
#  *  system/ads/
ADD obm/ config.ini ./


# Create the limited user what will be used to run the OBSR application
#    Note: the userhomes folder needs to be rw for UID/GUID 400
RUN groupadd --gid 400 ahsay \
    && useradd --uid 400 --gid 400 ahsay \
    && chown -R 400:400 .


# De-escalate from root
#USER ahsay


ENTRYPOINT ["/docker-entrypoint.sh"]
