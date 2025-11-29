# RunPod V-GPU 遠端桌面 (VNC) 一鍵部署方案

這份指南包含了在 RunPod 伺服器上設定 VNC 遠端桌面，並透過 SSH 隧道從本地連線的所有步驟。

---

### 1. [RunPod 端] 一鍵安裝腳本程式碼

在您的 RunPod 終端機中，建立一個名為 `setup_vnc_lada.sh` 的檔案，並貼上以下內容。

```bash
#!/bin/bash

# Part 1: System Update and GUI/VNC Installation
echo "=================================================="
echo "Updating package list and installing desktop environment..."
echo "=================================================="
export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install -y xfce4 xfce4-goodies terminator tigervnc-standalone-server --no-install-recommends

# Part 2: VNC Password Configuration
echo "=================================================="
echo "Configuring VNC Server..."
echo "=================================================="
mkdir -p ~/.vnc
echo "Please enter a VNC password (at least 6 characters)."
vncpasswd

# Part 3: VNC Startup Configuration
echo "=================================================="
echo "Setting up VNC startup script..."
echo "=================================================="
cat << 'EOF' > ~/.vnc/xstartup
#!/bin/bash
xrdb $HOME/.Xresources
startxfce4 &
EOF

chmod +x ~/.vnc/xstartup

# Part 4: Start VNC Server
echo "=================================================="
echo "Starting VNC Server on port 5901..."
echo "=================================================="
# Kill any existing VNC server sessions to prevent conflicts
vncserver -kill :1 &> /dev/null
# Start a new VNC server session on display :1 (port 5901), listening on localhost only for security
vncserver :1 -geometry 1920x1080 -depth 24

# Part 5: Create Lada Startup Shortcut
echo "=================================================="
echo "Creating Lada startup shortcut..."
echo "=================================================="
LADA_DIR="/workspace/lada-v0.8.2"
START_LADA_SCRIPT="/workspace/start_lada.sh"

cat << EOF > $START_LADA_SCRIPT
#!/bin/bash
echo "Changing directory to $LADA_DIR"
cd "$LADA_DIR" || { echo "Directory not found: $LADA_DIR"; exit 1; }

# Automatically find the GUI startup file (prioritize .sh, then .py)
GUI_EXECUTABLE=""
if [ -f "gui.sh" ]; then
    GUI_EXECUTABLE="./gui.sh"
elif [ -f "main.py" ]; then
    GUI_EXECUTABLE="python3 main.py"
elif [ $(find . -maxdepth 1 -type f -name "*.sh" | wc -l) -eq 1 ]; then
    GUI_EXECUTABLE=$(find . -maxdepth 1 -type f -name "*.sh")
elif [ $(find . -maxdepth 1 -type f -name "*.py" | wc -l) -eq 1 ]; then
    GUI_EXECUTABLE="python3 \$(find . -maxdepth 1 -type f -name "*.py")"
else
    echo "Could not automatically find a unique startup script (.sh or .py) in $LADA_DIR"
    exit 1
fi

echo "Executing Lada: \$GUI_EXECUTABLE"
\$GUI_EXECUTABLE
EOF

chmod +x $START_LADA_SCRIPT

echo "=================================================="
echo "Setup Complete!"
echo "You can now connect your VNC client."
echo "Inside the VNC desktop, open a terminal and run:"
echo "bash /workspace/start_lada.sh"
echo "=================================================="
```
**執行方式：**
1.  `chmod +x setup_vnc_lada.sh`
2.  `./setup_vnc_lada.sh`
3.  依照提示輸入 VNC 密碼。

---

### 2. [本地端] SSH 隧道連線指令

在您的**本地電腦**上開啟終端機，執行以下指令以建立連線隧道。

**請將 `[RUNPOD_IP]` 和 `[RUNPOD_PORT]` 替換為您 RunPod 頁面上的實際資訊。**

```bash
ssh -N -L 5901:localhost:5901 -p [RUNPOD_PORT] root@[RUNPOD_IP]
```
**範例 (根據您提供的截圖):**
```bash
ssh -N -L 5901:localhost:5901 -p 48701 root@195.26.233.100
```

**操作說明：**
1.  執行後保持此終端機視窗開啟。
2.  打開 VNC 客戶端，連線至 `localhost:5901`。
3.  輸入您在 RunPod 上設定的 VNC 密碼。

---

### 3. [VNC 內] 啟動 Lada 模型的指令

成功登入遠端桌面後，開啟終端機 (`Terminator`)，並執行以下指令。

```bash
bash /workspace/start_lada.sh
```
此指令會自動進入 Lada 目錄並啟動其圖形介面。
