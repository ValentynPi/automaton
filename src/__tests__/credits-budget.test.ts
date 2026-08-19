import { describe, it, expect } from "vitest";
import { remainingInferenceBudgetCents, getSurvivalTier } from "../conway/credits.js";
import { SURVIVAL_THRESHOLDS } from "../types.js";

describe("remainingInferenceBudgetCents", () => {
  it("treats non-positive daily limit as unlimited (above high)", () => {
    expect(remainingInferenceBudgetCents(0, 999)).toBe(SURVIVAL_THRESHOLDS.high + 1);
    expect(remainingInferenceBudgetCents(-1, 0)).toBe(SURVIVAL_THRESHOLDS.high + 1);
  });

  it("subtracts spent from the daily limit", () => {
    expect(remainingInferenceBudgetCents(50000, 1000)).toBe(49000);
  });

  it("floors at zero when overspent", () => {
    expect(remainingInferenceBudgetCents(100, 250)).toBe(0);
  });

  it("maps remaining budget through survival tiers", () => {
    expect(getSurvivalTier(remainingInferenceBudgetCents(1000, 0))).toBe("high");
    expect(getSurvivalTier(remainingInferenceBudgetCents(100, 40))).toBe("normal");
    expect(getSurvivalTier(remainingInferenceBudgetCents(50, 35))).toBe("low_compute");
    expect(getSurvivalTier(remainingInferenceBudgetCents(10, 10))).toBe("critical");
  });
});
