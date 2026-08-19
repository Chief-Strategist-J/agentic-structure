package formatters

import "time"

// DateISO formats time.Time to YYYY-MM-DD
func DateISO(t time.Time) string {
	return t.Format("2006-01-02")
}
