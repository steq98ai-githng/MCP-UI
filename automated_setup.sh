#!/bin/bash

# Part 0: Password Argument Check
if [ -z "$1" ]; then
    echo "Error: VNC password not provided."
    echo "Usage: sudo ./automated_setup.sh <your-desired-password>"
    exit 1
fi

VNC_PASSWORD="$1"

# Part 1: System Update and GUI/VNC Installation (Final)
echo "=================================================="
echo "Updating package list and installing all desktop dependencies..."
echo "=================================================="
export DEBIAN_FRONTEND=noninteractive
apt-get update -y
# Add dbus-x11 to the installation list to fix desktop environment
apt-get install -y xfce4 xfce4-goodies terminator tigervnc-standalone-server tigervnc-tools expect dbus-x11 --no-install-recommends

# Part 2: VNC Password Configuration (Automated for root)
echo "=================================================="
echo "Configuring VNC Server for the root user..."
echo "=================================================="
mkdir -p /root/.vnc
/usr/bin/expect <<EOF
spawn /usr/bin/vncpasswd
expect "Password:"
send "${VNC_PASSWORD}\r"
expect "Verify:"
send "${VNC_PASSWORD}\r"
expect "Would you like to enter a view-only password (y/n)?"
send "n\r"
expect eof
EOF

# Part 3: VNC Startup Configuration (Corrected)
echo "=================================================="
echo "Setting up corrected VNC startup script for root..."
echo "=================================================="
cat << 'EOF' > /root/.vnc/xstartup
#!/bin/sh
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
# Start XFCE4 in the foreground
/usr/bin/startxfce4
EOF

chmod +x /root/.vnc/xstartup

# Part 4: Start VNC Server
echo "=================================================="
echo "Starting VNC Server on port 5901..."
echo "=================================================="
# Kill any existing VNC server sessions to prevent conflicts
vncserver -kill :1 &> /dev/null
# Start a new VNC server session on display :1 (port 5901)
vncserver :1 -geometry 1920x1080 -depth 24

# Part 5: Create Lada Startup Shortcut
echo "=================================================="
echo "Creating Lada startup shortcut in /workspace/start_lada.sh..."
echo "=================================================="
LADA_DIR="/workspace/lada-v0.8.2"
START_LADA_SCRIPT="/workspace/start_lada.sh"

cat << EOF > $START_LADA_SCRIPT
#!/bin/bash
echo "Changing directory to $LADA_DIR..."
cd "$LADA_DIR" || { echo "Error: Directory not found: $LADA_DIR"; exit 1; }

# Automatically find the GUI startup file
GUI_EXECUTABLE=""
if [ -f "gui.sh" ]; then
    GUI_EXECUTABLE="./gui.sh"
elif [ -f "main.py" ]; then
    GUI_EXECUTABLE="python3 main.py"
else
    echo "Error: Could not automatically find a startup script (gui.sh or main.py) in $LADA_DIR"
    exit 1
fi

echo "Executing Lada: \$GUI_EXECUTABLE"
\$GUI_EXECUTABLE
EOF

chmod +x $START_LADA_SCRIPT
echo "Shortcut created."

# Part 6: Verification
echo "=================================================="
echo "Pausing for 5 seconds to let the server initialize..."
sleep 5
echo "Checking VNC server status and logs:"
vncserver -list
echo "=================== Log File ==================="
tail -n 20 /root/.vnc/*.log
echo "=============================================="
echo "AUTOMATED SETUP COMPLETE!"
echo "If the log shows no critical errors and the server is listed, the setup is successful."
echo "=============================================="
