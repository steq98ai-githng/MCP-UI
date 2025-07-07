import { execSync } from "node:child_process";
import { readFileSync } from "node:fs";
import net from "node:net";

function isWSL2(): boolean {
  try {
    const versionInfo = readFileSync("/proc/version", "utf8");
    return versionInfo.includes("microsoft") && versionInfo.includes("WSL2");
  } catch {
    return false;
  }
}

function killLinuxProcess(port: number): void {
  try {
    execSync(`lsof -ti:${port} | xargs kill -9`, { stdio: "pipe" });
  } catch {
    // Process might not be running on Linux side
  }
}

function killWindowsProcessViaPsh(port: number): void {
  try {
    const command = `powershell.exe "Get-NetTCPConnection -LocalPort ${port} -ErrorAction SilentlyContinue | ForEach-Object { Stop-Process -Id \$_.OwningProcess -Force -ErrorAction SilentlyContinue }"`;
    execSync(command, { stdio: "pipe" });
  } catch {
    // Process might not be running on Windows side
  }
}

function killWSL2Process(port: number): void {
  // In WSL2, processes can run on either Linux or Windows side
  // We need to check both since we don't know which one is actually using the port
  killLinuxProcess(port);
  killWindowsProcessViaPsh(port);
}

function killWindowsProcessViaCmd(port: number): void {
  const command = `FOR /F "tokens=5" %a in ('netstat -ano ^| findstr :${port}') do taskkill /F /PID %a`;
  execSync(command);
}

function killNativeLinuxProcess(port: number): void {
  execSync(`lsof -ti:${port} | xargs kill -9`);
}

export async function isPortInUse(port: number): Promise<boolean> {
  return new Promise((resolve) => {
    const server = net.createServer();

    server.once("error", () => {
      resolve(true); // Port is in use
    });

    server.once("listening", () => {
      server.close(() => {
        resolve(false); // Port is free
      });
    });

    server.listen(port);
  });
}

export function killProcessOnPort(port: number): void {
  try {
    if (isWSL2()) {
      killWSL2Process(port);
    } else if (process.platform === "win32") {
      killWindowsProcessViaCmd(port);
    } else {
      killNativeLinuxProcess(port);
    }
  } catch (error) {
    console.error(`Failed to kill process on port ${port}:`, error);
  }
}
