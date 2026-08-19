package platform.fp

import arrow.core.Either
import arrow.core.NonEmptyList

/**
 * Functional validation helpers for Kotlin.
 */
typealias ValidationResult<T> = Either<NonEmptyList<String>, T>
