# 🤖 Termux-LLM-Local-Android

Run uncensored AI models locally on your Android phone. One-script setup via Termux + llama.cpp. **No root, no cloud, no internet needed** after setup.

## ⚡ How It Works

```
📱 Browser (127.0.0.1:8080)  ← You chat here
       ↕
🌐 llama-server (HTTP API)   ← Serves chat UI + OpenAI API
       ↕
🧠 llama.cpp (C++ Engine)    ← Runs the AI on your CPU
       ↕
📦 GGUF Model File           ← The AI's brain
       ↕
🐧 Termux (Linux on Android) ← Real Linux environment
```

Everything runs **100% on-device**. Your conversations never leave your phone.

## 🚀 Quick Start

### 1. Install Termux
Download **Termux** from [F-Droid](https://f-droid.org/en/packages/com.termux/) (recommended) or the Play Store.

### 2. Download a Model
Download any `.gguf` model file and place it in your phone's storage:
```
/sdcard/AI_Models/
```

https://huggingface.co/bartowski

Create the `AI_Models` folder if it doesn't exist. The script will auto-detect all `.gguf` files in this folder.

### 3. Run the Installer
Open Termux and paste:
```bash
curl -fsSL https://raw.githubusercontent.com/orailnoor/termux-llm/main/install.sh -o ~/install.sh && bash ~/install.sh
```

Or if you downloaded the script manually:
```bash
cp /sdcard/install.sh ~ && bash ~/install.sh
```

### 4. Start Your AI
After setup completes, start the server anytime with:
```bash
bash ~/start-ai.sh
```

Then open your browser and go to: **http://127.0.0.1:8080**

## 📦 Recommended Models

If no models are found in `/sdcard/AI_Models/`, the script offers these ungated downloads:

| Model | Size | Type | Best For |
|-------|------|------|----------|
| **Gemma-2-2B-Abliterated** | 1.6 GB | 🔓 Abliterated | Permanently uncensored, very smart |
| **SmolLM2-1.7B-Uncensored** | 1.0 GB | 🔓 Uncensored | Ultra lightweight |
| **Qwen2.5-1.5B-Instruct** | 1.1 GB | 🔒 Standard | Great multilingual support |
| **Phi-3.5-Mini-3.8B** | 2.2 GB | 🔒 Standard | Strong reasoning |

> **💡 Tip:** Search [bartowski on HuggingFace](https://huggingface.co/bartowski) for more models. Always choose **Q4_K_M** quantization for the best balance of quality and speed on phones.

### 🔓 Uncensored vs Abliterated
- **Uncensored (fine-tuned):** Trained to not refuse, but may revert after long conversations.
- **Abliterated:** Refusal neurons surgically removed from the model weights. **Cannot** censor, ever. This is the recommended type.

## 📱 Supported Devices

| RAM | Recommended Model Size |
|-----|----------------------|
| 3-4 GB | Up to 1B models |
| 4-6 GB | Up to 2B models |
| 6-8 GB | Up to 3B models |
| 8+ GB | Up to 8B models |

**Performance:** Expect ~2-10 tokens/second depending on your processor and model size.

## 🔁 Switching Models

1. Download a new `.gguf` model
2. Place it in `/sdcard/AI_Models/`
3. Re-run the installer:
   ```bash
   bash ~/install.sh
   ```
4. Select the new model from the list

The engine won't recompile — it only downloads/copies the new model.

## 🔧 Connecting External Apps

The server exposes an **OpenAI-compatible API** at:
```
http://127.0.0.1:8080/v1
```

You can connect apps like **SillyTavern**, **Open WebUI**, or any OpenAI-compatible client by pointing them to this URL.

## 🐞 Troubleshooting

| Issue | Fix |
|-------|-----|
| `pkg update` fails | Run `termux-change-repo` and pick a mirror |
| Model download 401 error | Model is "gated" — download it in your browser instead |
| Phone gets very hot | Use a smaller model or reduce threads: edit `start-ai.sh` and change `-t 4` to `-t 2` |
| Out of memory crash | Close all other apps, use a smaller model |
| Server won't start | Make sure no other app is using port 8080 |

## 📜 License

MIT License — See [LICENSE](LICENSE) for details.

---

**If you found this useful, consider subscribing to [orailnoor on YouTube](https://youtube.com/@orailnoor)!**
