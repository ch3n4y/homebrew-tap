cask "easytier-gui" do
  version "2.5.0"

  sha256 arm:   "040c6741af07ebb469048b0cfa3fdd4215b00d31cc5539a9b46acfbce0737d4a",
         intel: "b741fbd8b48985528a695bee1880c8029fbe41d61acf44138d3d86706b04a8d7"

  url "https://github.com/EasyTier/EasyTier/releases/download/v#{version}/easytier-gui_#{version}_#{Hardware::CPU.intel? ? "x64" : "aarch64"}.dmg"
  name "EasyTier GUI"
  desc "GUI client for EasyTier - a decentralized mesh VPN solution"
  homepage "https://github.com/EasyTier/EasyTier"

  livecheck do
    url "https://github.com/EasyTier/EasyTier/releases"
    regex(/v?(\d+(?:\.\d+)+)/i)
    strategy :github_releases
  end

  app "easytier-gui.app"

  zap trash: [
    "~/Library/Application Support/EasyTier",
    "~/Library/Preferences/com.easytier.gui.plist",
    "~/Library/Saved Application State/com.easytier.gui.savedState",
  ]
end
