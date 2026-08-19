/**
 * 3-Level Rules Engine Architecture (TypeScript)
 * Level 1 — Atomic Rule: Single condition, single result.
 * Level 2 — Compound Rule: Boolean combination (AND/OR/NOT) of Atomic Rules.
 * Level 3 — Policy: Policy composed of Level 1 & Level 2 with custom resolver.
 *
 * Mandatory engine attributes:
 * - Full auditability
 * - Debuggability waterfall
 * - User-facing explanations
 */

export type Operator =
  | 'EQUALS'
  | 'NOT_EQUALS'
  | 'GREATER_THAN'
  | 'GREATER_THAN_OR_EQUAL'
  | 'LESS_THAN'
  | 'LESS_THAN_OR_EQUAL'
  | 'IN'
  | 'NOT_IN';

export type LogicalOperator = 'AND' | 'OR' | 'NOT';

/** Level 1 — Atomic rule */
export interface AtomicRule {
  id: string;
  field: string;
  operator: Operator;
  value: unknown;
  userFacingExplanation: string;
}

/** Level 2 — Compound rule */
export interface CompoundRule {
  id: string;
  logicalOp: LogicalOperator;
  atomicRules: AtomicRule[];
  nestedCompoundRules?: CompoundRule[];
  userFacingExplanation: string;
}

/** Level 3 — Policy */
export interface Policy {
  id: string;
  name: string;
  version: string;
  atomicRules: AtomicRule[];
  compoundRules: CompoundRule[];
  userFacingExplanation: string;
}

export interface RuleEvaluationAudit {
  evaluationId: string;
  policyId: string;
  policyVersion: string;
  traceId: string;
  tenantId: string;
  evaluatedAt: string;
  passed: boolean;
  facts: Record<string, unknown>;
  firedAtomicRules: string[];
  firedCompoundRules: string[];
  userFacingReasons: string[];
  debugWaterfall: string[];
}

export class RulesEvaluator {
  evaluatePolicy(
    policy: Policy,
    facts: Record<string, unknown>,
    traceId: string,
    tenantId: string
  ): { passed: boolean; audit: RuleEvaluationAudit } {
    const audit: RuleEvaluationAudit = {
      evaluationId: `eval-${Date.now()}-${Math.random().toString(36).substr(2, 5)}`,
      policyId: policy.id,
      policyVersion: policy.version,
      traceId,
      tenantId,
      evaluatedAt: new Date().toISOString(),
      passed: true,
      facts,
      firedAtomicRules: [],
      firedCompoundRules: [],
      userFacingReasons: [],
      debugWaterfall: [],
    };

    let policyPassed = true;

    // 1. Evaluate Level 1 Atomic Rules
    for (const rule of policy.atomicRules) {
      const passed = this.evaluateAtomic(rule, facts);
      audit.debugWaterfall.push(
        `[Level 1 Atomic] Rule ${rule.id} (${rule.field} ${rule.operator} ${JSON.stringify(rule.value)}): ${passed}`
      );
      if (passed) {
        audit.firedAtomicRules.push(rule.id);
      } else {
        policyPassed = false;
        audit.userFacingReasons.push(rule.userFacingExplanation);
      }
    }

    // 2. Evaluate Level 2 Compound Rules
    for (const compound of policy.compoundRules) {
      const passed = this.evaluateCompound(compound, facts);
      audit.debugWaterfall.push(
        `[Level 2 Compound] Rule ${compound.id} (Op: ${compound.logicalOp}): ${passed}`
      );
      if (passed) {
        audit.firedCompoundRules.push(compound.id);
      } else {
        policyPassed = false;
        audit.userFacingReasons.push(compound.userFacingExplanation);
      }
    }

    audit.passed = policyPassed;
    return { passed: policyPassed, audit };
  }

  evaluateAtomic(rule: AtomicRule, facts: Record<string, unknown>): boolean {
    const val = facts[rule.field];
    if (val === undefined || val === null) return false;
    return String(val) === String(rule.value);
  }

  evaluateCompound(compound: CompoundRule, facts: Record<string, unknown>): boolean {
    if (compound.logicalOp === 'AND') {
      return compound.atomicRules.every((r) => this.evaluateAtomic(r, facts));
    }
    if (compound.logicalOp === 'OR') {
      return compound.atomicRules.some((r) => this.evaluateAtomic(r, facts));
    }
    return false;
  }
}
