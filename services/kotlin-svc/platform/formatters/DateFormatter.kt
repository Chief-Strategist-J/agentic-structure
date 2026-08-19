package platform.formatters

import java.time.Instant
import java.time.ZoneId
import java.time.format.DateTimeFormatter

object DateFormatter {
    private val isoFormatter = DateTimeFormatter.ISO_LOCAL_DATE.withZone(ZoneId.of("UTC"))

    fun formatDateISO(instant: Instant): String {
        return isoFormatter.format(instant)
    }
}
