function update -d "Update OS and packages"
    set -l update_cmds system os mas mac-apps brew npm yarn pip python composer php apm atom gem ruby fish \
        dotfiles all packages usage help

    set -l sudo false

    if test (id -u) = 0
        set -l sudo true
    end

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
    printf "   %s" $argv[1]
    for x in (seq (count $argv));
        if test (math $x%9) -eq 0
            printf ",\n   "
            printf "%s" $argv[$x]
        else
            printf ", %s" $argv[$x]
        end
    end
    echo
end
alias __update_help __update_usage

function __update_system
    if command -v softwareupdate > /dev/null; and test (uname) = "Darwin";
        echo "♢ Updating macOS"
        sudo softwareupdate -ia
    end

    if command -v dnf > /dev/null;
        echo "♢ Updating RedHat based system"
        sudo dnf upgrade
    end

    if command -v yum > /dev/null; and not command -v dnf > /dev/null;
        echo "♢ Updating RedHat based system"
        sudo yum upgrade
    end

    if command -v apt > /dev/null; and test (uname) = "Linux";
        echo "♢ Updating Debian based system"
        sudo apt update
        sudo apt upgrade
    end

    if command -v apt-get > /dev/null; and not command -v apt > /dev/null;
        echo "♢ Updating Debian based system"
        sudo apt-get update
        sudo apt-get upgrade
    end
end
alias __update_os __update_system

function __update_mas
    if command -v mas > /dev/null;
        echo "♢ Updating Apps from App Store"
        mas upgrade
    end
end
alias __update_mac-apps __update_mas

function __update_brew
    if command -v brew > /dev/null;
        echo "♢ Updating Homebrew"
        brew update
        brew upgrade
        brew cleanup
        brew prune
        brew cask cleanup
    end
end

function __update_npm
    if command -v brew > /dev/null;
        echo "♢ Updating npm packages"
        npm update -g
    end
end

function __update_yarn
    if command -v yarn > /dev/null;
        echo "♢ Updating yarn packages"
        yarn global update
    end
end

function __update_pip
    if command -v pip > /dev/null;
        echo "♢ Updating 2.x packages"
        python -V
        pip -V
        pip freeze --local | grep -v '^\-e' | cut -d = -f 1  | xargs -n1 pip install -U
    end
    if command -v pip3 > /dev/null;
        echo "♢ Updating" (python3 -V) "packages"
        pip3 -V
        pip3 freeze --local | grep -v '^\-e' | cut -d = -f 1  | xargs -n1 pip3 install -U
    end
end
alias __update_python __update_pip

function __update_composer
    if command -v composer > /dev/null;
        echo "♢ Updating PHP packages"
        composer global update
    end
end
alias __update_php __update_composer

function __update_apm
    if command -v apm > /dev/null;
        echo "♢ Updating Atom packages"
        apm upgrade --no-confirm
    end
end
alias __update_atom __update_apm

function __update_gem
    if command -v gem > /dev/null;
        echo "♢ Updating Ruby packages"
        gem update
    end
end
alias __update_ruby __update_gem

function __update_fish
    if command -v fish > /dev/null
        echo "♢ Updating Fish packages"
        if functions | grep fisher > /dev/null;
            fisher up
        end

        if functions | grep omf > /dev/null;
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
