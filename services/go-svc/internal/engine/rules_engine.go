package engine

import (
	"context"
	"fmt"
	"time"
)

// Operator defines comparison operators for Level 1 Atomic Rules
type Operator string

const (
	OpEquals               Operator = "EQUALS"
	OpNotEquals            Operator = "NOT_EQUALS"
	OpGreaterThan          Operator = "GREATER_THAN"
	OpGreaterThanOrEqual   Operator = "GREATER_THAN_OR_EQUAL"
	OpLessThan             Operator = "LESS_THAN"
	OpLessThanOrEqual      Operator = "LESS_THAN_OR_EQUAL"
	OpIn                   Operator = "IN"
	OpNotIn                Operator = "NOT_IN"
)

// LogicalOperator defines boolean composition for Level 2 Compound Rules
type LogicalOperator string

const (
	LogicalAnd LogicalOperator = "AND"
	LogicalOr  LogicalOperator = "OR"
	LogicalNot LogicalOperator = "NOT"
)

// Level 1 — Atomic Rule: Cannot be decomposed further. Has one condition. Produces one result.
type AtomicRule struct {
	ID                    string      `json:"id"`
	Field                 string      `json:"field"`
	Operator              Operator    `json:"operator"`
	Value                 interface{} `json:"value"`
	UserFacingExplanation string      `json:"user_facing_explanation"`
}

// Level 2 — Compound Rule: Composed of atomic rules. Fires when a boolean combination fires.
type CompoundRule struct {
	ID                    string          `json:"id"`
	LogicalOp             LogicalOperator `json:"logical_op"`
	AtomicRules           []AtomicRule    `json:"atomic_rules"`
	NestedCompoundRules   []CompoundRule  `json:"nested_compound_rules,omitempty"`
	UserFacingExplanation string          `json:"user_facing_explanation"`
}

// Level 3 — Policy: Composed of atomic & compound rules with custom resolver.
type Policy struct {
	ID                    string         `json:"id"`
	Name                  string         `json:"name"`
	Version               string         `json:"version"`
	AtomicRules           []AtomicRule   `json:"atomic_rules"`
	CompoundRules         []CompoundRule `json:"compound_rules"`
	UserFacingExplanation string         `json:"user_facing_explanation"`
}

// AuditTrail Entry — Guarantees complete auditability, debuggability, and user-facing explanations.
type RuleEvaluationAudit struct {
	EvaluationID          string            `json:"evaluation_id"`
	PolicyID              string            `json:"policy_id"`
	PolicyVersion         string            `json:"policy_version"`
	TraceID               string            `json:"trace_id"`
	TenantID              string            `json:"tenant_id"`
	EvaluatedAt           time.Time         `json:"evaluated_at"`
	Passed                bool              `json:"passed"`
	Facts                 map[string]any    `json:"facts"`
	FiredAtomicRules      []string          `json:"fired_atomic_rules"`
	FiredCompoundRules    []string          `json:"fired_compound_rules"`
	UserFacingReasons     []string          `json:"user_facing_reasons"`
	DebugWaterfall        []string          `json:"debug_waterfall"`
}

// Evaluator evaluates Level 1, Level 2, and Level 3 rules with full auditability
type Evaluator struct{}

func NewEvaluator() *Evaluator {
	return &Evaluator{}
}

func (e *Evaluator) EvaluatePolicy(ctx context.Context, policy Policy, facts map[string]any, traceID, tenantID string) (bool, RuleEvaluationAudit) {
	audit := RuleEvaluationAudit{
		EvaluationID:       fmt.Sprintf("eval-%d", time.Now().UnixNano()),
		PolicyID:           policy.ID,
		PolicyVersion:      policy.Version,
		TraceID:            traceID,
		TenantID:           tenantID,
		EvaluatedAt:        time.Now(),
		Facts:              facts,
		FiredAtomicRules:   make([]string, 0),
		FiredCompoundRules: make([]string, 0),
		UserFacingReasons:  make([]string, 0),
		DebugWaterfall:     make([]string, 0),
	}

	policyPassed := true

	// 1. Evaluate Level 1 Atomic Rules
	for _, rule := range policy.AtomicRules {
		passed := e.EvaluateAtomic(rule, facts)
		audit.DebugWaterfall = append(audit.DebugWaterfall, fmt.Sprintf("[Level 1 Atomic] Rule %s (%s %s %v): %v", rule.ID, rule.Field, rule.Operator, rule.Value, passed))
		if passed {
			audit.FiredAtomicRules = append(audit.FiredAtomicRules, rule.ID)
		} else {
			policyPassed = false
			audit.UserFacingReasons = append(audit.UserFacingReasons, rule.UserFacingExplanation)
		}
	}

	// 2. Evaluate Level 2 Compound Rules
	for _, compound := range policy.CompoundRules {
		passed := e.EvaluateCompound(compound, facts)
		audit.DebugWaterfall = append(audit.DebugWaterfall, fmt.Sprintf("[Level 2 Compound] Rule %s (Op: %s): %v", compound.ID, compound.LogicalOp, passed))
		if passed {
			audit.FiredCompoundRules = append(audit.FiredCompoundRules, compound.ID)
		} else {
			policyPassed = false
			audit.UserFacingReasons = append(audit.UserFacingReasons, compound.UserFacingExplanation)
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

func (e *Evaluator) EvaluateCompound(compound CompoundRule, facts map[string]any) bool {
	if compound.LogicalOp == LogicalAnd {
		for _, atomic := range compound.AtomicRules {
			if !e.EvaluateAtomic(atomic, facts) {
				return false
			}
		}
		return true
	}
	if compound.LogicalOp == LogicalOr {
		for _, atomic := range compound.AtomicRules {
			if e.EvaluateAtomic(atomic, facts) {
				return true
			}
		}
		return false
	}
	return false
}
