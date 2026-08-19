package adapters.kafka

import java.time.Duration

class OutboxConsumer(
    private val brokers: List<String>,
    private val defaultTopic: String
) {
    fun startRelay(pollInterval: Duration) {
        // Centralized Kotlin outbox polling loop
    }
}
