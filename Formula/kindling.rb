class Kindling < Formula
  desc "Zsh framework with an async prompt and single-pass line editing"
  homepage "https://github.com/samuelbanapour/kindling"
  url "https://github.com/samuelbanapour/kindling/archive/refs/tags/v1.0.1.tar.gz"
  sha256 "6d2fafb914a0baaa9f8e89a01ae173a641e874eadaf1eaf7d77f7edf971d7ab8"
  license "MIT"
  head "https://github.com/samuelbanapour/kindling.git", branch: "main"

  def install
    # Everything ships as data, not executables: kindling.zsh is sourced from
    # the user's .zshrc, and the `kindling` command is a shell function it
    # defines.
    pkgshare.install "kindling.zsh", "lib", "plugins", "themes", "tools", "templates"

    # Tell the framework it is package-managed. Without this it would default
    # $KINDLING_CUSTOM to $KINDLING/custom — inside the Cellar, which
    # `brew upgrade` replaces wholesale, silently deleting any plugin the
    # user had written.
    (pkgshare/".kindling-managed").write "homebrew\n"

    doc.install "README.md"
    # install.sh is for people who don't use Homebrew; shipping it would invite
    # someone to run it and end up with a second, unmanaged copy.
  end

  def caveats
    <<~EOS
      Add to your ~/.zshrc:

        export KINDLING="#{opt_pkgshare}"
        kindling_plugins=(git jump zline extract)
        KINDLING_THEME=spark
        [ -r "$KINDLING/kindling.zsh" ] && source "$KINDLING/kindling.zsh"

      Then start a new shell and run: kindling doctor

      Your own plugins and themes live outside the Cellar, so they survive
      upgrades:

        ${XDG_DATA_HOME:-~/.local/share}/kindling/custom
    EOS
  end

  test do
    (testpath/"t.zsh").write <<~EOS
      export KINDLING="#{pkgshare}"
      kindling_plugins=(git extract jump zline)
      KINDLING_THEME=spark
      source "$KINDLING/kindling.zsh"
      # The prompt is set from a precmd hook, which does not fire under -c.
      for f in $precmd_functions; do $f; done
      print -r -- "version=$KINDLING_VERSION"
      print -r -- "install=$KINDLING_INSTALL"
      print -r -- "plugins=${kindling_loaded_plugins[*]}"
      print -r -- "prompt=$(( ${#PROMPT} > 0 ))"
      print -r -- "custom_outside=$([[ $KINDLING_CUSTOM == $KINDLING/* ]] && print no || print yes)"
    EOS
    output = shell_output("HOME=#{testpath} XDG_DATA_HOME=#{testpath}/data " \
                          "XDG_CACHE_HOME=#{testpath}/cache zsh -f #{testpath}/t.zsh")
    assert_match "version=1.0.1", output
    assert_match "install=homebrew", output
    assert_match "plugins=git extract jump zline", output
    assert_match "prompt=1", output
    assert_match "custom_outside=yes", output
  end
end
