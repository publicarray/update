function update -d "Update OS and packages"
    set -l update_cmds system os mas mac-apps brew npm yarn pip python composer php apm atom gem ruby fish \
        dotfiles all packages usage help

    if test -z "$argv"
        __update_usage $update_cmds
        return 1
    end

    for arg in $argv # iterate over the arguments
        set -l match 0

        for cmd in $update_cmds # iterate over the commands
            if test $arg = $cmd # search if the argument matches a command
                eval __update_$cmd $update_cmds # run function
                set match 1
            end
        end

        if test $match = 0
            printf "'%s' is not a valid option\n" $arg > /dev/stderr
        end
    end
end

function __update_usage
    printf "Usage: update/up [commands]\n\n"
    echo "Commands:"
    for x in (seq (count $argv));
        if test $x -eq 1
            printf "   %s" $argv[1]
        else if test (math $x%9) -eq 0
            printf ",\n   "
            printf "%s" $argv[$x]
        else
            printf ", %s" $argv[$x]
        end
    end
    echo
end
alias __update_help __update_usage

function __update_needs_root
    if test (id -u) -eq 0
        eval $argv
    else if  command -sq sudo
        sudo $argv
    else
        printf "Command 'sudo' not found. Failed to execute 'sudo %s'" $argv
        return 1
    end
end

function __update_system
    if command -sq softwareupdate; and test (uname) = "Darwin";
        echo "♢ Updating macOS"
        __update_needs_root softwareupdate -ia
    end

    if command -sq dnf;
        echo "♢ Updating RedHat based system"
        __update_needs_root dnf -y upgrade
    end

    if command -sq yum; and not command -sq dnf;
        echo "♢ Updating RedHat based system"
        __update_needs_root yum -y upgrade
    end

    if command -sq apt; and test (uname) = "Linux";
        echo "♢ Updating Debian based system"
        __update_needs_root apt update
        __update_needs_root apt -y upgrade
        # __update_needs_root apt dist-upgrade
        # __update_needs_root do-release-upgrade
    end

    if command -sq apt-get; and not command -sq apt;
        echo "♢ Updating Debian based system"
        __update_needs_root apt-get update
        __update_needs_root apt-get -y upgrade
    end

    if command -sq freebsd-update;
        echo "♢ Updating freeBSD system"
        freebsd-update fetch install
        # freebsd-update -r 11.1-RELEASE upgrade
    end

    if command -sq portsnap;
        echo "♢ Updating freeBSD ports tree"
        __update_needs_root portsnap auto
    end

    if command -sq pkg;
        echo "♢ Updating freeBSD packages"
        __update_needs_root pkg -y upgrade
        __update_needs_root pkg clean
        __update_needs_root pkg audit -F
        echo "♢ These following software can be upgraded with ports:"
        pkg version -l "<"
        # portmaster -a
        # portmaster -af # rebuild all
    end

    if command -sq portmaster;
        echo "♢ Updating freeBSD portmaster"
        __update_needs_root portmaster portmaster pkg --update-if-newer
    end
end
alias __update_os __update_system

function __update_mas
    if command -sq mas;
        echo "♢ Updating Apps from App Store"
        mas upgrade
    end
end
alias __update_mac-apps __update_mas

function __update_brew
    if command -sq brew;
        echo "♢ Updating Homebrew"
        brew update
        brew upgrade
        brew cleanup
        brew prune
        brew cask cleanup
    end
end

function __update_npm
    if command -sq npm;
        echo "♢ Updating npm packages"
        npm update -g
    end
end

function __update_yarn
    if command -sq yarn;
        echo "♢ Updating yarn packages"
        yarn global upgrade-interactive --latest
        yarn global upgrade
    end
end

function __update_pip
    if command -sq pip;
        echo "♢ Updating 2.x packages"
        python -V
        pip -V
        pip freeze --local | grep -v '^\-e' | cut -d = -f 1  | xargs -n1 pip install -U
    end
    if command -sq pip3;
        echo "♢ Updating" (python3 -V) "packages"
        pip3 -V
        pip3 freeze --local | grep -v '^\-e' | cut -d = -f 1  | xargs -n1 pip3 install -U
    end
end
alias __update_python __update_pip

function __update_composer
    if command -sq composer;
        echo "♢ Updating PHP packages"
        composer global update
    end
end
alias __update_php __update_composer

function __update_apm
    if command -sq apm;
        echo "♢ Updating Atom packages"
        apm upgrade --no-confirm
    end
end
alias __update_atom __update_apm

function __update_gem
    if command -sq gem;
        echo "♢ Updating Ruby packages"
        gem update
    end
end
alias __update_ruby __update_gem

function __update_fish
    if command -sq fish;
        echo "♢ Updating Fish packages"
        if  type -q fisher;
            fisher up
        end

        if type -q omf;
            omf update
        end
    end
end

function __update_dotfiles
    if test -d ~/.dotfiles
        echo "♢ Updating dotfiles"
        git -C ~/.dotfiles stash
        git -C ~/.dotfiles pull origin master
        git -C ~/.dotfiles stash pop
        git -C ~/.dotfiles submodule foreach git pull origin master
    end
    if test -d ~/.zprezto
        echo "♢ Updating the Prezto framework"
        git -C ~/.zprezto pull origin master
        git -C ~/.zprezto submodule foreach git pull origin master
    end
end

function __update_packages
    __update_brew
    __update_npm
    __update_yarn
    __update_pip
    __update_composer
    __update_gem
    __update_fish
end

function __update_all
    __update_system
    __update_mas
    __update_brew
    __update_npm
    __update_yarn
    __update_pip
    __update_composer
    __update_apm
    __update_gem
    __update_fish
    __update_dotfiles
end
