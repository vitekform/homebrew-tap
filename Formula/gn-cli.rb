# Template for the Homebrew formula in the tap (github.com/vitekform/homebrew-tap,
# Formula/gn-cli.rb). The homebrew job in .github/workflows/gn-cli.yml fills in
# 1.15.0 and the @SHA256_*@ placeholders from the published rsys release and
# pushes the result, with LICENSE from this folder, to the tap on every
# gn-cli-v* tag; don't edit the tap's copies.
#
# It installs the prebuilt binaries from rsys.ganamaga.me rather than building
# from source. Source code: https://github.com/vitekform/gn-cli.
class GnCli < Formula
  desc "Command-line client for the nextgen API"
  # Source, issues and build instructions live in the standalone repository.
  homepage "https://github.com/vitekform/gn-cli"
  version "1.15.0"
  # MIT with an additional User-Agent condition; not the unmodified SPDX MIT licence.
  license :cannot_represent

  on_macos do
    # One universal binary (Apple Silicon and Intel), also published as gn-cli-macos-x64.
    url "https://rsys.ganamaga.me/gn-cli/public/v/1.15.0/gn-cli-macos-arm64"
    sha256 "2f9f906e39f397e286004b1336f6b2c3775b12d11dd54f86467fe2b177a526c1"
  end

  on_linux do
    # The Linux binaries link the system libcurl (libcurl4) dynamically.
    on_intel do
      url "https://rsys.ganamaga.me/gn-cli/public/v/1.15.0/gn-cli-linux-x64"
      sha256 "1e5ad94570644b7bb3d087def323604cd2fc5fbfeb1066981b3df1c5badf88d7"
    end
    on_arm do
      url "https://rsys.ganamaga.me/gn-cli/public/v/1.15.0/gn-cli-linux-arm64"
      sha256 "a4e06e2097612fbab94212fe5df90c8d61486973b4be11d7f44f8fafef41061b"
    end
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
    assert_match "Additional User-Agent condition", shell_output("#{bin}/gn-cli license")
    assert_match "nlohmann/json", shell_output("#{bin}/gn-cli license third-party")
    assert_match "share", shell_output("#{bin}/gn-cli __complete s3 -- sh")
    (testpath/"abc.txt").write "abc"
    assert_match "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad",
                 shell_output("#{bin}/gn-cli --no-unicode rsys hash #{testpath}/abc.txt")
  end
end
