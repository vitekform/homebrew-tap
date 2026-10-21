# Template for the Homebrew formula in the tap (github.com/vitekform/homebrew-tap,
# Formula/gn-cli.rb). The homebrew job in .github/workflows/gn-cli.yml fills in
# 1.11.0 and the @SHA256_*@ placeholders from the published rsys release and
# pushes the result, with LICENSE from this folder, to the tap on every
# gn-cli-v* tag; don't edit the tap's copies.
#
# It installs the prebuilt binaries from rsys.ganamaga.me rather than building
# from source: the source lives inside the private nextgen monorepo.
class GnCli < Formula
  desc "Command-line client for the nextgen API"
  # The nextgen repository is private; this is gn-cli's public releases page.
  homepage "https://ganamaga.me/releases/gn-cli"
  version "1.11.0"
  # Proprietary: the gn-cli Limited Public License, which `gn-cli license` prints.
  license :cannot_represent

  on_macos do
    # CI only builds an Apple Silicon binary.
    depends_on arch: :arm64

    url "https://rsys.ganamaga.me/gn-cli/public/v/1.11.0/gn-cli-macos-arm64"
    sha256 "6780816f54c6e18e70ef4e097c9b98a8eee08f57a00cfc4c8197398ed9ff32bf"
  end

  on_linux do
    # The Linux binary links the system libcurl (libcurl4) dynamically.
    depends_on arch: :x86_64

    url "https://rsys.ganamaga.me/gn-cli/public/v/1.11.0/gn-cli-linux-x64"
    sha256 "1b0cc9580ce41ee0f258cdf491a43c3c7ad6fd67e1d771370e2f176a33c75c70"
  end

  def install
    bin.install Dir["gn-cli-*"].first => "gn-cli"
    # The download has no executable bit, and the completions below run the binary.
    chmod 0755, bin/"gn-cli"
    bin.install_symlink "gn-cli" => "gn"
    bin.install_symlink "gn-cli" => "gncli"
    generate_completions_from_executable(bin/"gn-cli", "completion", shells: [:bash, :zsh, :fish])
  end

  test do
    # brew test runs in a clean environment; without this every command that isn't
    # --version/license/completion stops at the Terms of Service gate.
    ENV["GN_ACCEPT_TERMS"] = "1"
    assert_match version.to_s, shell_output("#{bin}/gn-cli --version")
    assert_match version.to_s, shell_output("#{bin}/gn --version")
    assert_match "Limited Public License", shell_output("#{bin}/gn-cli license")
    assert_match "nlohmann/json", shell_output("#{bin}/gn-cli license third-party")
    assert_match "share", shell_output("#{bin}/gn-cli __complete s3 -- sh")
    (testpath/"abc.txt").write "abc"
    assert_match "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad",
                 shell_output("#{bin}/gn-cli --no-unicode rsys hash #{testpath}/abc.txt")
  end
end
