FROM quay.io/coreos/ignition-validate:release as validate

FROM quay.io/coreos/butane:release
COPY --from=validate /usr/local/bin/ignition-validate /usr/local/bin/ignition-validate
ENV INPUT=input/core-os.yaml
COPY ${INPUT} /shared/core-os.yaml
RUN ["/usr/local/bin/butane","--pretty","--strict","-o","/shared/core-os.ign","/shared/core-os.yaml"]
RUN ["/usr/local/bin/ignition-validate","/shared/core-os.ign"]
VOLUME /shared/
#TODO: core-os.ign könnte sich anfangen selbst zu hosten