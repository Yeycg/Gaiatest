#!/bin/bash

printf "\n"
cat <<EOF


░██████╗░░█████╗░  ░█████╗░██████╗░██╗░░░██╗██████╗░████████╗░█████╗░
██╔════╝░██╔══██╗  ██╔══██╗██╔══██╗╚██╗░██╔╝██╔══██╗╚══██╔══╝██╔══██╗
██║░░██╗░███████║  ██║░░╚═╝██████╔╝░╚████╔╝░██████╔╝░░░██║░░░██║░░██║
██║░░╚██╗██╔══██║  ██║░░██╗██╔══██╗░░╚██╔╝░░██╔═══╝░░░░██║░░░██║░░██║
╚██████╔╝██║░░██║  ╚█████╔╝██║░░██║░░░██║░░░██║░░░░░░░░██║░░░╚█████╔╝
░╚═════╝░╚═╝░░╚═╝  ░╚════╝░╚═╝░░╚═╝░░░╚═╝░░░╚═╝░░░░░░░░╚═╝░░░░╚════╝░
EOF

printf "\n\n"

##########################################################################################
#                                                                                        
#                🚀 THIS SCRIPT IS PROUDLY CREATED BY **GA CRYPTO**! 🚀                 
#                                                                                        
#   🌐 Join our revolution in decentralized networks and crypto innovation!               
#                                                                                        
# 📢 Stay updated:                                                                      
#     • Follow us on Telegram: https://t.me/GaCryptOfficial                             
#     • Follow us on X: https://x.com/GACryptoO                                         
##########################################################################################

# Green color for advertisement
GREEN="\033[0;32m"
RESET="\033[0m"

# Ensure required packages are installed
echo "📦 Installing dependencies..."
sudo apt update -y && sudo apt install -y pciutils libgomp1 curl wget build-essential libglvnd-dev pkg-config libopenblas-dev libomp-dev

# Detect if running inside WSL
IS_WSL=false
if grep -qi microsoft /proc/version; then
    IS_WSL=true
    echo "🖥️ Running inside WSL."
else
    echo "🖥️ Running on a native Ubuntu system."
fi

# Check if an NVIDIA GPU is present
check_nvidia_gpu() {
    if command -v nvidia-smi &> /dev/null || lspci | grep -i nvidia &> /dev/null; then
        echo "✅ NVIDIA GPU detected."
        return 0
    else
        echo "⚠️ No NVIDIA GPU found."
        return 1
    fi
}

# Check if the system is a VPS, Laptop, or Desktop
check_system_type() {
    vps_type=$(systemd-detect-virt)
    if echo "$vps_type" | grep -qiE "kvm|qemu|vmware|xen|lxc"; then
        echo "✅ This is a VPS."
        return 0  # VPS
    elif ls /sys/class/power_supply/ | grep -q "^BAT[0-9]"; then
        echo "✅ This is a Laptop."
        return 1  # Laptop
    else
        echo "✅ This is a Desktop."
        return 2  # Desktop
    fi
}

# Function to install CUDA Toolkit in WSL or Ubuntu 24.04
install_cuda() {
    if $IS_WSL; then
        echo "🖥️ Installing CUDA for WSL 2..."
    else
        echo "🖥️ Installing CUDA for Ubuntu 24.04..."
    fi

    # Add NVIDIA CUDA repository
    echo "📥 Adding NVIDIA CUDA repository..."
    wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/cuda-ubuntu2404.pin
    sudo mv cuda-ubuntu2404.pin /etc/apt/preferences.d/cuda-repository-pin-600

    wget https://developer.download.nvidia.com/compute/cuda/12.8.0/local_installers/cuda-repo-ubuntu2404-12-8-local_12.8.0-570.86.10-1_amd64.deb
    sudo dpkg -i cuda-repo-ubuntu2404-12-8-local_12.8.0-570.86.10-1_amd64.deb
    sudo cp /var/cuda-repo-ubuntu2404-12-8-local/cuda-*-keyring.gpg /usr/share/keyrings/

    # Update package list and install CUDA Toolkit
    echo "🔄 Updating package list..."
    sudo apt update || { echo "❌ Failed to update package list"; exit 1; }
    echo "🔧 Installing CUDA Toolkit..."
    sudo apt install -y cuda || { echo "❌ Failed to install CUDA Toolkit"; exit 1; }

    echo "✅ CUDA Toolkit installed successfully."
    setup_cuda_env
}

# Set up CUDA environment variables
setup_cuda_env() {
    echo "🔧 Setting up CUDA environment variables..."
    if ! grep -q "/usr/local/cuda/bin" /etc/profile.d/cuda.sh; then
        echo 'export PATH=/usr/local/cuda/bin${PATH:+:${PATH}}' | sudo tee -a /etc/profile.d/cuda.sh
        echo 'export LD_LIBRARY_PATH=/usr/local/cuda/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}' | sudo tee -a /etc/profile.d/cuda.sh
    fi
}

# Install GaiaNet with appropriate CUDA support
install_gaianet() {
    if command -v nvcc &> /dev/null; then
        CUDA_VERSION=$(nvcc --version | grep 'release' | awk '{print $6}' | cut -d',' -f1 | sed 's/V//g' | cut -d'.' -f1)
        echo "✅ CUDA version detected: $CUDA_VERSION"
        if [[ "$CUDA_VERSION" == "11" || "$CUDA_VERSION" == "12" ]]; then
            echo "🔧 Installing GaiaNet with ggmlcuda $CUDA_VERSION..."
            curl -sSfL 'https://github.com/GaiaNet-AI/gaianet-node/releases/download/0.4.20/install.sh' -o install.sh
            chmod +x install.sh
            ./install.sh --ggmlcuda $CUDA_VERSION || { echo "❌ GaiaNet installation with CUDA failed."; exit 1; }
            return
        fi
    fi
    echo "⚠️ Installing GaiaNet without GPU support..."
    curl -sSfL 'https://github.com/GaiaNet-AI/gaianet-node/releases/download/0.4.20/install.sh' | bash || { echo "❌ GaiaNet installation without GPU failed."; exit 1; }
}

# Add GaiaNet to PATH
add_gaianet_to_path() {
    echo "🔧 Adding GaiaNet to PATH for both user and root..."
    
    # Define the GaiaNet path
    GAIA_PATH="$HOME/gaianet/bin"

    # Update user's .bashrc
    if ! grep -q "$GAIA_PATH" ~/.bashrc; then
        echo "export PATH=$GAIA_PATH:\$PATH" >> ~/.bashrc
    fi

    # Update root's .bashrc (run only if script is executed with sudo)
    if [ "$EUID" -eq 0 ]; then
        if ! grep -q "$GAIA_PATH" /root/.bashrc; then
            echo "export PATH=$GAIA_PATH:\$PATH" >> /root/.bashrc
        fi
    fi

    # Update system-wide environment (for all users, including sudo)
    if ! grep -q "$GAIA_PATH" /etc/profile.d/gaianet.sh 2>/dev/null; then
        echo "export PATH=$GAIA_PATH:\$PATH" | sudo tee /etc/profile.d/gaianet.sh >/dev/null
    fi

    # Apply changes
    source ~/.bashrc
    [ "$EUID" -eq 0 ] && source /root/.bashrc
    source /etc/profile.d/gaianet.sh

    echo "✅ GaiaNet added to PATH successfully."
}

# Main logic
if check_nvidia_gpu; then
    setup_cuda_env
    install_cuda
    add_gaianet_to_path
    install_gaianet
else
    install_gaianet
fi

# Verify GaiaNet installation
if [ -f ~/gaianet/bin/gaianet ]; then
    echo "✅ GaiaNet installed successfully."
    add_gaianet_to_path
else
    echo "❌ GaiaNet installation failed. Exiting."
    exit 1
fi

# Determine system type and set configuration URL
check_system_type
SYSTEM_TYPE=$?  # Capture the return value of check_system_type

if [[ $SYSTEM_TYPE -eq 0 ]]; then
    # VPS
    CONFIG_URL="https://raw.githubusercontent.com/abhiag/Gaia_Node/main/config2.json"
elif [[ $SYSTEM_TYPE -eq 1 ]]; then
    # Laptop
    if ! check_nvidia_gpu; then
        CONFIG_URL="https://raw.githubusercontent.com/abhiag/Gaia_Node/main/config2.json"
    else
        CONFIG_URL="https://raw.githubusercontent.com/abhiag/Gaia_Node/main/config1.json"
    fi
elif [[ $SYSTEM_TYPE -eq 2 ]]; then
    # Desktop
    if ! check_nvidia_gpu; then
        CONFIG_URL="https://raw.githubusercontent.com/abhiag/Gaia_Node/main/config2.json"
    else
        CONFIG_URL="https://raw.githubusercontent.com/abhiag/Gaia_Node/main/config3.json"
    fi
fi

# Initialize and start GaiaNet
echo "⚙️ Initializing GaiaNet..."
~/gaianet/bin/gaianet init --config "$CONFIG_URL" || { echo "❌ GaiaNet initialization failed!"; exit 1; }

echo "🚀 Starting GaiaNet node..."
~/gaianet/bin/gaianet config --domain gaia.domains
~/gaianet/bin/gaianet start || { echo "❌ Error: Failed to start GaiaNet node!"; exit 1; }

echo "🔍 Fetching GaiaNet node information..."
~/gaianet/bin/gaianet info || { echo "❌ Error: Failed to fetch GaiaNet node information!"; exit 1; }

# Closing message
echo "==========================================================="
echo "🎉 Congratulations! Your GaiaNet node is successfully set up!"
echo "🌟 Stay connected: Telegram: https://t.me/GaCryptOfficial | Twitter: https://x.com/GACryptoO"
echo "💪 Together, let's build the future of decentralized networks!"
echo "===========================================================" 
