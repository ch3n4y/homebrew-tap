cask "easytier-gui" do
  version "2.5.0"

  on_arm do
    url "https://github.com/EasyTier/EasyTier/releases/download/v#{version}/easytier-gui_#{version}_aarch64.dmg"
    sha256 "040c6741af07ebb469048b0cfa3fdd4215b00d31cc5539a9b46acfbce0737d4a"
  end
  on_intel do
    url "https://github.com/EasyTier/EasyTier/releases/download/v#{version}/easytier-gui_#{version}_x64.dmg"
    sha256 "b741fbd8b48985528a695bee1880c8029fbe41d61acf44138d3d86706b04a8d7"
  end

  name "EasyTier GUI"
  desc "GUI client for EasyTier - a decentralized mesh VPN solution"
  homepage "https://github.com/EasyTier/EasyTier"

  livecheck do
    url :url
    strategy :github_latest
  end

  app "EasyTier.app"

  zap trash: [
    "~/Library/Application Support/EasyTier",
    "~/Library/Preferences/com.easytier.gui.plist",
    "~/Library/Saved Application State/com.easytier.gui.savedState",
  ]
end
