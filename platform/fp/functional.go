package fp

// Map applies fn to each element of slice and returns the result.
func Map[T, U any](s []T, fn func(T) U) []U {
	res := make([]U, len(s))
	for i, v := range s {
		res[i] = fn(v)
	}
	return res
}

// Filter returns elements of slice that satisfy the predicate.
func Filter[T any](s []T, pred func(T) bool) []T {
	var res []T
	for _, v := range s {
		if pred(v) {
			res = append(res, v)
		}
	}
	return res
}

// Reduce accumulates slice elements into an initial value using fn.
func Reduce[T, U any](s []T, init U, fn func(U, T) U) U {
	acc := init
	for _, v := range s {
		acc = fn(acc, v)
	}
	return acc
}

// GroupBy groups slice elements by key.
func GroupBy[T any, K comparable](s []T, keyFn func(T) K) map[K][]T {
	res := make(map[K][]T)
	for _, v := range s {
		k := keyFn(v)
		res[k] = append(res[k], v)
	}
	return res
}

// Partition splits slice into two slices based on predicate (matching, non-matching).
func Partition[T any](s []T, pred func(T) bool) ([]T, []T) {
	var yes, no []T
	for _, v := range s {
		if pred(v) {
			yes = append(yes, v)
		} else {
			no = append(no, v)
		}
	}
	return yes, no
}

// Pair represents a 2-tuple.
type Pair[A, B any] struct {
	First  A
	Second B
}

// Zip combines two slices into a slice of pairs.
func Zip[A, B any](a []A, b []B) []Pair[A, B] {
	minLen := len(a)
	if len(b) < minLen {
		minLen = len(b)
	}
	res := make([]Pair[A, B], minLen)
	for i := 0; i < minLen; i++ {
		res[i] = Pair[A, B]{First: a[i], Second: b[i]}
	}
	return res
}
