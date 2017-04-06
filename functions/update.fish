function update -d "update your mac"
    set -l system false
    set -l mas false # brew install mas #mas upgrade
    set -l brew false
    set -l npm false
    set -l yarn false
    set -l pip false
    set -l composer false
    set -l apm false
    set -l gem false
    set -l fishpkg false
    set -l dotfiles false
    set -l sudo false

    if test (id -u) = 0
        set -l sudo true
    end

    if test -z "$argv"
      __update_usage
      return 1
    end


    getopts $argv | while read -l key value
        switch $key
            case _
                switch $value
                    case 'system'
                        set system true
                    case 'mas'
                        set mas true
                    case 'brew'
                        set brew true
                    case 'npm'
                        set npm true
                    case 'yarn'
                        set yarn true
                    case 'pip'
                        set pip true
                    case 'composer'
                        set composer true
                    case 'apm'
                        set apm true
                    case 'gem'
                        set gem true
                    case 'dotfiles'
                        set dotfiles true
                    case 'fish'
                        set fishpkg true
                    case 'packages'
                        set brew true
                        set npm true
                        set yarn true
                        set pip true
                        set composer true
                        set apm true
                        set gem true
                    case 'all'
                        set system true
                        set mas true
                        set brew true
                        set npm true
                        set yarn true
                        set pip true
                        set composer true
                        set apm true
                        set gem true
                        set fishpkg true
                        set dotfiles true
                    case 'help'
                        __update_usage
                        return
                    case \*
                        printf "update: '%s' is not a valid option\n" $value > /dev/stderr
                        __update_usage
                end
            case h help
                __update_usage
                return
        end
    end

    if eval $system;
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

    if eval $mas; and command -v mas > /dev/null;
        echo "♢ Updating Apps from App Store"
        mas upgrade
    end

    if eval $brew; and command -v brew > /dev/null;
        echo "♢ Updating Homebrew"
        brew update
        brew upgrade
        brew cleanup
        brew prune
        brew cask cleanup
    end

    if eval $npm; and command -v brew > /dev/null;
        echo "♢ Updating npm packages"
        npm update -g
    end

    if eval $yarn; and command -v yarn > /dev/null;
        echo "♢ Updating yarn packages"
        yarn global update
    end

    if eval $pip; and command -v pip > /dev/null;
        echo "♢ Updating 2.x packages"
        python -V
        pip -V
        pip freeze --local | grep -v '^\-e' | cut -d = -f 1  | xargs -n1 pip install -U
    end
    if eval $pip; and command -v pip3 > /dev/null;
        echo "♢ Updating" (python3 -V) "packages"
        pip3 -V
        pip3 freeze --local | grep -v '^\-e' | cut -d = -f 1  | xargs -n1 pip3 install -U
    end

    if eval $composer; and command -v composer > /dev/null;
        echo "♢ Updating PHP packages"
        composer global update
    end

    if eval $apm; and command -v apm > /dev/null;
        echo "♢ Updating Atom packages"
        apm upgrade --no-confirm
    end

    if eval $gem; and command -v gem > /dev/null;
        echo "♢ Updating Ruby packages"
        gem update
    end

    if eval $fishpkg; and command -v fish > /dev/null
        echo "♢ Updating Fish packages"
        if functions | grep fisher > /dev/null;
            fisher up
        end

        if functions | grep omf > /dev/null;
            omf update
        end
    end

    if eval $dotfiles
        echo "♢ Updating dotfiles"
        git -C ~/.dotfiles stash
        git -C ~/.dotfiles pull origin master
        git -C ~/.dotfiles stash pop
        git -C ~/.dotfiles submodule foreach git pull origin master
        echo "♢ Updating the Prezto framework"
        git -C ~/.zprezto pull origin master
        git -C ~/.zprezto submodule foreach git pull origin master
    end
end

alias up=update

function __update_usage
    echo "Usage: update [options]"
    echo "    [system|mas|brew|npm|yarn|pip|composer|apm|gem|fish|dotfiles|all|packages] [--help]"
end
