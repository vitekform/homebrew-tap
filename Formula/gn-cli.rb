# Template for the Homebrew formula in the tap (github.com/vitekform/homebrew-tap,
# Formula/gn-cli.rb). The homebrew job in .github/workflows/gn-cli.yml fills in
# 1.1.0 and the @SHA256_*@ placeholders from the published rsys release and
# pushes the result to the tap on every gn-cli-v* tag; don't edit the tap's copy.
#
# It installs the prebuilt binaries from rsys.ganamaga.me rather than building
# from source: the source lives inside the whole nextgen monorepo.
class GnCli < Formula
  desc "Command-line client for the nextgen API"
  homepage "https://github.com/vitekform/nextgen/tree/master/gn_cli"
  version "1.1.0"

  on_macos do
    # CI only builds an Apple Silicon binary.
    depends_on arch: :arm64

    url "https://rsys.ganamaga.me/gn-cli/public/v/1.1.0/gn-cli-macos-arm64"
    sha256 "7b97555c7b6182f740aed635b8d88bf9346e6357019f90864b5659fcfe3da3cc"
  end

  on_linux do
    # The Linux binary links the system libcurl (libcurl4) dynamically.
    depends_on arch: :x86_64

    url "https://rsys.ganamaga.me/gn-cli/public/v/1.1.0/gn-cli-linux-x64"
    sha256 "23b16113046b6d9ee5e77243939b44abd381eeaa5fe9fffa05c502821f9584c9"
  end

  def install
    bin.install Dir["gn-cli-*"].first => "gn-cli"
    bin.install_symlink "gn-cli" => "gn"
    bin.install_symlink "gn-cli" => "gncli"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/gn-cli --version")
    assert_match version.to_s, shell_output("#{bin}/gn --version")
    (testpath/"abc.txt").write "abc"
    assert_match "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad",
                 shell_output("#{bin}/gn-cli --no-unicode rsys hash #{testpath}/abc.txt")
  end
end
