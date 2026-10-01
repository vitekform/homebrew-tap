# Template for the Homebrew formula in the tap (github.com/vitekform/homebrew-tap,
# Formula/gn-cli.rb). The homebrew job in .github/workflows/gn-cli.yml fills in
# 1.3.0 and the @SHA256_*@ placeholders from the published rsys release and
# pushes the result to the tap on every gn-cli-v* tag; don't edit the tap's copy.
#
# It installs the prebuilt binaries from rsys.ganamaga.me rather than building
# from source: the source lives inside the whole nextgen monorepo.
class GnCli < Formula
  desc "Command-line client for the nextgen API"
  homepage "https://github.com/vitekform/nextgen/tree/master/gn_cli"
  version "1.3.0"

  on_macos do
    # CI only builds an Apple Silicon binary.
    depends_on arch: :arm64

    url "https://rsys.ganamaga.me/gn-cli/public/v/1.3.0/gn-cli-macos-arm64"
    sha256 "2641abbd77d22b49c50e4c1f52c00606ec683ae2fdc96af389a4666e90e01aca"
  end

  on_linux do
    # The Linux binary links the system libcurl (libcurl4) dynamically.
    depends_on arch: :x86_64

    url "https://rsys.ganamaga.me/gn-cli/public/v/1.3.0/gn-cli-linux-x64"
    sha256 "b45e5a3b62575871531f2556d91ffcfe98e1eb7f6aaf5d67fe2e2f5a8f8a5327"
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
    assert_match version.to_s, shell_output("#{bin}/gn-cli --version")
    assert_match version.to_s, shell_output("#{bin}/gn --version")
    assert_match "share", shell_output("#{bin}/gn-cli __complete s3 -- sh")
    (testpath/"abc.txt").write "abc"
    assert_match "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad",
                 shell_output("#{bin}/gn-cli --no-unicode rsys hash #{testpath}/abc.txt")
  end
end
