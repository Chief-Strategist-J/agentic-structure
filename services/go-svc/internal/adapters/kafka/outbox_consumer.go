package kafka

import (
	"context"
	"time"
)

// OutboxConsumer relays events from the transactional outbox table to Kafka.
type OutboxConsumer struct {
	brokers []string
	topic   string
}

func NewOutboxConsumer(brokers []string, topic string) *OutboxConsumer {
	return &OutboxConsumer{brokers: brokers, topic: topic}
}

func (c *OutboxConsumer) StartRelay(ctx context.Context, pollInterval time.Duration) error {
	// Centralized transactional outbox polling loop
	return nil
}
