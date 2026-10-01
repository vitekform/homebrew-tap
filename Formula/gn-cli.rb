# Template for the Homebrew formula in the tap (github.com/vitekform/homebrew-tap,
# Formula/gn-cli.rb). The homebrew job in .github/workflows/gn-cli.yml fills in
# 1.2.1 and the @SHA256_*@ placeholders from the published rsys release and
# pushes the result to the tap on every gn-cli-v* tag; don't edit the tap's copy.
#
# It installs the prebuilt binaries from rsys.ganamaga.me rather than building
# from source: the source lives inside the whole nextgen monorepo.
class GnCli < Formula
  desc "Command-line client for the nextgen API"
  homepage "https://github.com/vitekform/nextgen/tree/master/gn_cli"
  version "1.2.1"

  on_macos do
    # CI only builds an Apple Silicon binary.
    depends_on arch: :arm64

    url "https://rsys.ganamaga.me/gn-cli/public/v/1.2.1/gn-cli-macos-arm64"
    sha256 "9285a41e6bc540b9e96320dadcbbf955ba98afdd6076e001e3f61c6698fa1da2"
  end

  on_linux do
    # The Linux binary links the system libcurl (libcurl4) dynamically.
    depends_on arch: :x86_64

    url "https://rsys.ganamaga.me/gn-cli/public/v/1.2.1/gn-cli-linux-x64"
    sha256 "017bc9181335637a1b34390070b15bddfab9e4df7a0ac2afa9e6adb099e909e4"
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
