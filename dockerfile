FROM alpine
COPY run.sh start.sh /srv/
RUN chmod +x /srv/*.sh && \
    /bin/sh /srv/run.sh
CMD ["/srv/start.sh"]