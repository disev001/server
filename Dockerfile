FROM quay.io/coreos/ignition-validate:release as validate
FROM quay.io/coreos/butane:release as butane
FROM quay.io/coreos/coreos-installer 
#input in new image
ENV INPUT=input/core-os.yaml
COPY ${INPUT} /shared/core-os.yaml
#validator aus ignition-validate und base von butane
COPY --from=validate /usr/local/bin/ignition-validate /usr/local/bin/ignition-validate
COPY --from=butane /usr/local/bin/butane /usr/local/bin/butane

RUN ["/usr/local/bin/butane","--pretty","--strict","-o","/shared/core-os.ign","/shared/core-os.yaml"]
RUN ["/usr/local/bin/ignition-validate","/shared/core-os.ign"]

ENTRYPOINT ["/usr/sbin/coreos-installer","iso","customize", \
 "--dest-device","/dev/sda", \
    "--dest-ignition" ,"/shared/core-os.ign", \
     "--dest-console", "ttyS0,115200n8", \
     "--dest-console", "tty0" , \
      "-o" ,"/tmp/iso/custom.iso","/tmp/iso/coreos.iso" ]

VOLUME [ "/tmp" ]
# ENTRYPOINT ["/usr/sbin/coreos-installer","iso","customize",\
#     "--dest-device", "/dev/sda",\
#     "--dest-ignition", "/shared/core-os.ign" ,\
#     "--dest-console","ttyS0,115200n8" ,\
#     "--dest-console", "tty0", \
#     "--network-keyfile", "static-ip.nmconnection",\
#     "-o" "custom.iso" "fedora-coreos-37.20230205.3.0-live.x86_64.iso"]

# coreos-installer iso customize \
#     --dest-device /dev/sda \
#     --dest-ignition config.ign \
#     --dest-console ttyS0,115200n8 \
#     --dest-console tty0 \
#     --network-keyfile static-ip.nmconnection \
#     --ignition-ca ca.pem \
#     --post-install post.sh \
#     -o /shared/custom.iso /tmp/iso/co.iso