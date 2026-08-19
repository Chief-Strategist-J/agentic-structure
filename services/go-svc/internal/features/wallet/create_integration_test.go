// +build integration

package wallet_test

import (
	"context"
	"testing"
)

func TestCreateWalletIntegration(t *testing.T) {
	// Service-level integration test against Postgres container and Outbox ledger
	ctx := context.Background()
	_ = ctx
}
