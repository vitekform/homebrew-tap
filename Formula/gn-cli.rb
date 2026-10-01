# Template for the Homebrew formula in the tap (github.com/vitekform/homebrew-tap,
# Formula/gn-cli.rb). The homebrew job in .github/workflows/gn-cli.yml fills in
# 1.0.4 and the @SHA256_*@ placeholders from the published rsys release and
# pushes the result to the tap on every gn-cli-v* tag; don't edit the tap's copy.
#
# It installs the prebuilt binaries from rsys.ganamaga.me rather than building
# from source: the source lives inside the whole nextgen monorepo.
class GnCli < Formula
  desc "Command-line client for the nextgen API"
  homepage "https://github.com/vitekform/nextgen/tree/master/gn_cli"
  version "1.0.4"

  on_macos do
    # CI only builds an Apple Silicon binary.
    depends_on arch: :arm64

    url "https://rsys.ganamaga.me/gn-cli/public/v/1.0.4/gn-cli-macos-arm64"
    sha256 "54093cb0d6f05582f5ef1230bce86f03cdddec2d6734451d78adf9549e3fdf74"
  end

  on_linux do
    # The Linux binary links the system libcurl (libcurl4) dynamically.
    depends_on arch: :x86_64

    url "https://rsys.ganamaga.me/gn-cli/public/v/1.0.4/gn-cli-linux-x64"
    sha256 "3ecebb1842956e3b028d835525c04d6767481b7ece92a11749b92cce83c64644"
  end

  def install
    bin.install Dir["gn-cli-*"].first => "gn-cli"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/gn-cli --version")
    (testpath/"abc.txt").write "abc"
    assert_match "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad",
                 shell_output("#{bin}/gn-cli --no-unicode rsys hash #{testpath}/abc.txt")
  end
end
