class Easytier < Formula
  desc "Simple, secure, decentralized mesh VPN solution with WireGuard support"
  homepage "https://github.com/EasyTier/EasyTier"
  version "2.5.0"
  license "LGPL-3.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/EasyTier/EasyTier/releases/download/v2.5.0/easytier-macos-aarch64-v2.5.0.zip"
      sha256 "ce3744470e41675358728ab0a8da798436ec763f561d8b698d8d06a7ffa21895"
    else
      url "https://github.com/EasyTier/EasyTier/releases/download/v2.5.0/easytier-macos-x86_64-v2.5.0.zip"
      sha256 "9bc12142f8808f0de02575064e39901ac6804d82ef27c1d08ecf0bced3e79c47"
    end
  end

  livecheck do
    url :stable
    strategy :github_latest
  end

  def install
    bin.install "easytier-core", "easytier-cli", "easytier-web", "easytier-web-embed"

    # Create config directory
    (etc/"easytier").mkpath

    # Generate default config file if it doesn't exist
    default_config = etc/"easytier/default.conf"
    unless default_config.exist?
      default_config.write <<~TOML
        instance_name = "default"
        dhcp = true
        listeners = [
            "tcp://0.0.0.0:11010",
            "udp://0.0.0.0:11010",
            "wg://0.0.0.0:11011",
            "ws://0.0.0.0:11011/",
            "wss://0.0.0.0:11012/",
        ]
        exit_nodes = []
        rpc_portal = "0.0.0.0:0"

        [[peer]]
        uri = "tcp://public.easytier.top:11010"

        [network_identity]
        network_name = "default"
        network_secret = "default"

        [flags]
        default_protocol = "udp"
        dev_name = ""
        enable_encryption = true
        enable_ipv6 = true
        mtu = 1380
        latency_first = false
        enable_exit_node = false
        no_tun = false
        use_smoltcp = false
        foreign_network_whitelist = "*"
        disable_p2p = false
        p2p_only = false
        relay_all_peer_rpc = false
        disable_tcp_hole_punching = false
        disable_udp_hole_punching = false
      TOML
    end
  end

  def caveats
    <<~EOS
      EasyTier has been installed with the following commands:
        - easytier-core: Core VPN service
        - easytier-cli: Command-line interface
        - easytier-web: Web console server
        - easytier-web-embed: Embedded web server

      Configuration file location:
        #{etc}/easytier/default.conf

      To start easytier-core as a background service:
        sudo brew services start easytier

      To stop the service:
        sudo brew services stop easytier

      To run manually:
        sudo easytier-core -c #{etc}/easytier/default.conf
    EOS
  end

  service do
    run [opt_bin/"easytier-core", "-c", etc/"easytier/default.conf"]
    keep_alive true
    require_root true
    working_dir HOMEBREW_PREFIX
    log_path var/"log/easytier.log"
    error_log_path var/"log/easytier.log"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/easytier-core --version 2>&1")
  end
end
