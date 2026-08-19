package platform.engine

import java.time.Instant

enum class OutputType { SCORE, FLAG, LABEL, VALUE, EVENT }
enum class Operator { EQUALS, NOT_EQUALS, GREATER_THAN, GREATER_THAN_OR_EQUAL, LESS_THAN, LESS_THAN_OR_EQUAL, IN, NOT_IN }
enum class LogicalOperator { AND, OR, NOT }

/** Level 1 — Atomic Rule with Full Provenance, Change Tracking & Operational Metadata */
data class AtomicRule(
    val id: String,
    val version: Int,
    val name: String,
    val owner: String,
    val domain: String,
    val rationale: String,
    val activeFrom: Instant? = null,
    val activeTo: Instant? = null,
    val enabled: Boolean = true,
    val field: String,
    val operator: Operator,
    val value: Any,
    val priority: Int = 10,
    val weight: Double = 1.0,
    val conditionName: String? = null,
    val computationName: String? = null,
    val outputKey: String,
    val outputType: OutputType,
    val userFacingExplanation: String,
    val createdAt: Instant = Instant.now(),
    val createdBy: String,
    val updatedAt: Instant = Instant.now(),
    val updatedBy: String,
    val source: String? = null,
    val supersedes: String? = null,
    val changeReason: String? = null,
    val tags: List<String> = emptyList(),
    val timeoutMs: Int? = null,
    val deterministic: Boolean = true
)

/** Level 2 — Compound Rule */
data class CompoundRule(
    val id: String,
    val version: Int,
    val name: String,
    val owner: String,
    val domain: String,
    val rationale: String,
    val enabled: Boolean = true,
    val logicalOp: LogicalOperator,
    val atomicRules: List<AtomicRule>,
    val priority: Int = 10,
    val outputKey: String,
    val outputType: OutputType,
    val weight: Double = 1.0,
    val userFacingExplanation: String
)

/** Level 3 — Policy */
data class Policy(
    val id: String,
    val name: String,
    val version: Int,
    val owner: String,
    val domain: String,
    val rationale: String,
    val atomicRules: List<AtomicRule>,
    val compoundRules: List<CompoundRule>,
    val userFacingExplanation: String
)

/** Complete Audit Trail — Accountability, Debuggability, Rationale */
data class RuleEvaluationAudit(
    val evaluationId: String,
    val policyId: String,
    val policyVersion: Int,
    val traceId: String,
    val tenantId: String,
    val evaluatedAt: Instant = Instant.now(),
    val passed: Boolean,
    val facts: Map<String, Any>,
    val firedAtomicRules: List<String>,
    val firedCompoundRules: List<String>,
    val userFacingReasons: List<String>,
    val debugWaterfall: List<String>,
    val ruleRationales: Map<String, String>
)

class RulesEvaluator {
    fun evaluatePolicy(policy: Policy, facts: Map<String, Any>, traceId: String, tenantId: String): Pair<Boolean, RuleEvaluationAudit> {
        val now = Instant.now()
        val firedAtomic = mutableListOf<String>()
        val reasons = mutableListOf<String>()
        val waterfall = mutableListOf<String>()
        val rationales = mutableMapOf<String>()
        var policyPassed = true

        policy.atomicRules.forEach { rule ->
            rationales[rule.id] = rule.rationale
            if (!rule.enabled) {
                waterfall.add("[Level 1 Atomic] Rule ${rule.id} (ver:${rule.version}) skipped (disabled)")
                return@forEach
            }
            if (rule.activeFrom != null && now.isBefore(rule.activeFrom)) {
                waterfall.add("[Level 1 Atomic] Rule ${rule.id} skipped (not active yet)")
                return@forEach
            }
            if (rule.activeTo != null && now.isAfter(rule.activeTo)) {
                waterfall.add("[Level 1 Atomic] Rule ${rule.id} skipped (expired)")
                return@forEach
            }

            val passed = evaluateAtomic(rule, facts)
            waterfall.add("[Level 1 Atomic] Rule ${rule.id} (Priority: ${rule.priority}, Weight: ${rule.weight}, ${rule.field} ${rule.operator} ${rule.value}): $passed | Rationale: ${rule.rationale}")
            if (passed) {
                firedAtomic.add(rule.id)
            } else {
                policyPassed = false
                reasons.add(rule.userFacingExplanation)
            }
        }

        val audit = RuleEvaluationAudit(
            evaluationId = "eval-\${System.currentTimeMillis()}",
            policyId = policy.id,
            policyVersion = policy.version,
            traceId = traceId,
            tenantId = tenantId,
            evaluatedAt = now,
            passed = policyPassed,
            facts = facts,
            firedAtomicRules = firedAtomic,
            firedCompoundRules = emptyList(),
            userFacingReasons = reasons,
            debugWaterfall = waterfall,
            ruleRationales = rationales
        )

        return Pair(policyPassed, audit)
    }

    private fun evaluateAtomic(rule: AtomicRule, facts: Map<String, Any>): Boolean {
        val valFact = facts[rule.field] ?: return false
        return valFact.toString() == rule.value.toString()
    }
}
