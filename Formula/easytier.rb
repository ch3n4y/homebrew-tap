class Easytier < Formula
  desc "Simple, secure, decentralized mesh VPN solution with WireGuard support"
  homepage "https://github.com/EasyTier/EasyTier"
  license "LGPL-3.0"

  if Hardware::CPU.arm?
    url "https://github.com/EasyTier/EasyTier/releases/download/v2.5.0/easytier-macos-aarch64-v2.5.0.zip"
    sha256 "ce3744470e41675358728ab0a8da798436ec763f561d8b698d8d06a7ffa21895"
  else
    url "https://github.com/EasyTier/EasyTier/releases/download/v2.5.0/easytier-macos-x86_64-v2.5.0.zip"
    sha256 "9bc12142f8808f0de02575064e39901ac6804d82ef27c1d08ecf0bced3e79c47"
  end

  livecheck do
    url "https://github.com/EasyTier/EasyTier/releases"
    regex(/v?(\d+(?:\.\d+)+)/i)
    strategy :github_releases
  end

  def install
    bin.install "easytier-core", "easytier-cli", "easytier-web", "easytier-web-embed"

    (libexec/"easytier-service").write service_wrapper
    chmod 0755, libexec/"easytier-service"

    # Generate default service and network configuration.
    (etc/"easytier").mkpath
    (etc/"easytier/default.conf").write default_config unless (etc/"easytier/default.conf").exist?
    (etc/"easytier/service.env").write default_service_env unless (etc/"easytier/service.env").exist?
  end

  def service_wrapper
    <<~SH
      #!/bin/sh
      set -eu

      service_env="#{etc}/easytier/service.env"
      config_file="#{etc}/easytier/default.conf"

      if [ -r "$service_env" ]; then
        . "$service_env"
      fi

      if [ -n "${EASYTIER_CONFIG_SERVER:-}" ]; then
        exec "#{opt_bin}/easytier-core" -w "$EASYTIER_CONFIG_SERVER"
      fi

      exec "#{opt_bin}/easytier-core" -c "$config_file"
    SH
  end

  def default_service_env
    <<~SH
      # Leave EASYTIER_CONFIG_SERVER empty to run with default.conf.
      # Set it to use the web console config server, for example:
      # EASYTIER_CONFIG_SERVER="tcp://127.0.0.1:22020/admin"
      EASYTIER_CONFIG_SERVER=""
    SH
  end

  def default_config
    <<~TOML
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

  def caveats
    <<~EOS
      EasyTier has been installed with the following binaries:
        • easytier-core       - Core VPN service
        • easytier-cli        - Command-line interface
        • easytier-web        - Web console server
        • easytier-web-embed  - Embedded web server

      Configuration:
        Default config: #{etc}/easytier/default.conf
        Service mode:   #{etc}/easytier/service.env
        Edit the config file to customize your network settings.

      Service Startup Modes:
        1. Default config file:
           Leave EASYTIER_CONFIG_SERVER empty in #{etc}/easytier/service.env
           The service runs: easytier-core -c #{etc}/easytier/default.conf

        2. Web console config server:
           Set EASYTIER_CONFIG_SERVER in #{etc}/easytier/service.env
           The service runs: easytier-core -w "$EASYTIER_CONFIG_SERVER"

      Service Management:
        Start service:  sudo brew services start easytier
        Stop service:   sudo brew services stop easytier
        Restart:        sudo brew services restart easytier
        Status:         brew services info easytier

      Manual Usage:
        sudo easytier-core -c #{etc}/easytier/default.conf
        sudo easytier-core -w tcp://127.0.0.1:22020/admin

      Documentation:
        https://github.com/EasyTier/EasyTier
    EOS
  end

  service do
    run [opt_libexec/"easytier-service"]
    keep_alive true
    require_root true
    working_dir HOMEBREW_PREFIX
    log_path var/"log/easytier.log"
    error_log_path var/"log/easytier.log"
  end

  test do
    # Test version output
    assert_match version.to_s, shell_output("#{bin}/easytier-core --version 2>&1")

    # Test that all binaries exist and are executable
    %w[easytier-core easytier-cli easytier-web easytier-web-embed].each do |binary|
      assert_path_exists bin/binary
      assert_predicate bin/binary, :executable?
    end

    # Test config file was created
    assert_path_exists etc/"easytier/default.conf"
    assert_path_exists etc/"easytier/service.env"
    assert_predicate libexec/"easytier-service", :executable?
  end
end
