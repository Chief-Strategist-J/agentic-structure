from dataclasses import dataclass, field
from datetime import datetime, timezone
from enum import Enum
from typing import Any, Dict, List, Optional
import uuid

class OutputType(str, Enum):
    SCORE = "score"
    FLAG = "flag"
    LABEL = "label"
    VALUE = "value"
    EVENT = "event"

class Operator(str, Enum):
    EQUALS = "EQUALS"
    NOT_EQUALS = "NOT_EQUALS"
    GREATER_THAN = "GREATER_THAN"
    GREATER_THAN_OR_EQUAL = "GREATER_THAN_OR_EQUAL"
    LESS_THAN = "LESS_THAN"
    LESS_THAN_OR_EQUAL = "LESS_THAN_OR_EQUAL"

class LogicalOperator(str, Enum):
    AND = "AND"
    OR = "OR"
    NOT = "NOT"

@dataclass
class AtomicRule:
    id: str
    version: int
    name: str
    owner: str
    domain: str
    rationale: str
    field: str
    operator: Operator
    value: Any
    output_key: str
    output_type: OutputType
    user_facing_explanation: str
    created_by: str
    updated_by: str
    active_from: Optional[datetime] = None
    active_to: Optional[datetime] = None
    enabled: bool = True
    priority: int = 10
    weight: float = 1.0
    created_at: datetime = field(default_factory=lambda: datetime.now(timezone.utc))
    updated_at: datetime = field(default_factory=lambda: datetime.now(timezone.utc))
    source: Optional[str] = None
    supersedes: Optional[str] = None
    change_reason: Optional[str] = None
    tags: List[str] = field(default_factory=list)
    timeout_ms: Optional[int] = None
    deterministic: bool = True

@dataclass
class Policy:
    id: str
    name: str
    version: int
    owner: str
    domain: str
    rationale: str
    atomic_rules: List[AtomicRule]
    user_facing_explanation: str

@dataclass
class RuleEvaluationAudit:
    evaluation_id: str
    policy_id: str
    policy_version: int
    trace_id: str
    tenant_id: str
    evaluated_at: datetime
    passed: bool
    facts: Dict[str, Any]
    fired_atomic_rules: List[str]
    user_facing_reasons: List[str]
    debug_waterfall: List[str]
    rule_rationales: Dict[str, str]

class RulesEvaluator:
    def evaluate_policy(self, policy: Policy, facts: Dict[str, Any], trace_id: str, tenant_id: str) -> RuleEvaluationAudit:
        now = datetime.now(timezone.utc)
        fired_rules: List[str] = []
        reasons: List[str] = []
        waterfall: List[str] = []
        rationales: Dict[str, str] = {}
        policy_passed = True

        for rule in policy.atomic_rules:
            rationales[rule.id] = rule.rationale
            if not rule.enabled:
                waterfall.append(f"[Level 1 Atomic] Rule {rule.id} skipped (disabled)")
                continue

            fact_val = facts.get(rule.field)
            passed = str(fact_val) == str(rule.value) if fact_val is not None else False
            waterfall.append(f"[Level 1 Atomic] Rule {rule.id} ({rule.field} {rule.operator.value} {rule.value}): {passed} | Rationale: {rule.rationale}")

            if passed:
                fired_rules.append(rule.id)
            else:
                policy_passed = False
                reasons.append(rule.user_facing_explanation)

        return RuleEvaluationAudit(
            evaluation_id=f"eval-{uuid.uuid4()}",
            policy_id=policy.id,
            policy_version=policy.version,
            trace_id=trace_id,
            tenant_id=tenant_id,
            evaluated_at=now,
            passed=policy_passed,
            facts=facts,
            fired_atomic_rules=fired_rules,
            user_facing_reasons=reasons,
            debug_waterfall=waterfall,
            rule_rationales=rationales
        )
