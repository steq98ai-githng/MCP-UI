import { zodToJsonSchema } from "zod-to-json-schema";
import { z } from "zod";

import { GetConsoleLogsTool } from "@repo/types/mcp/tool";

import { Tool } from "./tool";

export const getConsoleLogs: Tool = {
  schema: {
    name: GetConsoleLogsTool.shape.name.value,
    description: GetConsoleLogsTool.shape.description.value,
    inputSchema: zodToJsonSchema(GetConsoleLogsTool.shape.arguments),
  },
  handle: async (context, _params) => {
    const consoleLogs = await context.sendSocketMessage(
      "browser_get_console_logs",
      {},
    );
    const text: string = consoleLogs
      .map((log) => JSON.stringify(log))
      .join("\n");
    return {
      content: [{ type: "text", text }],
    };
  },
};

// Enhanced Screenshot Tool schema with fullPage support
const ScreenshotToolArgs = z.object({
  fullPage: z.boolean().optional().describe("Whether to capture the full page or just the viewport"),
});

export const screenshot: Tool = {
  schema: {
    name: "screenshot",
    description: "Take a screenshot of the current page. Supports both viewport and full page capture.",
    inputSchema: zodToJsonSchema(ScreenshotToolArgs),
  },
  handle: async (context, params) => {
    // Parse and validate parameters
    const validatedParams = ScreenshotToolArgs.parse(params || {});
    
    // Pass fullPage parameter to browser extension
    const screenshot = await context.sendSocketMessage(
      "browser_screenshot",
      validatedParams,
    );
    return {
      content: [
        {
          type: "image",
          data: screenshot,
          mimeType: "image/png",
        },
      ],
    };
  },
};