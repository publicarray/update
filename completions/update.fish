complete -c update -d "Update OS and packages"
complete -c update --no-files -s 'h' -l 'help' -d "Display usage information"

complete -c update --no-files -a "system" -d "Update System [apt,dnf,..]"
complete -c update --no-files -a "mas" -d "Update macOS App Store"
complete -c update --no-files -a "brew" -d "Update Homebrew Packages"
complete -c update --no-files -a "npm" -d "Update JavaScript Packages"
complete -c update --no-files -a "yarn" -d "Update JavaScript Packages"
complete -c update --no-files -a "pip" -d "Update Python Packages"
complete -c update --no-files -a "composer" -d "Update php packages"
complete -c update --no-files -a "apm" -d "Update Atom packages"
complete -c update --no-files -a "gem" -d "Update Ruby gems"
complete -c update --no-files -a "fish" -d "Update omf and fisher 🐟 "
complete -c update --no-files -a "dotfiles" -d "Up ~/.dotfiles and prezto"
complete -c update --no-files -a "packages" -d "Update all package managers"
complete -c update --no-files -a "all" -d "Update everything"

complete -c up -w update
