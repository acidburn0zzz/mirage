FROM ocaml/opam
RUN sudo -u opam sh -c "opam depext -u mirage mirage-xen mirage-unix" && \
  sudo -u opam sh -c "opam install -y -j 2 -v mirage mirage-xen mirage-unix"
