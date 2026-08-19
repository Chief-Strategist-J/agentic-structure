package errors

import "fmt"

type ErrorCode string

const (
	CodeValidationFailed    ErrorCode = "VALIDATION_FAILED"
	CodeEntityNotFound      ErrorCode = "ENTITY_NOT_FOUND"
	CodeUnauthorized        ErrorCode = "UNAUTHORIZED"
	CodeForbidden           ErrorCode = "FORBIDDEN"
	CodeConflict            ErrorCode = "CONFLICT"
	CodeIdempotencyConflict ErrorCode = "IDEMPOTENCY_CONFLICT"
	CodePreconditionFailed  ErrorCode = "PRECONDITION_FAILED"
	CodeInternalError       ErrorCode = "INTERNAL_ERROR"
)

type FieldError struct {
	Field   string `json:"field"`
	Code    string `json:"code"`
	Message string `json:"message"`
}

type AppError struct {
	Code        ErrorCode    `json:"code"`
	Message     string       `json:"message"`
	HTTPStatus  int          `json:"http_status"`
	FieldErrors []FieldError `json:"field_errors,omitempty"`
}

func (e *AppError) Error() string {
	return fmt.Sprintf("[%s] %s (status: %d)", e.Code, e.Message, e.HTTPStatus)
}

func NewValidationError(fieldErrors []FieldError) *AppError {
	return &AppError{
		Code:        CodeValidationFailed,
		Message:     "Input validation failed",
		HTTPStatus:  400,
		FieldErrors: fieldErrors,
	}
}

func NewNotFoundError(resource, id string) *AppError {
	return &AppError{
		Code:       CodeEntityNotFound,
		Message:    fmt.Sprintf("%s '%s' not found", resource, id),
		HTTPStatus: 404,
	}
}
