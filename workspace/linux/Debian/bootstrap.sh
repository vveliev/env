#!/usr/bin/env bash

function install {
    FILE="$2"
    URL="$1/$FILE"
    wget $URL -O $FILE
    sudo gdebi $FILE
    rm $FILE
}

function get_download_url {
    wget -q -nv -O- https://api.github.com/repos/$1/releases/latest 2>/dev/null |	jq -r '.assets[] | select(.browser_download_url | contains("linux-amd64")) | .browser_download_url'
}

function install_etckeeper {
    sudo apt install -y etckeeper
    sudo sed -i 's/^VCS=/#VCS/' /etc/etckeeper/etckeeper.conf
    sudo sed -i 's/^#?VCS=.*git.*/VCS="git"/' /etc/etckeeper/etckeeper.conf
    sudo cd /etc
    sudo etckeeper init
    sudo etckeeper commit "Initial checkin"
}

function install_pyenv {
    wget -O- https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash
}

function install_yppamanager {
    sudo add-apt-repository -y  ppa:webupd8team/y-ppa-manager
    sudo apt install -y y-ppa-manager
}

function install_wavebox {
    sudo wget -qO - https://wavebox.io/dl/client/repo/archive.key | sudo apt-key add -
    echo "deb https://wavebox.io/dl/client/repo/ x86_64/" | sudo tee /etc/apt/sources.list.d/wavebox.list
    sudo apt install -y wavebox ttf-mscorefonts-installer
}

function install_copyq {
    sudo add-apt-repository -y  ppa:hluk/copyq
    sudo apt install -y copyq
}

function install_docker {
    sudo snap install docker
    sudo usermod -aG docker $USER
}

function install_nvm {
    wget -O- https://raw.githubusercontent.com/creationix/nvm/v0.33.8/install.sh | bash
    source "$HOME/.nvm/nvm.sh" nouse
    nvm installn 10
    nvm use 10
    npm install -g npm@6
}

function install_nodenv {
    cd ~
    git clone https://github.com/nodenv/nodenv.git ~/.nodenv
    cd ~/.nodenv && src/configure && make -C src
    mkdir -p "$(nodenv root)"/plugins
    git clone https://github.com/nodenv/node-build.git "$(nodenv root)"/plugins/node-build
    nodenv package-hooks install --all
    git clone https://github.com/nodenv/nodenv-package-rehash.git "$(nodenv root)"/plugins/nodenv-package-rehash
    nodenv install 10.18.0
    nodenv global 10.18.0
    npm-setup-global-packages.sh
}

function install_mongodb {
    source /etc/lsb-release
    if [ "$DISTRIB_CODENAME" == "juno" ]; then DISTRIB_CODENAME=bionic; fi
    if [ "$DISTRIB_CODENAME" == "bionic" ]; then DISTRIB_CODENAME=xenial; fi
    sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2930ADAE8CAF5059EE73BB4B58712A2291FA4AD5
    echo "deb [arch=amd64] https://repo.mongodb.org/apt/ubuntu $DISTRIB_CODENAME/mongodb-org/3.6 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.6.list
    sudo apt install -y mongodb-org-tools mongodb-org-shell
}

function install_skm {
    sudo snap install go --classic
    go get github.com/TimothyYe/skm/cmd/skm
}

function install_stacer() {
    sudo add-apt-repository ppa:oguzhaninan/stacer -y
    jsudo apt-get update
    sudo apt-get install stacer -y
}

function need_fix_sudo() {
    BASE="$(sudo augtool match /files/etc/sudoers/*/user $USER)"
    [[ "$BASE" == "" ]] && return
    false
}

function add_touchpad() {
    sudo add-apt-repository -y  ppa:atareao/atareao
    sudo apt install touchpad-indicator
}

function fix_sudo() {
    if need_fix_sudo; then
        info "Adding $USER to sudoers with no password\n"
        sudo usermod -aG sudo $USER
		cat <<EOF >/tmp/sudoers.aug
set /files/etc/sudoers/spec[last()]/user "$USER"
set /files/etc/sudoers/spec[last()]/host_group/host "ALL"
set /files/etc/sudoers/spec[last()]/host_group/command "ALL"
set /files/etc/sudoers/spec[last()]/host_group/command/runas_user "ALL"
set /files/etc/sudoers/spec[last()]/host_group/command/tag "NOPASSWD"
save
EOF
        sudo augtool -f /tmp/sudoers.aug
    fi
    # echo "$USER ALL=(ALL) NOPASSWD: ALL" | sudo tee -a /etc/sudoers
}

function need_sysctl_patch() {
    BASE="$(sudo augtool match /files/etc/sysctl.conf/fs.inotify.max_user_watches)"
    [[ "$BASE" == "" ]] && return
    false
}

function patch_sysctl() {
    if need_sysctl_patch; then
        cat <<EOF >/tmp/sysctl.aug
set /files/etc/sysctl.conf/fs.inotify.max_user_watches 524288
save
EOF
        info "Setting sysctl.conf fs.inotify.max_user_watches=524288\n"
        sudo augtool -f /tmp/sysctl.aug
        sudo sysctl -p
    fi
}

function install_vscode() {
    wget -O- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
    sudo install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/
    echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" | sudo tee /etc/apt/sources.list.d/vscode.list
    sudo apt install -y apt-transport-https code
}

function install_google_chrome() {
    wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
    echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-chrome.list
    sudo apt install -y google-chrome-beta chrome-gnome-shell
}

function install_base_packages() {
    # NOTE: Update this with the latest tool added to the list
    if [ "$(which sakura)" == "" ]; then
        sudo apt update
        sudo apt install -y apt-transport-https curl autojump awscli bash-completion build-essential ca-certificates cifs-utils comprez \
        direnv dselect gawk gdebi git jq mc mysql-client net-tools p7zip-full s3cmd sshfs tmux tmux-plugin-manager vim-nox virtualenv \
        vpnc-scripts yadm whiptail aptitude terminator augeas-tools sakura fonts-powerline libffi-dev
    fi
}

function install_gui_packages() {
    sudo apt install -y gtk2-engines-murrine gtk2-engines-pixbuf fonts-roboto ninja-build meson sassc glogg meld synaptic menulibre kupfer remmina vim-gtk3 fonts-firacode
    sudo snap install opera
    install_peek
}

function install_bashit() {
    cd "$HOME"
    
    if [ ! -d ~/.bash_it ]; then
        git clone --depth 1 https://github.com/Bash-it/bash-it.git .bash_it
    fi

    #$ bash-it-config.sh  -- a la https://github.com/Bash-it/bash-it/issues/1350#issuecomment-549949179
    # Bash-it Enabled-Component Backup
    # Date: Wed 18 Dec 2019 02:46:07 PM EST
    # Folder: /home/mcrowe/.bash_it
    # Components: alias plugin completion

    # alias

    #bash-it disable alias all

    bash-it enable alias docker
    bash-it enable alias docker-compose
    bash-it enable alias general
    bash-it enable alias npm

    # plugin

    #bash-it disable plugin all

    bash-it enable plugin autojump
    bash-it enable plugin aws
    bash-it enable plugin base
    bash-it enable plugin direnv
    bash-it enable plugin docker
    bash-it enable plugin docker-compose
    bash-it enable plugin git
    bash-it enable plugin history
    bash-it enable plugin ssh
    bash-it enable plugin tmux

    # completion

    #bash-it disable completion all

    bash-it enable completion awless
    bash-it enable completion awscli
    bash-it enable completion bash-it
    bash-it enable completion docker
    bash-it enable completion docker-compose
    bash-it enable completion git
    bash-it enable completion git_flow
    bash-it enable completion gulp
    bash-it enable completion npm
    bash-it enable completion pip
    bash-it enable completion pip3
    bash-it enable completion ssh
    bash-it enable completion system
    bash-it enable completion tmux
    bash-it enable completion vuejs

}

function install_dotfiles() {
    cd "$HOME"
    
    if [ ! -d .dotfiles ]; then
        git clone --recursive https://github.com/drmikecrowe/dotphiles.git ~/.dotfiles
    fi
    
    grep -q $HOSTNAME .dotfiles/dotsyncrc
    if [ "$?" == "1" ]; then
        sed -i "/\[hosts\]/ a $HOSTNAME" .dotfiles/dotsyncrc
    fi
    ./.dotfiles/dotsync/bin/dotsync -L
    
    grep -q 'dotfiles/bash_it' ~/.bashrc
    if [ "$?" == "1" ]; then
        echo "source ~/.dotfiles/bash_it/bash-it.sh" >> ~/.bashrc
    fi
}

function grub_tools() {
    sudo add-apt-repository -y ppa:danielrichter2007/grub-customizer
    sudo add-apt-repository -y ppa:yannubuntu/boot-repair
    sudo apt install -y grub-customizer boot-repair 
}


function install_peek() {
    sudo add-apt-repository -y ppa:peek-developers/stable
    sudo apt install -y peek
}

function menu() {
    declare -a MENU
    
    if [ ! -d ~/.bash_it ]; then
        MENU=("BASH_IT" "Install Bash-it?" OFF)
        MENU=("${MENU[@]}" "DOTFILES" "Install dotfiles?" OFF)
    else
        MENU=("DOTFILES" "Update dotfiles?" OFF)
    fi
    if [ ! -f /etc/ssh/sshd_config ]; then MENU=("${MENU[@]}" "SSHD" "Install ssh server?" ON); fi
    if [ ! -d /etc/etckeeper ]; then MENU=("${MENU[@]}" "ETCKEEPER" "Install etckeeper?" ON); fi
    if [ ! -d ~/.pyenv ]; then MENU=("${MENU[@]}" "PYENV" "Install pyenv?" ON); fi
    if [ "$(which docker)" == "" ]; then MENU=("${MENU[@]}" "DOCKER" "Install docker?" ON); fi
    if [ ! -d ~/.nodenv]; then MENU=("${MENU[@]}" "NODENV" "Install nodenv?" ON); fi
    if [ ! -d ~/.nvm ]; then MENU=("${MENU[@]}" "NVM" "Install nvm?" ON); fi
    if [ "$(which mongorestore)" == "" ]; then MENU=("${MENU[@]}" "MONGO" "Install MongoDB CLI tools?" OFF); fi
    
    if need_fix_sudo; then MENU=("${MENU[@]}" "FIX_SUDO" "Remove sudo password prompt?" ON); fi
    if need_sysctl_patch; then MENU=("${MENU[@]}" "FIX_SYSCTL" "Increase inotify user watches in /etc/sysctl?" ON); fi
    
    if [ "$(which kupfer)" == "" ]; then MENU=("${MENU[@]}" "GUI" "Install common GUI packages?" ON); fi
    if [ ! -f /opt/wavebox/Wavebox ]; then MENU=("${MENU[@]}" "WAVEBOX" "Install Wavebox?" OFF); fi
    if [ "$(which copyq)" == "" ]; then MENU=("${MENU[@]}" "COPYQ" "Install copyq?" ON); fi
    if [ "$(which y-ppa-manager)" == "" ]; then MENU=("${MENU[@]}" "YPPAMANAGER" "Install y-ppa-manager?" OFF); fi
    if [ "$(which code)" == "" ]; then MENU=("${MENU[@]}" "VSCODE" "Install Visual Studio Code" ON); fi
    if [ "$(which skm)" == "" ]; then MENU=("${MENU[@]}" "SKM" "Install SKM Key Manager" ON); fi
    if [ "$(which google-chrome-beta)" == "" ]; then MENU=("${MENU[@]}" "GOOGLE_CHROME" "Install Google Chrome" ON); fi
    if [ "$(which spotify)" == "" ]; then MENU=("${MENU[@]}" "SPOTIFY" "Install Spotify" ON); fi
    if [ "$(which terraform)" == "" ]; then MENU=("${MENU[@]}" "TERRAFORM" "Install TerraForm" ON); fi
    if [ "$(which slack)" == "" ]; then MENU=("${MENU[@]}" "SLACK" "Install Slack" ON); fi
    if [ "$(which touchpad-indicator)" == "" ]; then MENU=("${MENU[@]}" "TOUCHPAD" "Install Touchpad Indicator" ON); fi
    if [ "$(which boot-repair)" == "" ]; then MENU=("${MENU[@]}" "BOOT_REPAIR" "Install Grub2 Customizer and Boot Repair" OFF); fi
    if [ "$(which stacer)" == "" ]; then MENU=("${MENU[@]}" "STACER" "Install Stacer" OFF); fi

    # if [ "$(which XXX)" == "" ]; then MENU=("${MENU[@]}" "XXX" "Install XXX" OFF); fi
    
    echo $(whiptail --title "Installation Selection" --checklist "Choose installation Packages" 20 78 12 "${MENU[@]}"  3>&1 1>&2 2>&3)
}


function mainScript() {
    install_base_packages
    
    if [ "$(which git)" == "" ]; then error "${bold}git${reset} required.	Please bootstrap first"; exit 1; fi
    
    MENU="$(menu)"
    for choice in $MENU; do
        case ${choice//\"/} in
            "SLACK") sudo snap install slack --classic; ;;
            "TERRAFORM") sudo snap install terraform; ;;
            "SPOTIFY") sudo snap install spotify; ;;
            "BASH_IT") install_bashit; ;;
            "DOTFILES") install_dotfiles; ;;
            "SSHD") sudo apt install -y openssh-server; ;;
            "ETCKEEPER") install_etckeeper; ;;
            "PYENV") install_pyenv; ;;
            "DOCKER") install_docker; ;;
            "NVM") install_nvm; ;;
            "NODENV") install_nodenv; ;;
            "MONGO") install_mongodb; ;;
            "FIX_SUDO") fix_sudo; ;;
            "FIX_SYSCTL") patch_sysctl; ;;
            "GUI") install_gui_packages; ;;
            "WAVEBOX") install_wavebox; ;;
            "COPYQ") install_copyq; ;;
            "YPPAMANAGER") install_yppamanager; ;;
            "VSCODE") install_vscode; ;;
            "SKM") install_skm; ;;
            "GOOGLE_CHROME") install_google_chrome; ;;
            "TOUCHPAD") add_touchpad; ;;
            "BOOT_REPAIR") grub_tools; ;;
            "STACER") install_stacer; ;;
            *) echo "Unknown option $choice"; exit 1; ;;
        esac
    done
    
}

# Options and Usage
# -----------------------------------
function usage() {
    echo -n "${scriptName} [OPTION]...

 ${bold}Options:${reset}
	-l, --log-level					 Set the display logging level (default=${bold}notice${reset}. Valid values are debug|info|notice
	-d, --debug							 Set logging level to debug (shortcut)
	-n, --notice							Set logging level to notice (shortcut)
	-h, --help								Display this help and exit
			--version						 Output version information and exit
    "
}

function process_user_options() {
    # Print help if no arguments were passed.
    # Uncomment to force arguments when invoking the script
    # -------------------------------------
    #[[ $# -eq 0 ]] && set -- "--help"
    
    # Set Flags
    quiet=false
    printLog=false
    logLevel=info
    force=false
    strict=false
    debug=false
    readme=true
    output=true
    args=()
    
    # Read the options and set stuff
    while [[ ${1} = -?* ]]; do
        case ${1} in
            -h|--help) usage >&2; safeExit ;;
            --version) echo "$(basename ${0}) ${version}"; safeExit ;;
            -p|--prefix) shift; GEOMODULE=${1}; GOUT=output-${GEOMODULE}.tf; notice "Changing the prefix to ${bold}${GEOMODULE}${reset}" ;;
            -o|--output-name) shift; GOUT=${1}; notice "Changing the output modules name to ${bold}${GOUT}${reset}" ;;
            -l|--log-level) shift; logLevel=${1}; shift; ;;
            -d|--debug) shift; logLevel=debug; shift; ;;
            -n|--notice) shift; logLevel=notice; shift; ;;
            --endopts) shift; break ;;
            *) usage; die "invalid option: '${1}'." ;;
        esac
        shift
    done
    
    # Store the remaining part as arguments.
    args+=("$@")
}

###
### ----------------------[ No editing normally below here ]----------------------
###

# Define log levels
# ----------------------
declare -A logLevels=(["debug"]=0 ["info"]=1 ["notice"]=2)
declare -A cache=()

# Set Base Variables
# ----------------------
scriptName=$(basename "${0}")

# Logging
# -----------------------------------
# Log is only used when the '-l' flag is set.
logFile="/tmp/${scriptBasename}.log"

function trapCleanup() {
    echo ""
    # Delete temp files, if any
    if [ -d "${tmpDir}" ] ; then
        rm -r "${tmpDir}"
    fi
    die "Exit trapped. In function: '${FUNCNAME[*]}'"
}

function safeExit() {
    # Delete temp files, if any
    if [ -d "${tmpDir}" ] ; then
        rm -r "${tmpDir}"
    fi
    trap - INT TERM EXIT
    exit
}

# Set Colors
bold=$(tput bold)
reset=$(tput sgr0)
purple=$(tput setaf 171)
red=$(tput setaf 1)
green=$(tput setaf 76)
tan=$(tput setaf 3)
blue=$(tput setaf 38)
underline=$(tput sgr 0 1)

# Set Temp Directory
tmpDir="/tmp/${scriptName}.${RANDOM}.${RANDOM}.${RANDOM}.$"
(umask 077 && mkdir "${tmpDir}") || {
    die "Could not create temporary directory! Exiting."
}

# Logging & Feedback
# -----------------------------------------------------
function _alert() {
    case ${1} in
        debug|notice|info)
            [[ ${logLevels[${1}]} ]] || return 1
            
            #check if level is enough
            (( ${logLevels[${1}]} < ${logLevels[$logLevel]} )) && return 2
        ;;
    esac
    case ${1} in
        error) local color="${bold}${red}"; ;;
        warning) local color="${red}"; ;;
        success) local color="${green}"; ;;
        debug) local color="${purple}"; ;;
        header) local color="${bold}${tan}"; ;;
        input) local color="${bold}"; ;;
        notice) local color="${green}"; ;;
        info) local color=""; ;;
    esac
    
    # Don't use colors on pipes or non-recognized terminals
    if [[ "${TERM}" != "xterm"* ]] || [ -t 1 ]; then color=""; reset=""; fi
    
    # Print to console when script is not 'quiet'
    if ${quiet}; then return; else
        echo -e "$(date +"%r") ${color}$(printf "[%7s]" "${1}") ${_message}${reset}\\n";
    fi
    
    # Print to Logfile
    if ${printLog} && [ "${1}" != "input" ]; then
        color=""; reset="" # Don't use colors in logs
        echo -e "$(date +"%m-%d-%Y %r") $(printf "[%7s]" "${1}") ${_message}" >> "${logFile}";
    fi
}

function die ()			 { local _message="${*} Exiting."; quiet=false; echo -e "$(_alert error)"; safeExit;}
function error ()		 { local _message="${*}"; echo -en "$(_alert error)"; }
function warning ()	 { local _message="${*}"; echo -en "$(_alert warning)"; }
function notice ()		{ local _message="${*}"; echo -en "$(_alert notice)"; }
function info ()			{ local _message="${*}"; echo -en "$(_alert info)"; }
function debug ()		 { local _message="${*}"; echo -en "$(_alert debug)"; }
function success ()	 { local _message="${*}"; echo -en "$(_alert success)"; }
function input()			{ local _message="${*}"; echo -en "$(_alert input)"; }
function header()		 { local _message="== ${*} ==	"; echo -e "$(_alert header)"; }
function verbose()		{ if ${verbose}; then debug "$@"; fi }

# SEEKING CONFIRMATION
# ------------------------------------------------------
function seek_confirmation() {
    input "$@"
    if "${force}"; then
        notice "Forcing confirmation with '--force' flag set"
    else
        read -p " (y/n) " -n 1
        echo ""
    fi
}
function is_confirmed() {
    if "${force}"; then
        return 0
    else
        if [[ "${REPLY}" =~ ^[Yy]$ ]]; then
            return 0
        fi
        return 1
    fi
}
function is_not_confirmed() {
    if "${force}"; then
        return 1
    else
        if [[ "${REPLY}" =~ ^[Nn]$ ]]; then
            return 0
        fi
        return 1
    fi
}


# Iterate over options breaking -ab into -a -b when needed and --foo=bar into
# --foo bar
optstring=h
unset options
while (($#)); do
    case ${1} in
        # If option is of type -ab
        -[!-]?*)
            # Loop over each character starting with the second
            for ((i=1; i < ${#1}; i++)); do
                c=${1:i:1}
                
                # Add current char to options
                options+=("-$c")
                
                # If option takes a required argument, and it's not the last char make
                # the rest of the string its argument
                if [[ $optstring = *"$c:"* && ${1:i+1} ]]; then
                    options+=("${1:i+1}")
                    break
                fi
            done
        ;;
        
        # If option is of type --foo=bar
        --?*=*) options+=("${1%%=*}" "${1#*=}") ;;
        # add --endopts for --
        --) options+=(--endopts) ;;
        # Otherwise, nothing special
        *) options+=("${1}") ;;
    esac
    shift
done
set -- "${options[@]}"
unset options

process_user_options $@

# Trap bad exits with your cleanup function
trap trapCleanup EXIT INT TERM

# Set IFS to preferred implementation
IFS=$' \n\t'

# Exit on error. Append '||true' when you run the script if you expect an error.
#set -o errexit

# Run in debug mode, if set
if ${debug}; then set -x ; fi

# Exit on empty variable
if ${strict}; then set -o nounset ; fi

# Bash will remember & return the highest exitcode in a chain of pipes.
# This way you can catch the error in case mysqldump fails in `mysqldump |gzip`, for example.
set -o pipefail

# Run your script
mainScript

# Exit cleanly
safeExit

# vim: tabstop=4 shiftwidth=4 expandtab
