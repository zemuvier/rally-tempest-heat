FROM xrally/xrally-openstack:0.10.0

ENV TEMPEST_TAG="17.2.0"
ENV HEAT_TAG="b4acd96ee35e8839c22ca6dc08034fca684a2a22"

WORKDIR /var/lib
USER root

    # TBD define plugins tag/branch 

RUN git clone https://github.com/openstack/tempest.git -b $TEMPEST_TAG && \
    pip install tempest==$TEMPEST_TAG && \
    git clone https://github.com/openstack/heat-tempest-plugin.git && \
    pip install ansible==2.3

WORKDIR /home/rally

COPY *.list /var/lib/
COPY *.conf /var/lib/
COPY run_tempest.sh /usr/bin/run-tempest
COPY prepare_env.sh /var/lib/prepare_env.sh
COPY generate_resources.sh /var/lib/generate_resources.sh

ENV LOG_DIR /home/rally/rally_reports/
ENV SET smoke
ENV CONCURRENCY 0
ENV TEMPEST_CONF lvm_mcp.conf
ENV SKIP_LIST mcp_skip.list

WORKDIR /var/lib/heat-tempest-plugin

RUN git checkout $HEAT_TAG && \
    pip install -r requirements.txt && \
    pip install -r test-requirements.txt

ENV SOURCE_FILE /home/rally/keystonercv3

ENTRYPOINT ["run-tempest"]
