# AI 代理程式 for Browser MCP

此目錄包含基於 Python 的 AI 代理程式，設計用於與 Browser MCP (模型內容協議) 伺服器進行互動。此代理程式使用 Google 的 Gemini Pro 模型來處理資訊，並決定在瀏覽器中執行的操作。

## 功能

此代理程式的主要角色是作為瀏覽器自動化的「大腦」。它使用持續的 WebSocket 連線與 Browser MCP 伺服器進行即時通訊。

1.  **連接**：使用 WebSocket 協定 (`ws://`) 連接到 Browser MCP 伺服器。
2.  **接收**：從伺服器接收訊息 (代表瀏覽器上下文或任務)。
3.  **處理**：使用 Google Gemini AI 處理每條訊息，以確定適當的下一步操作。
4.  **傳送**：將 AI 生成的操作作為回應傳送回伺服器。
5.  **監聽**：在一個非同步循環中持續監聽新訊息。

## 設定

在運行代理程式之前，您需要設定您的 Google AI API 金鑰。

1.  **取得 Google AI API 金鑰**：如果您還沒有，可以從 [Google AI Studio](https://aistudio.google.com/app/apikey) 取得。

2.  **設定環境變數**：代理程式從名為 `GOOGLE_API_KEY` 的環境變數中讀取 API 金鑰。您需要在您的終端機工作階段中設定此變數。

    **在 Linux/macOS 上：**
    ```bash
    export GOOGLE_API_KEY="您的API金鑰"
    ```

    **在 Windows (命令提示字元) 上：**
    ```bash
    set GOOGLE_API_KEY="您的API金鑰"
    ```

    **在 Windows (PowerShell) 上：**
    ```powershell
    $env:GOOGLE_API_KEY="您的API金鑰"
    ```

    請將 `"您的API金鑰"` 替換為您實際的 API 金鑰。

## 如何執行

1.  **啟動虛擬環境**：請確保您已啟動您的 Python 虛擬環境。

    ```bash
    source .venv/bin/activate
    ```

2.  **安裝依賴套件**：此代理程式需要額外的 Python 套件。請使用 pip 進行安裝：

    ```bash
    pip install google-generativeai websockets
    ```

3.  **執行代理程式**：導航到專案的根目錄，並執行 `agent` 目錄中的 `main.py` 腳本。

    ```bash
    python agent/main.py
    ```

    如果 MCP 伺服器不在預設位置運行，您也可以指定其位址。請注意，代理程式現在需要一個 WebSocket 位址 (以 `ws://` 開頭)。
    ```bash
    python agent/main.py --mcp_server "ws://您的伺服器位址:埠號"
    ```

## 未來發展

此腳本為 AI 代理程式提供了一個堅實的基礎。未來的增強功能可能包括：

-   **更複雜的提示 (Prompts)**：為 Gemini 模型開發結構化且具備上下文感知能力的提示，以更可靠地處理複雜任務。
-   **錯誤處理**：改進對網路問題和 AI 模型故障的錯誤處理。
-   **狀態管理**：實現一種機制，讓代理程式能夠在多次互動中保持狀態。
-   **設定檔案**：將伺服器位址和模型名稱等設定移至專用的設定檔案中。
