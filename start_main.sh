#!/bin/bash

# Настройки рамки
FRAME_COLOR="\e[1;34m"
NICK_COLOR="\e[1;33m"  # Цвет для выделения ника
FRAME_TOP="┌─────────────────────────────────────────────┐"
FRAME_BOTTOM="└─────────────────────────────────────────────┘"
FRAME_LEFT_RIGHT="│ "
FRAME_END="\e[0m\n"
FRAME_END2="\e[0m"

# Список приложений для автоматической установки
AUTO_APPS=(
    "visual-studio-code" "firefox" "google-chrome"
    "telegram" "yandex-music" "rocket-chat"
)

# Список приложений, не требующих --cask
NO_CASK_APPS=(
    "lcov"
)

# Функция для установки Homebrew
install_homebrew() {
    if [ -d /opt/goinfre/$USER/homebrew ]; then
        . ~/.zprofile
        brsw
        printf "$FRAME_COLOR
$FRAME_TOP
$FRAME_LEFT_RIGHT Homebrew directory already exists.         $FRAME_LEFT_RIGHT
$FRAME_BOTTOM$FRAME_END"
    else 
        printf "$FRAME_COLOR
$FRAME_TOP
$FRAME_LEFT_RIGHT Installing Homebrew...                     $FRAME_LEFT_RIGHT
$FRAME_BOTTOM$FRAME_END"
        git clone https://github.com/Homebrew/brew homebrew || exit 1
        eval "$(/opt/goinfre/$USER/homebrew/bin/brew shellenv)"
        chmod -R go-w "$(brew --prefix)/zsh"
        brew update --force --quiet || exit 1
    fi
}

# Функция для автоматической установки приложений
install_apps_auto() {
    printf "$FRAME_COLOR
$FRAME_TOP
$FRAME_LEFT_RIGHT Installing applications:                   $FRAME_LEFT_RIGHT
$FRAME_BOTTOM$FRAME_END"

    for app in "${NO_CASK_APPS[@]}"; do
        printf "${FRAME_COLOR}${FRAME_TOP}\n"
        printf "$FRAME_LEFT_RIGHT - %-40s $FRAME_LEFT_RIGHT\n" "$app"
        printf "$FRAME_BOTTOM$FRAME_END"
        brew install $app || exit 1
    done

    for app in "${AUTO_APPS[@]}"; do
        printf "${FRAME_COLOR}${FRAME_TOP}\n"
        printf "$FRAME_LEFT_RIGHT - %-40s $FRAME_LEFT_RIGHT\n" "$app"
        printf "${FRAME_BOTTOM}${FRAME_END}"
        brew install --cask $app || exit 1
    done
}

# Функция для ручной установки приложений
install_apps_manual() {
    printf "$FRAME_COLOR
$FRAME_TOP
$FRAME_LEFT_RIGHT Enter app name to install                  $FRAME_LEFT_RIGHT
$FRAME_LEFT_RIGHT (enter 'stop' to finish)                   $FRAME_LEFT_RIGHT
$FRAME_BOTTOM$FRAME_END"

    while true; do
        read -r APP_NAME
        if [ "$APP_NAME" = "stop" ]; then
            break
        fi

        if [[ " ${NO_CASK_APPS[*]} " =~ " ${APP_NAME} " ]]; then
            printf "${FRAME_COLOR}${FRAME_TOP}\n"
            printf "%s- %-41s %s\n" "${FRAME_LEFT_RIGHT}" "Installing $APP_NAME without --cask" "${FRAME_LEFT_RIGHT}"
            printf "${FRAME_BOTTOM}${FRAME_END}"
            brew install $APP_NAME || exit 1
        else
            printf "${FRAME_COLOR}${FRAME_TOP}\n"
            printf "%s- %-41s %s\n" "${FRAME_LEFT_RIGHT}" "Installing $APP_NAME with --cask" "${FRAME_LEFT_RIGHT}"
            printf "${FRAME_BOTTOM}${FRAME_END}"
            brew install --cask $APP_NAME || exit 1
        fi
    done
}

# Функция обновления приложений
update_apps() {
    printf "$FRAME_COLOR
$FRAME_TOP
$FRAME_LEFT_RIGHT Updating applications...                   $FRAME_LEFT_RIGHT
$FRAME_BOTTOM$FRAME_END"
    brew upgrade --force --quiet || exit 1
    brew update --force --quiet || exit 1
}

# Функция для проверки и добавления строк в .zshrc
check_and_update_zshrc() {
    ZSHRC_FILE="$HOME/.zshrc"
    APPDIR_LINE="export HOMEBREW_CASK_OPTS=\"--appdir=/opt/goinfre/$USER/Applications\""

    if ! grep -q "$APPDIR_LINE" "$ZSHRC_FILE"; then
        printf "$FRAME_COLOR
$FRAME_TOP
$FRAME_LEFT_RIGHT Updating .zshrc file...                    $FRAME_LEFT_RIGHT
$FRAME_BOTTOM$FRAME_END"
        echo "$APPDIR_LINE" >> "$ZSHRC_FILE"
    else
        printf "$FRAME_COLOR
$FRAME_TOP
$FRAME_LEFT_RIGHT HOMEBREW_CASK_OPTS already set in .zshrc   $FRAME_LEFT_RIGHT
$FRAME_BOTTOM$FRAME_END"
    fi
}

# Функция для проверки и добавления строк в .zprofile
check_and_update_zprofile() {
    ZPROFILE_FILE="$HOME/.zprofile"
    BRSW_FUNCTION="function brsw {
eval \"\$(/opt/goinfre/$USER/homebrew/bin/brew shellenv)\"
chmod -R go-w \"\$(brew --prefix)/share/zsh\"
}"
    VS_CODE_PATH="export PATH=\"\$PATH:/opt/goinfre/$USER/Applications/Visual Studio Code.app/Contents/Resources/app/bin\""

    if ! grep -q "$BRSW_FUNCTION" "$ZPROFILE_FILE"; then
        printf "$FRAME_COLOR
$FRAME_TOP
$FRAME_LEFT_RIGHT Updating .zprofile file...                 $FRAME_LEFT_RIGHT
$FRAME_BOTTOM$FRAME_END"
        echo "$BRSW_FUNCTION" >> "$ZPROFILE_FILE"
    else
        printf "$FRAME_COLOR
$FRAME_TOP
$FRAME_LEFT_RIGHT brsw function already set in .zprofile     $FRAME_LEFT_RIGHT
$FRAME_BOTTOM$FRAME_END"
    fi

    if ! grep -q "$VS_CODE_PATH" "$ZPROFILE_FILE"; then
        echo "$VS_CODE_PATH" >> "$ZPROFILE_FILE"
    else
        printf "$FRAME_COLOR
$FRAME_TOP
$FRAME_LEFT_RIGHT VS Code path already set in .zprofile      $FRAME_LEFT_RIGHT
$FRAME_BOTTOM$FRAME_END"
    fi
}

# Запрос на ввод ника
printf "$FRAME_COLOR
$FRAME_TOP
$FRAME_LEFT_RIGHT 🚀 Hi! This is a starter script that will  $FRAME_LEFT_RIGHT
$FRAME_LEFT_RIGHT    install a bunch of cool stuff in        $FRAME_LEFT_RIGHT
$FRAME_LEFT_RIGHT    goinfre/Applications. Let's go!         $FRAME_LEFT_RIGHT
$FRAME_LEFT_RIGHT                                            $FRAME_LEFT_RIGHT
$FRAME_LEFT_RIGHT ✨ Your nickname is: ${NICK_COLOR}$USER${FRAME_COLOR}              $FRAME_LEFT_RIGHT
$FRAME_BOTTOM$FRAME_END"

# Проверка наличия директории в goinfre
if [ -d /opt/goinfre/$USER ]; then
    cd /opt/goinfre/$USER
else 
    echo "Directory in goinfre doesn't exists"
    exit 1
fi

# Установка Homebrew
install_homebrew

# Создание директории для приложений
if [ -d /opt/goinfre/$USER/Applications ]; then
    printf "$FRAME_COLOR
$FRAME_TOP
$FRAME_LEFT_RIGHT Applications directory already exists.     $FRAME_LEFT_RIGHT
$FRAME_BOTTOM$FRAME_END"
else 
    printf "$FRAME_COLOR
$FRAME_TOP
$FRAME_LEFT_RIGHT Creating Applications directory...         $FRAME_LEFT_RIGHT
$FRAME_BOTTOM$FRAME_END"
    mkdir Applications
fi

# Проверка наличия директории для приложений
if [ -d /opt/goinfre/$USER/Applications ]; then
    printf "$FRAME_COLOR
$FRAME_TOP
$FRAME_LEFT_RIGHT Applications directory found. Updating...  $FRAME_LEFT_RIGHT
$FRAME_BOTTOM$FRAME_END"
    update_apps
fi

# Проверка и обновление .zshrc
check_and_update_zshrc

# Проверка и обновление .zprofile
check_and_update_zprofile

# Выбор режима установки приложений
printf "$FRAME_COLOR
$FRAME_TOP
$FRAME_LEFT_RIGHT Select application installation mode:      $FRAME_LEFT_RIGHT
$FRAME_LEFT_RIGHT 1. Automatic (predefined set of apps)      $FRAME_LEFT_RIGHT
$FRAME_LEFT_RIGHT 2. Manual (enter apps one by one)          $FRAME_LEFT_RIGHT
$FRAME_LEFT_RIGHT Enter mode number (1 or 2): $FRAME_END2"
read -p "" INSTALL_MODE
printf "$FRAME_COLOR$FRAME_BOTTOM$FRAME_END"

case $INSTALL_MODE in
    1)
        printf "$FRAME_COLOR
$FRAME_TOP
$FRAME_LEFT_RIGHT Automatically installing:                  $FRAME_LEFT_RIGHT
$FRAME_END2"

        for app in "${NO_CASK_APPS[@]}"; do
            printf "$FRAME_COLOR$FRAME_LEFT_RIGHT - %-40s $FRAME_LEFT_RIGHT\n" "$app"
        done
        for app in "${AUTO_APPS[@]}"; do
            printf "$FRAME_COLOR$FRAME_LEFT_RIGHT - %-40s $FRAME_LEFT_RIGHT\n" "$app"
        done
        printf "$FRAME_COLOR$FRAME_LEFT_RIGHT                                            $FRAME_LEFT_RIGHT
$FRAME_LEFT_RIGHT You can find more apps at:                 $FRAME_LEFT_RIGHT
$FRAME_LEFT_RIGHT https://formulae.brew.sh/cask/             $FRAME_LEFT_RIGHT
$FRAME_BOTTOM$FRAME_END"
        install_apps_auto
        ;;
    2)
        printf "$FRAME_COLOR
$FRAME_TOP
$FRAME_LEFT_RIGHT You can install the following apps:        $FRAME_LEFT_RIGHT
$FRAME_LEFT_RIGHT (enter 'stop' to finish)                   $FRAME_LEFT_RIGHT
$FRAME_END2"

        for app in "${NO_CASK_APPS[@]}"; do
            printf "$FRAME_COLOR$FRAME_LEFT_RIGHT - %-40s $FRAME_LEFT_RIGHT\n" "$app"
        done
        for app in "${AUTO_APPS[@]}"; do
            printf "$FRAME_COLOR$FRAME_LEFT_RIGHT - %-40s $FRAME_LEFT_RIGHT\n" "$app"
        done
        printf "$FRAME_COLOR$FRAME_LEFT_RIGHT                                            $FRAME_LEFT_RIGHT
$FRAME_LEFT_RIGHT You can find more apps at:                 $FRAME_LEFT_RIGHT
$FRAME_LEFT_RIGHT https://formulae.brew.sh/cask/             $FRAME_LEFT_RIGHT
$FRAME_BOTTOM$FRAME_END"
        install_apps_manual
        ;;
    *)
        printf "$FRAME_COLOR
$FRAME_TOP
$FRAME_LEFT_RIGHT Invalid mode selected. Exiting.            $FRAME_LEFT_RIGHT
$FRAME_BOTTOM$FRAME_END"
        exit 1
        ;;
esac

# Настройка Docker
printf "$FRAME_COLOR
$FRAME_TOP
$FRAME_LEFT_RIGHT Configuring Docker...                      $FRAME_LEFT_RIGHT
$FRAME_BOTTOM$FRAME_END"
rm -rf ~/Library/Containers/com.docker.docker
mkdir -p ~/goinfre/Docker/Data
ln -s ~/goinfre/Docker ~/Library/Containers/com.docker.docker

printf "$FRAME_COLOR
$FRAME_TOP
$FRAME_LEFT_RIGHT All done! Enjoy your setup.                $FRAME_LEFT_RIGHT
$FRAME_BOTTOM$FRAME_END"
