package platform.errors

data class AppError(
    val code: String,
    val message: String,
    val httpStatus: Int = 500
)
