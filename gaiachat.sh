#!/bin/bash

# Function to check if NVIDIA CUDA or GPU is present
check_cuda() {
    if command -v nvcc &> /dev/null || command -v nvidia-smi &> /dev/null; then
        echo "✅ NVIDIA GPU with CUDA detected."
        return 0  # CUDA is present
    else
        echo "❌ NVIDIA GPU Not Found."
        return 1  # CUDA is not present
    fi
}

# Function to check if the system is a VPS, Laptop, or Desktop
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

# Function to set the API URL based on system type and CUDA presence
set_api_url() {
    check_system_type
    system_type=$?

    check_cuda
    cuda_present=$?

    if [ "$system_type" -eq 0 ]; then
        # VPS
        API_URL="https://llama.gaia.domains/v1/chat/completions"
        API_NAME="llama"
    elif [ "$system_type" -eq 1 ]; then
        # Laptop
        if [ "$cuda_present" -eq 0 ]; then
            API_URL="https://sirjames.gaia.domains/v1/chat/completions"
            API_NAME="james"
        else
            API_URL="https://llama.gaia.domains/v1/chat/completions"
            API_NAME="llama"
        fi
    elif [ "$system_type" -eq 2 ]; then
        # Desktop
        if [ "$cuda_present" -eq 0 ]; then
            API_URL="https://llama.gaia.domains/v1/chat/completions"
            API_NAME="llama"
        else
            API_URL="https://llama.gaia.domains/v1/chat/completions"
            API_NAME="llama"
        fi
    fi

    echo "🔗 Using API: ($API_NAME)"
}

# Set the API URL based on system type and CUDA presence
set_api_url

# Check if jq is installed, and if not, install it
if ! command -v jq &> /dev/null; then
    echo "❌ jq not found. Installing jq..."
    sudo apt update && sudo apt install jq -y
    if [ $? -eq 0 ]; then
        echo "✅ jq installed successfully!"
    else
        echo "❌ Failed to install jq. Please install jq manually and re-run the script."
        exit 1
    fi
else
    echo "✅ jq is already installed."
fi

# Function to get a random general question based on the API URL
generate_random_general_question() {
    if [[ "$API_URL" == "https://llama.gaia.domains/v1/chat/completions" ]]; then
general_questions=(
  "Why is the Renaissance considered a turning point in history?"
"How did the Industrial Revolution change the world?"
"Why is the Great Wall of China historically significant?"
"What were the main causes of World War I?"
"How did the printing press impact society?"
"Why is the moon landing in 1969 considered a major achievement?"
"What led to the fall of the Roman Empire?"
"How did the Cold War shape global politics?"
"Why is the Amazon rainforest important for the planet?"
"What sound does a cat make?"
"Which number comes after 4?"
"What is the opposite of 'hot'?"
"What do you use to brush your teeth?"
"What is the first letter of the alphabet?"
"What shape is a football?"
"How many fingers do humans have?"
"How do vaccines work to protect against diseases?"
"What are black holes, and why are they important in astronomy?"
"How does climate change affect ecosystems?"
"Why is the discovery of DNA considered revolutionary?"
"How did the internet change modern communication?"
"What role does the United Nations play in global peacekeeping?"
"Why is the Suez Canal important for global trade?"
"How did the Magna Carta influence modern democracy?"
"Why is the water cycle crucial for life on Earth?"
"What are the main challenges of space exploration?"
"How did the discovery of electricity transform society?"
"Why is the number zero important in mathematics?"
"How is the Fibonacci sequence observed in nature?"
"Why is the Pythagorean theorem significant in geometry?"
"How does probability influence real-life decision-making?"
"What are prime numbers, and why are they important in cryptography?"
"Why is calculus essential in modern science and engineering?"
"How does the concept of infinity affect mathematical theories?"
"What is the significance of Euler’s formula in mathematics?"
"Why is Pi considered an irrational number, and why is it useful?"
"How does statistics help in making informed decisions?"
"What is artificial intelligence, and how is it changing the world?"
"How do self-driving cars work?"
"What are the benefits of renewable energy sources?"
"Why is cybersecurity important in the digital age?"
"What is the significance of the discovery of penicillin?"
"How do social media platforms influence public opinion?"
"What are the main causes of climate change?"
"Why is the Hubble Space Telescope important for astronomy?"
"What is the significance of the Rosetta Stone?"
"How do cryptocurrencies like Bitcoin work?"
"What are the health benefits of regular exercise?"
"Why is the discovery of the Higgs boson important for physics?"
"How does the human brain process emotions?"
"What are the main differences between classical and quantum physics?"
"Why is the invention of the wheel considered a milestone in human history?"
"How do vaccines contribute to herd immunity?"
"What are the ethical implications of genetic engineering?"
"Why is the discovery of exoplanets important for astronomy?"
"How do plants convert sunlight into energy through photosynthesis?"
"What is the significance of the discovery of the structure of DNA?"
"Why is the concept of time zones necessary?"
"How do earthquakes occur, and how are they measured?"
"What are the main benefits of space exploration for humanity?"
"Why is the invention of the telephone considered a breakthrough in communication?"
"How do vaccines help prevent the spread of infectious diseases?"
"What is the significance of the discovery of the double helix structure of DNA?"
"Why is the concept of democracy important in modern societies?"
"How do renewable energy sources like solar and wind power work?"
"What are the main challenges of artificial intelligence development?"
"Why is the discovery of the theory of relativity important for physics?"
"How do vaccines contribute to global health?"
"What is the significance of the discovery of the structure of the atom?"
"Why is the invention of the internet considered a turning point in history?"
"How do vaccines help in eradicating diseases like smallpox?"
"What are the main benefits of a balanced diet for human health?"
"Why is the discovery of the structure of the universe important for cosmology?"
"How do vaccines help in controlling pandemics like COVID-19?"
)

    elif [[ "$API_URL" == "https://sirjames.gaia.domains/v1/chat/completions" ]]; then
general_questions=(
   "What is the capital city of France?"
"How does photosynthesis work in plants?"
"What are the main benefits of meditation for mental health?"
"Why is the Great Barrier Reef important for marine life?"
"What is the significance of the discovery of penicillin?"
"How do electric cars help reduce carbon emissions?"
"What are the main causes of deforestation in the Amazon?"
"Why is the invention of the airplane considered a milestone in history?"
"How do vaccines help prevent the spread of infectious diseases?"
"What is the role of the World Health Organization (WHO) in global health?"
"Why is the discovery of the structure of DNA important for biology?"
"How do renewable energy sources like solar and wind power work?"
"What are the main challenges of space exploration for humanity?"
"Why is the concept of democracy important in modern societies?"
"How do social media platforms influence public opinion?"
"What is the significance of the discovery of the Higgs boson in physics?"
"How do earthquakes occur, and how are they measured?"
"What are the health benefits of regular physical exercise?"
"Why is the invention of the internet considered a turning point in history?"
"How do vaccines contribute to herd immunity?"
"What are the ethical implications of genetic engineering?"
"Why is the discovery of exoplanets important for astronomy?"
"How does the human brain process emotions and memories?"
"What are the main differences between classical and quantum physics?"
"Why is the concept of time zones necessary for global coordination?"
"What is the significance of the Rosetta Stone in understanding ancient languages?"
"How do cryptocurrencies like Bitcoin work?"
"What are the main benefits of a balanced diet for human health?"
"Why is the discovery of the theory of relativity important for physics?"
"How do vaccines help in eradicating diseases like smallpox?"
"What is the significance of the discovery of the structure of the atom?"
"Why is the invention of the telephone considered a breakthrough in communication?"
"How do vaccines help in controlling pandemics like COVID-19?"
"What are the main challenges of artificial intelligence development?"
"Why is the discovery of the structure of the universe important for cosmology?"
"How do plants convert sunlight into energy through photosynthesis?"
"What is the significance of the discovery of the double helix structure of DNA?"
"Why is the invention of the wheel considered a milestone in human history?"
"How do vaccines contribute to global health?"
"What are the main benefits of renewable energy sources?"
"Why is the discovery of the structure of the universe important for cosmology?"
"How do vaccines help in controlling pandemics like COVID-19?"
"What are the main challenges of artificial intelligence development?"
"Why is the discovery of the theory of relativity important for physics?"
"How do vaccines help in eradicating diseases like smallpox?"
"What is the significance of the discovery of the structure of the atom?"
"Why is the invention of the telephone considered a breakthrough in communication?"
"How do vaccines help in controlling pandemics like COVID-19?"
"What are the main challenges of artificial intelligence development?"
"Why is the discovery of the structure of the universe important for cosmology?"
)
    elif [[ "$API_URL" == "https://llama.gaia.domains/v1/chat/completions" ]]; then
  general_questions=(
    "What is the capital city of France?"
"How does photosynthesis work in plants?"
"What are the main benefits of meditation for mental health?"
"Why is the Great Barrier Reef important for marine life?"
"What is the significance of the discovery of penicillin?"
"How do electric cars help reduce carbon emissions?"
"What are the main causes of deforestation in the Amazon?"
"Why is the invention of the airplane considered a milestone in history?"
"How do vaccines help prevent the spread of infectious diseases?"
"What is the role of the World Health Organization (WHO) in global health?"
"Why is the discovery of the structure of DNA important for biology?"
"How do renewable energy sources like solar and wind power work?"
"What are the main challenges of space exploration for humanity?"
"Why is the concept of democracy important in modern societies?"
"How do social media platforms influence public opinion?"
"What is the significance of the discovery of the Higgs boson in physics?"
"How do earthquakes occur, and how are they measured?"
"What are the health benefits of regular physical exercise?"
"Why is the invention of the internet considered a turning point in history?"
"How do vaccines contribute to herd immunity?"
"What are the ethical implications of genetic engineering?"
"Why is the discovery of exoplanets important for astronomy?"
"How does the human brain process emotions and memories?"
"What are the main differences between classical and quantum physics?"
"Why is the concept of time zones necessary for global coordination?"
"What is the significance of the Rosetta Stone in understanding ancient languages?"
"How do cryptocurrencies like Bitcoin work?"
"What are the main benefits of a balanced diet for human health?"
"Why is the discovery of the theory of relativity important for physics?"
"How do vaccines help in eradicating diseases like smallpox?"
"What is the significance of the discovery of the structure of the atom?"
"Why is the invention of the telephone considered a breakthrough in communication?"
"How do vaccines help in controlling pandemics like COVID-19?"
"What are the main challenges of artificial intelligence development?"
"Why is the discovery of the structure of the universe important for cosmology?"
"How do plants convert sunlight into energy through photosynthesis?"
"What is the significance of the discovery of the double helix structure of DNA?"
"Why is the invention of the wheel considered a milestone in human history?"
"How do vaccines contribute to global health?"
"What are the main benefits of renewable energy sources?"
"Why is the discovery of the structure of the universe important for cosmology?"
"How do vaccines help in controlling pandemics like COVID-19?"
"What are the main challenges of artificial intelligence development?"
"Why is the discovery of the theory of relativity important for physics?"
"How do vaccines help in eradicating diseases like smallpox?"
"What is the significance of the discovery of the structure of the atom?"
"Why is the invention of the telephone considered a breakthrough in communication?"
"How do vaccines help in controlling pandemics like COVID-19?"
"What are the main challenges of artificial intelligence development?"
"Why is the discovery of the structure of the universe important for cosmology?"
)
    fi

    echo "${general_questions[$RANDOM % ${#general_questions[@]}]}"
}

# Function to handle the API request
send_request() {
    local message="$1"
    local api_key="$2"

    echo "📬 Sending Question to $API_NAME: $message"

    json_data=$(cat <<EOF
{
    "messages": [
        {"role": "system", "content": "You are a helpful assistant."},
        {"role": "user", "content": "$message"}
    ]
}
EOF
    )

    response=$(curl -s -w "\n%{http_code}" -X POST "$API_URL" \
        -H "Authorization: Bearer $api_key" \
        -H "Accept: application/json" \
        -H "Content-Type: application/json" \
        -d "$json_data")

    http_status=$(echo "$response" | tail -n 1)
    body=$(echo "$response" | head -n -1)

    # Extract the 'content' from the JSON response using jq (Suppress errors)
    response_message=$(echo "$body" | jq -r '.choices[0].message.content' 2>/dev/null)

    if [[ "$http_status" -eq 200 ]]; then
        if [[ -z "$response_message" ]]; then
            echo "⚠️ Response content is empty!"
        else
            ((success_count++))  # Increment success count
            echo "✅ [SUCCESS] Response $success_count Received!"
            echo "📝 Question: $message"
            echo "💬 Response: $response_message"
        fi
    else
        echo "⚠️ [ERROR] API request failed | Status: $http_status | Retrying."
        sleep 5
    fi

    # Set sleep time based on API URL
    if [[ "$API_URL" == "https://llama.gaia.domains/v1/chat/completions" ]]; then
        echo "⏳ Fetching (llama API)..."
        sleep 20
    elif [[ "$API_URL" == "https://sirjames.gaia.domains/v1/chat/completions" ]]; then
        echo "⏳ Fetching (llama API)..."
        sleep 25
    elif [[ "$API_URL" == "https://llama.gaia.domains/v1/chat/completions" ]]; then
        echo "⏳ Fetching..."
        sleep 20
    fi
}

API_KEY_DIR="$HOME/gaianet"
mkdir -p "$API_KEY_DIR"

API_KEY_LIST=($(ls "$API_KEY_DIR" 2>/dev/null | grep '^apikey_'))

load_existing_key() {
    if [ ${#API_KEY_LIST[@]} -eq 0 ]; then
        echo "❌ No existing API keys found."
        return
    fi

    echo "🔍 Detected existing API keys:"
    for i in "${!API_KEY_LIST[@]}"; do
        echo "$((i+1))) ${API_KEY_LIST[$i]}"
    done

    echo -n "👉 Select a key to load (Enter number): "
    read -r key_choice

    if [[ "$key_choice" =~ ^[0-9]+$ ]] && ((key_choice > 0 && key_choice <= ${#API_KEY_LIST[@]})); then
        selected_file="${API_KEY_LIST[$((key_choice-1))]}"
        api_key=$(cat "$API_KEY_DIR/$selected_file")
        echo "✅ Loaded API key from $selected_file"
    else
        echo "❌ Invalid selection. Exiting..."
        exit 1
    fi
}

save_new_key() {
    echo -n "Enter your API Key: "
    read -r api_key

    if [ -z "$api_key" ]; then
        echo "❌ Error: API Key is required!"
        exit 1
    fi

    while true; do
        echo -n "Enter a name to save this key (no spaces): "
        read -r key_name
        key_name=$(echo "$key_name" | tr -d ' ')  # Remove spaces

        if [ -z "$key_name" ]; then
            echo "❌ Error: Name cannot be empty!"
        elif [ -f "$API_KEY_DIR/apikey_$key_name" ]; then
            echo "⚠️  A key with this name already exists! Choose a different name."
        else
            echo "$api_key" > "$API_KEY_DIR/apikey_$key_name"
            chmod 600 "$API_KEY_DIR/apikey_$key_name"  # Secure the key file
            echo "✅ API Key saved as 'apikey_$key_name'"
            break
        fi
    done
}

# Main Logic
if [ ${#API_KEY_LIST[@]} -gt 0 ]; then
    echo "📂 Existing API keys detected."
    echo "1) Load an existing API key"
    echo "2) Enter a new API key"
    echo -n "👉 Choose an option (1 or 2): "
    read -r choice

    case "$choice" in
        1) load_existing_key ;;
        2) save_new_key ;;
        *) echo "❌ Invalid choice. Exiting..." && exit 1 ;;
    esac
else
    echo "🔑 No saved API keys found. Please enter a new one."
    save_new_key
fi

# Asking for duration
echo -n "⏳ How many hours do you want the bot to run? "
read -r bot_hours

# Convert hours to seconds
if [[ "$bot_hours" =~ ^[0-9]+$ ]]; then
    max_duration=$((bot_hours * 3600))
    echo "🕒 The bot will run for $bot_hours hour(s) ($max_duration seconds)."
else
    echo "⚠️ Invalid input! Please enter a number."
    exit 1
fi

# Display thread information
echo "✅ Using 1 thread..."
echo "⏳ Waiting 30 seconds before sending the first request..."
sleep 5

echo "🚀 Starting requests..."
start_time=$(date +%s)
success_count=0  # Initialize success counter

while true; do
    current_time=$(date +%s)
    elapsed=$((current_time - start_time))

    if [[ "$elapsed" -ge "$max_duration" ]]; then
        echo "🛑 Time limit reached ($bot_hours hours). Exiting..."
        echo "📊 Total successful responses: $success_count"
        sleep 100000
        exit 0
    fi

    random_message=$(generate_random_general_question)
    send_request "$random_message" "$api_key"
done
