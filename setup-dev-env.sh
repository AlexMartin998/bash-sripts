#!/bin/bash

set -e

echo "===== SCRIPT DE CONFIGURACIÓN PARA ENTORNO DEV (ZSH, NVM, GIT) ====="

confirm() {
    while true; do
        read -p "$1 [s/n]: " yn
        case $yn in
            [Ss]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo "Por favor, responde s o n.";;
        esac
    done
}

echo ""
echo "¿Qué deseas hacer? Puedes seleccionar múltiples opciones separadas por espacio:"
echo "1) Configurar ZSH y Oh My Zsh"
echo "2) Instalar NVM + Node.js + pnpm"
echo "3) Agregar alias útiles de Git"
echo "4) TODO (hacer todo)"
echo ""

read -p "Selecciona una o más opciones (ej. 1 2 3 o solo 4): " -a options

# Función para verificar si zsh está instalado
install_zsh() {
    if command -v zsh >/dev/null 2>&1; then
        echo "✅ Zsh ya está instalado."
    else
        echo "🔧 Instalando zsh..."
        sudo apt update
        sudo apt install -y zsh
    fi
}

# Función para instalar y configurar Oh My Zsh
configure_oh_my_zsh() {
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        echo "🔧 Instalando Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    else
        echo "✅ Oh My Zsh ya está instalado."
    fi

    echo "🔧 Instalando plugins zsh-autosuggestions y zsh-syntax-highlighting..."

    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions || true
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting || true

    echo "🔧 Actualizando plugins en .zshrc..."
    sed -i 's/plugins=(.*)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' ~/.zshrc || echo "plugins=(git zsh-autosuggestions zsh-syntax-highlighting)" >> ~/.zshrc

    echo "🔄 Aplicando cambios..."
    source ~/.zshrc
}

# Función para instalar NVM y Node.js
install_nvm() {
    echo "🔧 Instalando NVM..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.4/install.sh | bash

    echo "🔧 Configurando NVM en .zshrc..."
    {
        echo ''
        echo '# Configuración de NVM'
        echo 'export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"'
        echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"'
        echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"'
    } >> ~/.zshrc

    echo "🔄 Verificando si estás en Zsh..."
    if [ -n "$ZSH_VERSION" ]; then
        echo "✅ Estás en Zsh. Aplicando configuración..."
        source ~/.zshrc
        echo "⬇️ Instalando Node.js versión LTS..."
        nvm install --lts
        echo "⬇️ Instalando pnpm..."
        npm install -g pnpm
        echo "✅ NVM, Node.js LTS y pnpm instalados correctamente."
    else
        echo "⚠️  Estás en Bash. La configuración no puede aplicarse automáticamente."
        echo "👉 Abre una nueva terminal Zsh o ejecuta manualmente los siguientes comandos:"
        echo ""
        echo "   source ~/.zshrc"
        echo "   nvm install --lts"
        echo "   npm install -g pnpm"
        echo ""
    fi
}


# Función para configurar alias de Git
configure_git_aliases() {
    echo "🔧 Configurando alias de Git..."
    git config --global alias.lg 'log --oneline --decorate --all --graph'
    git config --global alias.s 'status -s -b'
    echo "✅ Alias de Git configurados."
}

# # Lógica principal
# if [[ "$option" == "1" || "$option" == "4" ]]; then
#     if confirm "¿Deseas configurar ZSH y Oh My Zsh?"; then
#         install_zsh
#         configure_oh_my_zsh
#     fi
# fi

# if [[ "$option" == "2" || "$option" == "4" ]]; then
#     if confirm "¿Deseas instalar NVM, Node.js y pnpm?"; then
#         install_nvm
#     fi
# fi

# if [[ "$option" == "3" || "$option" == "4" ]]; then
#     if confirm "¿Deseas agregar alias útiles a Git?"; then
#         configure_git_aliases
#     fi
# fi

# Lógica principal
for opt in "${options[@]}"; do
    case "$opt" in
        1)
            echo ""
            echo "🚀 Ejecutando opción 1: Configurar ZSH y Oh My Zsh"
            install_zsh
            configure_oh_my_zsh
            ;;
        2)
            echo ""
            echo "🚀 Ejecutando opción 2: Instalar NVM + Node.js + pnpm"
            install_nvm
            ;;
        3)
            echo ""
            echo "🚀 Ejecutando opción 3: Agregar alias útiles de Git"
            configure_git_aliases
            ;;
        4)
            echo ""
            echo "🚀 Ejecutando opción 4: TODO (hacer todo)"
            install_zsh
            configure_oh_my_zsh
            install_nvm
            configure_git_aliases
            break
            ;;
        *)
            echo "❌ Opción no válida: $opt"
            ;;
    esac
done

echo ""
echo "✅ Configuración completada. ¡Feliz desarrollo!"

