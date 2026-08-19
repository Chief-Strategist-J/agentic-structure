package com.platform.platform.engine;

import java.time.Instant;
import java.util.*;

public class RulesEngine {
    public enum OutputType { SCORE, FLAG, LABEL, VALUE, EVENT }
    public enum Operator { EQUALS, NOT_EQUALS, GREATER_THAN, LESS_THAN }

    public record AtomicRule(
        String id,
        int version,
        String name,
        String owner,
        String domain,
        String rationale,
        boolean enabled,
        String field,
        Operator operator,
        Object value,
        int priority,
        double weight,
        String outputKey,
        OutputType outputType,
        String userFacingExplanation,
        Instant createdAt,
        String createdBy,
        Instant updatedAt,
        String updatedBy,
        boolean deterministic
    ) {}

    public record RuleEvaluationAudit(
        String evaluationId,
        String policyId,
        String traceId,
        String tenantId,
        Instant evaluatedAt,
        boolean passed,
        List<String> firedAtomicRules,
        List<String> userFacingReasons,
        List<String> debugWaterfall
    ) {}
}
