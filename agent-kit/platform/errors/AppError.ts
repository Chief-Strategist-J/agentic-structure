export type ErrorCode =
  | "VALIDATION_FAILED"
  | "ENTITY_NOT_FOUND"
  | "UNAUTHORIZED"
  | "FORBIDDEN"
  | "CONFLICT"
  | "IDEMPOTENCY_CONFLICT"
  | "PRECONDITION_FAILED"
  | "INTERNAL_ERROR";

export interface FieldError {
  field: string;
  code: string;
  message: string;
}

export class AppError extends Error {
  readonly code: ErrorCode;
  readonly httpStatus: number;
  readonly fieldErrors: readonly FieldError[];

  constructor(
    code: ErrorCode,
    message: string,
    httpStatus = 500,
    fieldErrors: readonly FieldError[] = []
  ) {
    super(message);
    this.name = "AppError";
    this.code = code;
    this.httpStatus = httpStatus;
    this.fieldErrors = Object.freeze([...fieldErrors]);
  }

  static validation(fieldErrors: readonly FieldError[]): AppError {
    return new AppError(
      "VALIDATION_FAILED",
      "Input validation failed",
      400,
      fieldErrors
    );
  }

  static notFound(resource: string, id: string): AppError {
    return new AppError(
      "ENTITY_NOT_FOUND",
      `${resource} '${id}' not found`,
      404
    );
  }

  static idempotencyConflict(key: string): AppError {
    return new AppError(
      "IDEMPOTENCY_CONFLICT",
      `Concurrent or conflicting operation with idempotency key '${key}'`,
      409
    );
  }
}
