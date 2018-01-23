FROM xrally/xrally-openstack:0.10.1

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

COPY mcp_skip.list /var/lib/mcp_skip.list
COPY lvm_mcp.conf /var/lib/lvm_mcp.conf
COPY run_tempest.sh /usr/bin/run-tempest

WORKDIR /var/lib/heat-tempest-plugin

RUN git checkout $HEAT_TAG && \
    pip install -r requirements.txt && \
    pip install -r test-requirements.txt

ENV SOURCE_FILE keystonercv3

ENTRYPOINT ["run-tempest"]
