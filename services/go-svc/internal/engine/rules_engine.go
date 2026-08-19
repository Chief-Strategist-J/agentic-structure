package engine

import (
	"context"
	"fmt"
	"time"
)

type OutputType string

const (
	OutputTypeScore OutputType = "score"
	OutputTypeFlag  OutputType = "flag"
	OutputTypeLabel OutputType = "label"
	OutputTypeValue OutputType = "value"
	OutputTypeEvent OutputType = "event"
)

type Operator string

const (
	OpEquals             Operator = "EQUALS"
	OpNotEquals          Operator = "NOT_EQUALS"
	OpGreaterThan        Operator = "GREATER_THAN"
	OpGreaterThanOrEqual Operator = "GREATER_THAN_OR_EQUAL"
	OpLessThan           Operator = "LESS_THAN"
	OpLessThanOrEqual    Operator = "LESS_THAN_OR_EQUAL"
	OpIn                 Operator = "IN"
	OpNotIn              Operator = "NOT_IN"
)

type LogicalOperator string

const (
	LogicalAnd LogicalOperator = "AND"
	LogicalOr  LogicalOperator = "OR"
	LogicalNot LogicalOperator = "NOT"
)

// Level 1 — Atomic Rule with Complete Metadata & Lifecycle
type AtomicRule struct {
	// Identity
	ID      string `json:"id"`
	Version int    `json:"version"`
	Name    string `json:"name"`

	// Ownership
	Owner     string `json:"owner"`
	Domain    string `json:"domain"`
	Rationale string `json:"rationale"`

	// Lifecycle
	ActiveFrom *time.Time `json:"active_from,omitempty"`
	ActiveTo   *time.Time `json:"active_to,omitempty"`
	Enabled    bool       `json:"enabled"`

	// Evaluation
	Field    string   `json:"field"`
	Operator Operator `json:"operator"`
	Value    any      `json:"value"`
	Priority int      `json:"priority"`

	// Output
	OutputKey             string     `json:"output_key"`
	OutputType            OutputType `json:"output_type"`
	Weight                float64    `json:"weight"`
	UserFacingExplanation string     `json:"user_facing_explanation"`
}

// Level 2 — Compound Rule
type CompoundRule struct {
	ID                    string          `json:"id"`
	Version               int             `json:"version"`
	Name                  string          `json:"name"`
	Owner                 string          `json:"owner"`
	Domain                string          `json:"domain"`
	Rationale             string          `json:"rationale"`
	Enabled               bool            `json:"enabled"`
	LogicalOp             LogicalOperator `json:"logical_op"`
	AtomicRules           []AtomicRule    `json:"atomic_rules"`
	Priority              int             `json:"priority"`
	OutputKey             string          `json:"output_key"`
	OutputType            OutputType      `json:"output_type"`
	Weight                float64         `json:"weight"`
	UserFacingExplanation string          `json:"user_facing_explanation"`
}

// Level 3 — Policy
type Policy struct {
	ID                    string         `json:"id"`
	Name                  string         `json:"name"`
	Version               int            `json:"version"`
	Owner                 string         `json:"owner"`
	Domain                string         `json:"domain"`
	Rationale             string         `json:"rationale"`
	AtomicRules           []AtomicRule   `json:"atomic_rules"`
	CompoundRules         []CompoundRule `json:"compound_rules"`
	UserFacingExplanation string         `json:"user_facing_explanation"`
}

type RuleEvaluationAudit struct {
	EvaluationID       string         `json:"evaluation_id"`
	PolicyID           string         `json:"policy_id"`
	PolicyVersion      int            `json:"policy_version"`
	TraceID            string         `json:"trace_id"`
	TenantID           string         `json:"tenant_id"`
	EvaluatedAt        time.Time      `json:"evaluated_at"`
	Passed             bool           `json:"passed"`
	Facts              map[string]any `json:"facts"`
	FiredAtomicRules   []string       `json:"fired_atomic_rules"`
	FiredCompoundRules []string       `json:"fired_compound_rules"`
	UserFacingReasons  []string       `json:"user_facing_reasons"`
	DebugWaterfall     []string       `json:"debug_waterfall"`
}

type Evaluator struct{}

func NewEvaluator() *Evaluator {
	return &Evaluator{}
}

func (e *Evaluator) EvaluatePolicy(ctx context.Context, policy Policy, facts map[string]any, traceID, tenantID string) (bool, RuleEvaluationAudit) {
	now := time.Now()
	audit := RuleEvaluationAudit{
		EvaluationID:       fmt.Sprintf("eval-%d", now.UnixNano()),
		PolicyID:           policy.ID,
		PolicyVersion:      policy.Version,
		TraceID:            traceID,
		TenantID:           tenantID,
		EvaluatedAt:        now,
		Facts:              facts,
		FiredAtomicRules:   make([]string, 0),
		FiredCompoundRules: make([]string, 0),
		UserFacingReasons:  make([]string, 0),
		DebugWaterfall:     make([]string, 0),
	}

	policyPassed := true

	// Evaluate Atomic Rules
	for _, rule := range policy.AtomicRules {
		if !rule.Enabled {
			audit.DebugWaterfall = append(audit.DebugWaterfall, fmt.Sprintf("[Level 1 Atomic] Rule %s skipped (disabled)", rule.ID))
			continue
		}
		if rule.ActiveFrom != nil && now.Before(*rule.ActiveFrom) {
			audit.DebugWaterfall = append(audit.DebugWaterfall, fmt.Sprintf("[Level 1 Atomic] Rule %s skipped (not active yet)", rule.ID))
			continue
		}
		if rule.ActiveTo != nil && now.After(*rule.ActiveTo) {
			audit.DebugWaterfall = append(audit.DebugWaterfall, fmt.Sprintf("[Level 1 Atomic] Rule %s skipped (expired)", rule.ID))
			continue
		}

		passed := e.EvaluateAtomic(rule, facts)
		audit.DebugWaterfall = append(audit.DebugWaterfall, fmt.Sprintf("[Level 1 Atomic] Rule %s (Priority: %d, Weight: %.2f, %s %s %v): %v", rule.ID, rule.Priority, rule.Weight, rule.Field, rule.Operator, rule.Value, passed))
		if passed {
			audit.FiredAtomicRules = append(audit.FiredAtomicRules, rule.ID)
		} else {
			policyPassed = false
			audit.UserFacingReasons = append(audit.UserFacingReasons, rule.UserFacingExplanation)
		}
	}

	audit.Passed = policyPassed
	return policyPassed, audit
}

func (e *Evaluator) EvaluateAtomic(rule AtomicRule, facts map[string]any) bool {
	factVal, exists := facts[rule.Field]
	if !exists {
		return false
	}
	return fmt.Sprintf("%v", factVal) == fmt.Sprintf("%v", rule.Value)
}
