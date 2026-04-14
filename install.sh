#!/data/data/com.termux/files/usr/bin/bash
# =========================================================================
# System: Android Uncensored AI Server (Termux Optimized)
# Description: Installs llama.cpp and runs local GGUF models on Android.
#              Models are loaded from /sdcard/AI_Models/ directory.
# =========================================================================

set -e

# --- Colour codes ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
GRAY='\033[0;90m'
NC='\033[0m'

echo -e "${CYAN}=========================================================="
echo -e "   ANDROID AI SERVER - TERMUX INSTALLER"
echo -e "==========================================================${NC}"

# 1. System Check
TOTAL_RAM=$(free -m | awk '/^Mem:/{print $2}')
echo -e "${YELLOW}Detected RAM: ${TOTAL_RAM} MB${NC}"

if [ "$TOTAL_RAM" -lt 4000 ]; then
    echo -e "${RED}Warning: Low RAM (<4GB). Only use models under 2B parameters.${NC}"
elif [ "$TOTAL_RAM" -lt 6000 ]; then
    echo -e "${YELLOW}Note: 4-6GB RAM detected. Models up to 3B should work fine.${NC}"
fi

# 2. Permissions & Dependencies
echo ""
echo -e "${YELLOW}[1/4] Preparing Termux environment...${NC}"
termux-setup-storage || true
sleep 2
pkg update -y
pkg install clang cmake git wget ninja -y

# =========================================================================
# 3. Model Discovery from /sdcard/AI_Models/
# =========================================================================
echo ""
echo -e "${CYAN}=========================================================="
echo -e "   MODEL SELECTION"
echo -e "==========================================================${NC}"

AI_MODELS_DIR="$HOME/storage/shared/AI_Models"
mkdir -p "$AI_MODELS_DIR" 2>/dev/null || true

# Scan for .gguf files
GGUF_FILES=()
if [ -d "$AI_MODELS_DIR" ]; then
    while IFS= read -r -d '' file; do
        GGUF_FILES+=("$file")
    done < <(find "$AI_MODELS_DIR" -maxdepth 1 -name "*.gguf" -type f -print0 2>/dev/null | sort -z)
fi

if [ ${#GGUF_FILES[@]} -gt 0 ]; then
    # ---- Models found on SD card ----
    echo ""
    echo -e "${GREEN}Found ${#GGUF_FILES[@]} model(s) in /sdcard/AI_Models/:${NC}"
    echo ""

    for i in "${!GGUF_FILES[@]}"; do
        FILENAME=$(basename "${GGUF_FILES[$i]}")
        FILESIZE=$(du -h "${GGUF_FILES[$i]}" 2>/dev/null | cut -f1)
        echo -e "  ${YELLOW}[$((i+1))]${NC} ${FILENAME} ${GRAY}(${FILESIZE})${NC}"
    done

    echo ""
    read -p "  Select model (1-${#GGUF_FILES[@]}): " MODEL_CHOICE

    # Validate input
    if ! [[ "$MODEL_CHOICE" =~ ^[0-9]+$ ]] || [ "$MODEL_CHOICE" -lt 1 ] || [ "$MODEL_CHOICE" -gt ${#GGUF_FILES[@]} ]; then
        echo -e "${YELLOW}Invalid choice. Defaulting to 1.${NC}"
        MODEL_CHOICE=1
    fi

    SELECTED_PATH="${GGUF_FILES[$((MODEL_CHOICE-1))]}"
    MODEL_FILE=$(basename "$SELECTED_PATH")
    MODEL_SOURCE="local"

    echo -e "${GREEN}Selected: ${MODEL_FILE}${NC}"

else
    # ---- No models found — offer ungated downloads ----
    echo ""
    echo -e "${RED}No .gguf models found in /sdcard/AI_Models/${NC}"
    echo ""
    echo -e "${GRAY}You can download models from HuggingFace and place .gguf files in:${NC}"
    echo -e "${CYAN}  /sdcard/AI_Models/${NC}"
    echo ""
    echo -e "${YELLOW}Or choose an ungated model to download now:${NC}"
    echo ""
    echo -e "  ${YELLOW}[1]${NC} Gemma-2-2B-Abliterated   ${GRAY}(1.6 GB)${NC} ${GREEN}[UNCENSORED - Abliterated]${NC}"
    echo -e "  ${YELLOW}[2]${NC} SmolLM2-1.7B-Uncensored  ${GRAY}(1.0 GB)${NC} ${GREEN}[UNCENSORED]${NC}"
    echo -e "  ${YELLOW}[3]${NC} Qwen2.5-1.5B-Instruct    ${GRAY}(1.1 GB)${NC} ${CYAN}[STANDARD - Multilingual]${NC}"
    echo -e "  ${YELLOW}[4]${NC} Phi-3.5-Mini-3.8B        ${GRAY}(2.2 GB)${NC} ${CYAN}[STANDARD - Smart]${NC}"
    echo ""
    echo -e "  ${RED}[0]${NC} Exit — I'll download a model myself first"
    echo ""
    read -p "  Choice (0/1/2/3/4): " DL_CHOICE

    case $DL_CHOICE in
        1)
            MODEL_URL="https://huggingface.co/bartowski/gemma-2-2b-it-abliterated-GGUF/resolve/main/gemma-2-2b-it-abliterated-Q4_K_M.gguf"
            MODEL_FILE="gemma-2-2b-it-abliterated-Q4_K_M.gguf"
            ;;
        2)
            MODEL_URL="https://huggingface.co/bartowski/SmolLM2-1.7B-Instruct-Uncensored-GGUF/resolve/main/SmolLM2-1.7B-Instruct-Uncensored-Q4_K_M.gguf"
            MODEL_FILE="SmolLM2-1.7B-Instruct-Uncensored-Q4_K_M.gguf"
            ;;
        3)
            MODEL_URL="https://huggingface.co/bartowski/Qwen2.5-1.5B-Instruct-GGUF/resolve/main/Qwen2.5-1.5B-Instruct-Q4_K_M.gguf"
            MODEL_FILE="Qwen2.5-1.5B-Instruct-Q4_K_M.gguf"
            ;;
        4)
            MODEL_URL="https://huggingface.co/bartowski/Phi-3.5-mini-instruct-GGUF/resolve/main/Phi-3.5-mini-instruct-Q4_K_M.gguf"
            MODEL_FILE="Phi-3.5-mini-instruct-Q4_K_M.gguf"
            ;;
        0|*)
            echo ""
            echo -e "${CYAN}No problem! Download any .gguf model and place it in:${NC}"
            echo -e "${GREEN}  /sdcard/AI_Models/${NC}"
            echo -e "${CYAN}Then re-run this script.${NC}"
            echo ""
            echo -e "${GRAY}Recommended sites:${NC}"
            echo "  https://huggingface.co/bartowski"
            echo "  (Look for Q4_K_M quantization files)"
            exit 0
            ;;
    esac

    MODEL_SOURCE="download"
    echo -e "${GREEN}Will download: ${MODEL_FILE}${NC}"
fi

# =========================================================================
# 4. Clone and Build Llama.cpp
# =========================================================================
echo ""
echo -e "${YELLOW}[2/4] Preparing Llama.cpp engine...${NC}"
cd $HOME
if [ ! -d "llama.cpp" ]; then
    git clone https://github.com/ggerganov/llama.cpp
fi

cd llama.cpp
# Only build if llama-server doesn't exist
if [ ! -f "build/bin/llama-server" ]; then
    echo -e "${YELLOW}Compiling engine (First time only — may take 10-30 min)...${NC}"
    rm -rf build
    cmake -B build -GNinja -DLLAMA_BUILD_SERVER=ON -DLLAMA_BUILD_TESTS=OFF
    cmake --build build --config Release --target llama-server
else
    echo -e "${GREEN}Engine already compiled. Skipping...${NC}"
fi

# =========================================================================
# 5. Model Procurement
# =========================================================================
echo ""
echo -e "${YELLOW}[3/4] Procuring AI Model...${NC}"
mkdir -p models

if [ "$MODEL_SOURCE" = "local" ]; then
    # Copy from SD card to llama.cpp/models/
    if [ -f "models/$MODEL_FILE" ]; then
        echo -e "${GREEN}Model already in engine directory. Skipping copy...${NC}"
    else
        echo -e "${YELLOW}Copying model from SD card...${NC}"
        cp "$SELECTED_PATH" "models/$MODEL_FILE"
        echo -e "${GREEN}Done!${NC}"
    fi
else
    # Download the model
    if [ -f "models/$MODEL_FILE" ]; then
        echo -e "${GREEN}Model already downloaded. Skipping...${NC}"
    else
        echo -e "${YELLOW}Downloading model (This may take a while)...${NC}"
        wget -c "$MODEL_URL" -O "models/$MODEL_FILE" || {
            echo -e "${RED}ERROR: Download failed.${NC}"
            echo "Download the model manually and place it in /sdcard/AI_Models/"
            echo "Then re-run this script."
            exit 1
        }
        # Also save a copy to AI_Models for future use on other phones
        cp "models/$MODEL_FILE" "$AI_MODELS_DIR/$MODEL_FILE" 2>/dev/null || true
        echo -e "${GREEN}Download complete! (Copy also saved to /sdcard/AI_Models/)${NC}"
    fi
fi

# =========================================================================
# 6. Create Start Script
# =========================================================================
echo ""
echo -e "${YELLOW}[4/4] Creating startup script...${NC}"
cat << EOF > $HOME/start-ai.sh
#!/data/data/com.termux/files/usr/bin/bash
cd \$HOME/llama.cpp
echo "Starting local AI Server on port 8080..."
echo "Open browser: http://127.0.0.1:8080"
echo "Press Ctrl+C to stop."
./build/bin/llama-server -m models/$MODEL_FILE -c 2048 -t 4 --port 8080
EOF
chmod +x $HOME/start-ai.sh

echo ""
echo -e "${GREEN}=========================================================="
echo -e "   SETUP COMPLETE!"
echo -e "==========================================================${NC}"
echo ""
echo -e "  Model: ${CYAN}${MODEL_FILE}${NC}"
echo -e "  Start: ${YELLOW}bash ~/start-ai.sh${NC}"
echo -e "  Chat:  ${CYAN}http://127.0.0.1:8080${NC}"
echo ""
echo -e "${GRAY}TIP: To switch models, place a new .gguf in /sdcard/AI_Models/"
echo -e "     and re-run this script.${NC}"
echo ""
