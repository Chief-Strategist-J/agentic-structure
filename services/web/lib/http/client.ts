import { AppError } from "../errors/AppError";

export interface RequestContext {
  traceId: string;
  requestId: string;
  tenantId: string;
  actorId?: string;
  idempotencyKey?: string;
  deadlineMs?: number;
}

export interface HttpClientConfig {
  baseUrl: string;
  timeoutMs: number;
}

export class HttpClient {
  constructor(private readonly config: HttpClientConfig) {}

  async request<T>(
    method: "GET" | "POST" | "PUT" | "PATCH" | "DELETE",
    path: string,
    ctx: RequestContext,
    body?: unknown,
    options?: { ifMatch?: string }
  ): Promise<T> {
    const controller = new AbortController();
    const timeout = ctx.deadlineMs ?? this.config.timeoutMs;
    const timeoutId = setTimeout(() => controller.abort(), timeout);

    const headers: Record<string, string> = {
      "Content-Type": "application/json",
      "traceparent": `00-${ctx.traceId}-0000000000000000-01`,
      "X-Request-ID": ctx.requestId,
      "X-Tenant-ID": ctx.tenantId,
    };

    if (ctx.actorId) headers["X-Actor-ID"] = ctx.actorId;
    if (ctx.idempotencyKey) headers["Idempotency-Key"] = ctx.idempotencyKey;
    if (options?.ifMatch) headers["If-Match"] = options.ifMatch;

    try {
      const response = await fetch(`${this.config.baseUrl}${path}`, {
        method,
        headers,
        body: body ? JSON.stringify(body) : undefined,
        signal: controller.signal, // with explicit AbortSignal timeout
      });

      clearTimeout(timeoutId);

      if (!response.ok) {
        throw new AppError(
          "INTERNAL_ERROR",
          `HTTP ${method} ${path} failed with status ${response.status}`,
          response.status
        );
      }

      if (response.status === 204) return undefined as T;
      return (await response.json()) as T;
    } catch (err: unknown) {
      clearTimeout(timeoutId);
      if (err instanceof Error && err.name === "AbortError") {
        throw new AppError("INTERNAL_ERROR", `Request timed out after ${timeout}ms`, 504);
      }
      throw err;
    }
  }
}
