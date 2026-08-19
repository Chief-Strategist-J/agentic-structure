/**
 * 3-Level Rules Engine Architecture with Full Metadata, Provenance, Change Tracking & Operational Attributes
 * (TypeScript implementation for Next.js Web Application)
 */

export type OutputType = 'score' | 'flag' | 'label' | 'value' | 'event';
export type Operator = 'EQUALS' | 'NOT_EQUALS' | 'GREATER_THAN' | 'GREATER_THAN_OR_EQUAL' | 'LESS_THAN' | 'LESS_THAN_OR_EQUAL' | 'IN' | 'NOT_IN';
export type LogicalOperator = 'AND' | 'OR' | 'NOT';

export interface AtomicRule {
  // Identity
  id: string;
  version: number;
  name: string;

  // Ownership
  owner: string;
  domain: string;
  rationale: string; // Strong rationale why this rule exists

  // Lifecycle
  activeFrom?: string; // ISO timestamp
  activeTo?: string;   // ISO timestamp
  enabled: boolean;

  // Evaluation
  field: string;
  operator: Operator;
  value: unknown;
  priority: number;
  weight: number;
  conditionName?: string;
  computationName?: string;

  // Output
  outputKey: string;
  outputType: OutputType;
  userFacingExplanation: string;

  // Provenance
  createdAt: string;
  createdBy: string;
  updatedAt: string;
  updatedBy: string;
  source?: string;

  // Change tracking
  supersedes?: string;
  changeReason?: string;

  // Operational & Evaluation Metadata
  tags: string[];
  timeoutMs?: number;
  deterministic: boolean;
}

export interface CompoundRule {
  id: string;
  version: number;
  name: string;
  owner: string;
  domain: string;
  rationale: string;
  enabled: boolean;
  logicalOp: LogicalOperator;
  atomicRules: AtomicRule[];
  priority: number;
  outputKey: string;
  outputType: OutputType;
  weight: number;
  userFacingExplanation: string;
}

export interface Policy {
  id: string;
  name: string;
  version: number;
  owner: string;
  domain: string;
  rationale: string;
  atomicRules: AtomicRule[];
  compoundRules: CompoundRule[];
  userFacingExplanation: string;
}

export interface RuleEvaluationAudit {
  evaluationId: string;
  policyId: string;
  policyVersion: number;
  traceId: string;
  tenantId: string;
  evaluatedAt: string;
  passed: boolean;
  facts: Record<string, unknown>;
  firedAtomicRules: string[];
  firedCompoundRules: string[];
  userFacingReasons: string[];
  debugWaterfall: string[];
  ruleRationales: Record<string, string>;
}

export class RulesEvaluator {
  evaluatePolicy(
    policy: Policy,
    facts: Record<string, unknown>,
    traceId: string,
    tenantId: string
  ): { passed: boolean; audit: RuleEvaluationAudit } {
    const now = new Date();
    const audit: RuleEvaluationAudit = {
      evaluationId: `eval-${Date.now()}-${Math.random().toString(36).substr(2, 5)}`,
      policyId: policy.id,
      policyVersion: policy.version,
      traceId,
      tenantId,
      evaluatedAt: now.toISOString(),
      passed: true,
      facts,
      firedAtomicRules: [],
      firedCompoundRules: [],
      userFacingReasons: [],
      debugWaterfall: [],
      ruleRationales: {},
    };

    let policyPassed = true;

    for (const rule of policy.atomicRules) {
      audit.ruleRationales[rule.id] = rule.rationale;

      if (!rule.enabled) {
        audit.debugWaterfall.push(`[Level 1 Atomic] Rule ${rule.id} (ver:${rule.version}) skipped (disabled)`);
        continue;
      }
      if (rule.activeFrom && now < new Date(rule.activeFrom)) {
        audit.debugWaterfall.push(`[Level 1 Atomic] Rule ${rule.id} skipped (not active yet)`);
        continue;
      }
      if (rule.activeTo && now > new Date(rule.activeTo)) {
        audit.debugWaterfall.push(`[Level 1 Atomic] Rule ${rule.id} skipped (expired)`);
        continue;
      }

      const passed = this.evaluateAtomic(rule, facts);
      audit.debugWaterfall.push(
        `[Level 1 Atomic] Rule ${rule.id} (Priority: ${rule.priority}, Weight: ${rule.weight}, Deterministic: ${rule.deterministic}, ${rule.field} ${rule.operator} ${JSON.stringify(rule.value)}): ${passed} | Rationale: ${rule.rationale}`
      );
      if (passed) {
        audit.firedAtomicRules.push(rule.id);
      } else {
        policyPassed = false;
        audit.userFacingReasons.push(rule.userFacingExplanation);
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
}
