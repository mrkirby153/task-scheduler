{ lib, beamPackages, overrides ? (x: y: {}) }:

let
  buildRebar3 = lib.makeOverridable beamPackages.buildRebar3;
  buildMix = lib.makeOverridable beamPackages.buildMix;
  buildErlangMk = lib.makeOverridable beamPackages.buildErlangMk;

  self = packages // (overrides self packages);

  packages = with beamPackages; with self; {
    amqp = buildMix rec {
      name = "amqp";
      version = "3.2.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0550112l0x8kmz0dxd38lz4lv550anq8z4rr0807jvnz6q1mff8l";
      };

      beamDeps = [ amqp_client ];
    };

    amqp_client = buildRebar3 rec {
      name = "amqp_client";
      version = "3.9.29";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "19kpzsbr71vcwafgyq7slnimiafwnd2y5fffhbyclkvrdp1g7d3m";
      };

      beamDeps = [ rabbit_common ];
    };

    credentials_obfuscation = buildRebar3 rec {
      name = "credentials_obfuscation";
      version = "3.1.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0y5pnypmawkn05fbq5wm8dg9v9f0kglv7mnlk6lzpkf6n5i4x204";
      };

      beamDeps = [];
    };

    db_connection = buildMix rec {
      name = "db_connection";
      version = "2.5.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "18jsnmabdjwj3i7ml43ljzrzzvfy1a3bnbaqywgsv7nndji5nbf9";
      };

      beamDeps = [ telemetry ];
    };

    decimal = buildMix rec {
      name = "decimal";
      version = "2.1.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1k7z418b6cj977wswpxsk5844xrxc1smaiqsmrqpf3pdjzsfbksk";
      };

      beamDeps = [];
    };

    json = buildMix rec {
      name = "json";
      version = "1.4.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "05ix0lzsdg4xdva23vg55q0ks9pg0kwxb1z0fnwgr92fps6j3gws";
      };

      beamDeps = [];
    };

    jsx = buildRebar3 rec {
      name = "jsx";
      version = "3.1.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1wr7jkxm6nlgvd52xhniav64xr9rml2ngb35rwjwqlqvq7ywhp0c";
      };

      beamDeps = [];
    };

    myxql = buildMix rec {
      name = "myxql";
      version = "0.6.3";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0lczbm06silw8kmcrkzj2d2gsmrp94ar0x7851f5rvdcvlbvb7mg";
      };

      beamDeps = [ db_connection decimal ];
    };

    rabbit_common = buildRebar3 rec {
      name = "rabbit_common";
      version = "3.9.29";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1q93x8j4rk14c7mxi4wc550cdaz745h099klb715h5zjby7dhq9c";
      };

      beamDeps = [ credentials_obfuscation jsx recon ];
    };

    recon = buildMix rec {
      name = "recon";
      version = "2.5.3";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1mwr6267lwl4p7f8jfk14s4cszxwra6zgf84hkcxz8fldzs86rkc";
      };

      beamDeps = [];
    };

    telemetry = buildRebar3 rec {
      name = "telemetry";
      version = "1.2.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1mgyx9zw92g6w8fp9pblm3b0bghwxwwcbslrixq23ipzisfwxnfs";
      };

      beamDeps = [];
    };
  };
in self

