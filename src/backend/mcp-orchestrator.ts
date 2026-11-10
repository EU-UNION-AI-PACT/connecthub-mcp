import { spawn } from 'child_process';
import readline from 'readline';

export interface McpToolCallResult {
  tool: string;
  output: any;
  durationMs: number;
}

export class McpOrchestrator {
  public static async executeTool(
    command: string,
    args: string[],
    toolName: string,
    toolArgs: Record<string, any>,
    env: Record<string, string> = {}
  ): Promise<McpToolCallResult> {
    const startTime = Date.now();

    return new Promise((resolve, reject) => {
      const proc = spawn(command, args, {
        stdio: ['pipe', 'pipe', 'pipe'],
        env: { ...process.env, ...env }
      });

      const rl = readline.createInterface({ input: proc.stdout });
      let callResult: any = null;

      const initMessage = {
        jsonrpc: '2.0',
        id: 1,
        method: 'initialize',
        params: {
          protocolVersion: '2024-11-05',
          capabilities: {},
          clientInfo: { name: 'connecthub-orchestrator', version: '1.0.0' }
        }
      };
      proc.stdin.write(JSON.stringify(initMessage) + '\n');

      rl.on('line', (line) => {
        try {
          const msg = JSON.parse(line);
          if (msg.id === 1) {
            proc.stdin.write(JSON.stringify({ jsonrpc: '2.0', method: 'notifications/initialized', params: {} }) + '\n');
            const toolCallReq = {
              jsonrpc: '2.0',
              id: 2,
              method: 'tools/call',
              params: {
                name: toolName,
                arguments: toolArgs
              }
            };
            proc.stdin.write(JSON.stringify(toolCallReq) + '\n');
          } else if (msg.id === 2) {
            callResult = msg.result;
            proc.kill();
            resolve({
              tool: toolName,
              output: callResult,
              durationMs: Date.now() - startTime
            });
          }
        } catch (e) {
          // ignore stream output
        }
      });

      proc.on('error', (err) => reject(err));

      setTimeout(() => {
        proc.kill();
        reject(new Error(`MCP Tool ${toolName} execution timed out (30s)`));
      }, 30000);
    });
  }
}
