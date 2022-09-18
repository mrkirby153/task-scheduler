{ lib, beamPackages, overrides ? (x: y: {}) }:

let
  buildRebar3 = lib.makeOverridable beamPackages.buildRebar3;
  buildMix = lib.makeOverridable beamPackages.buildMix;
  buildErlangMk = lib.makeOverridable beamPackages.buildErlangMk;

  self = packages // (overrides self packages);

  packages = with beamPackages; with self; {
    bunt = buildMix rec {
      name = "bunt";
      version = "0.2.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0lw3v9kwbbcy1v6ygziiky887gffwwmxvyg4r1v0zm71kzhcgxbs";
      };

      beamDeps = [];
    };

    certifi = buildRebar3 rec {
      name = "certifi";
      version = "2.8.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1slp20z2fgcq9p2bbdp1gj218kjqpx5jsa95sq40nq7qqv0yziva";
      };

      beamDeps = [];
    };

    credo = buildMix rec {
      name = "credo";
      version = "1.5.6";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "05zbqwzpai3257slw5ibblz6wazallc8ar1awq6y6r5xb3js6ljb";
      };

      beamDeps = [ bunt file_system jason ];
    };

    dialyxir = buildMix rec {
      name = "dialyxir";
      version = "1.1.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "16hbdhkbqq69v452vx3c0d26mmadkmwr6nvdpr72c5azqi4qxsh7";
      };

      beamDeps = [ erlex ];
    };

    earmark_parser = buildMix rec {
      name = "earmark_parser";
      version = "1.4.16";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1bffmjpbmmi1hkvcwc0n5n5na43h082y7qqjs16jfnlg2sbgdz39";
      };

      beamDeps = [];
    };

    erlex = buildMix rec {
      name = "erlex";
      version = "0.2.6";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0x8c1j62y748ldvlh46sxzv5514rpzm809vxn594vd7y25by5lif";
      };

      beamDeps = [];
    };

    ex_doc = buildMix rec {
      name = "ex_doc";
      version = "0.25.5";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0l43aabp3ch3vricv7h0x36a9kqzgx57c1qn5726n56wii9zm338";
      };

      beamDeps = [ earmark_parser makeup_elixir makeup_erlang ];
    };

    excoveralls = buildMix rec {
      name = "excoveralls";
      version = "0.14.4";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1h9ig4hijdhp73isl830hip7s7g78ykz19i8jx8pl72cvzr05az3";
      };

      beamDeps = [ hackney jason ];
    };

    file_system = buildMix rec {
      name = "file_system";
      version = "0.2.10";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1p0myxmnjjds8bbg69dd6fvhk8q3n7lb78zd4qvmjajnzgdmw6a1";
      };

      beamDeps = [];
    };

    hackney = buildRebar3 rec {
      name = "hackney";
      version = "1.18.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0pjwbf87nqj2ki3i076whrswh2cdhklj6cbaikdj1mq40xidmz4s";
      };

      beamDeps = [ certifi idna metrics mimerl parse_trans ssl_verify_fun unicode_util_compat ];
    };

    idna = buildRebar3 rec {
      name = "idna";
      version = "6.1.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1sjcjibl34sprpf1dgdmzfww24xlyy34lpj7mhcys4j4i6vnwdwj";
      };

      beamDeps = [ unicode_util_compat ];
    };

    jason = buildMix rec {
      name = "jason";
      version = "1.2.2";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0y91s7q8zlfqd037c1mhqdhrvrf60l4ax7lzya1y33h5y3sji8hq";
      };

      beamDeps = [];
    };

    makeup = buildMix rec {
      name = "makeup";
      version = "1.0.5";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1a9cp9zp85yfybhdxapi9haa1yykzq91bw8abmk0qp1z5p05i8fg";
      };

      beamDeps = [ nimble_parsec ];
    };

    makeup_elixir = buildMix rec {
      name = "makeup_elixir";
      version = "0.15.2";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0x9yhal7zngssyrgrm2gxq1d91phr51jpvackpsfyclvs14aw8zx";
      };

      beamDeps = [ makeup nimble_parsec ];
    };

    makeup_erlang = buildMix rec {
      name = "makeup_erlang";
      version = "0.1.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1fvw0zr7vqd94vlj62xbqh0yrih1f7wwnmlj62rz0klax44hhk8p";
      };

      beamDeps = [ makeup ];
    };

    metrics = buildRebar3 rec {
      name = "metrics";
      version = "1.0.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "05lz15piphyhvvm3d1ldjyw0zsrvz50d2m5f2q3s8x2gvkfrmc39";
      };

      beamDeps = [];
    };

    mimerl = buildRebar3 rec {
      name = "mimerl";
      version = "1.2.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "08wkw73dy449n68ssrkz57gikfzqk3vfnf264s31jn5aa1b5hy7j";
      };

      beamDeps = [];
    };

    nimble_parsec = buildMix rec {
      name = "nimble_parsec";
      version = "1.1.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0jzmr0x3s6z16c74gvrk9aqc10brn6a1dwa8ywzr2vkhdgb35sq8";
      };

      beamDeps = [];
    };

    parse_trans = buildRebar3 rec {
      name = "parse_trans";
      version = "3.3.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "12w8ai6b5s6b4hnvkav7hwxd846zdd74r32f84nkcmjzi1vrbk87";
      };

      beamDeps = [];
    };

    ssl_verify_fun = buildRebar3 rec {
      name = "ssl_verify_fun";
      version = "1.1.6";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1026l1z1jh25z8bfrhaw0ryk5gprhrpnirq877zqhg253x3x5c5x";
      };

      beamDeps = [];
    };

    stream_data = buildMix rec {
      name = "stream_data";
      version = "0.5.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0wg2p5hwf7qmkwsc1i3q7h558f7sr9f13y8i6kds9bb9q3pd4aq1";
      };

      beamDeps = [];
    };

    unicode_util_compat = buildRebar3 rec {
      name = "unicode_util_compat";
      version = "0.7.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "08952lw8cjdw8w171lv8wqbrxc4rcmb3jhkrdb7n06gngpbfdvi5";
      };

      beamDeps = [];
    };
  };
in self

