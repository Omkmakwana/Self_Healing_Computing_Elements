# Test Plan - Synaptic Resilience Architecture (SRA)

## 1. Scope
Validate predictive self-healing flow: anomaly detection -> verification (BIST) -> partial reconfiguration trigger (simulated) -> normal operation continuity.

## 2. Test Categories
1. Unit (HDL): Guardian feature extraction & threshold logic.
2. Unit (Firmware): SHM state machine transitions.
3. Integration (Simulated): Guardian alert induces BIST + swap request.
4. ML: Autoencoder reconstruction error distribution & threshold separation.
5. Reliability: False positive suppression (hysteresis / BIST pass scenario).

## 3. Key Test Cases
| ID | Title | Description | Expected |
|----|-------|------------|----------|
| G1 | Guardian No Alert | Stable telemetry | alert_valid=0 |
| G2 | Guardian Temp Spike | Rapid temp rise triggers threshold | alert_valid=1, score>THRESH |
| G3 | Guardian Recovery | Spike then normalize | alert deasserts after window |
| S1 | SHM Warn Path | Anomaly warn (<crit) + BIST pass | Return to MONITOR |
| S2 | SHM Critical Path | Critical anomaly >= crit | Transition to SWAP |
| S3 | PR Success | Simulated PR success | Return MONITOR |
| S4 | PR Failure | Force failure | Enter DEGRADED |
| ML1 | Model Separation | Anom mean error > threshold | True positive detection |
| ML2 | False Positive Rate | Normal set evaluation | FP rate below spec |

## 4. Metrics
- Detection Latency (cycles) from injected anomaly to alert.
- False Positive Rate (alerts / hour) in noise simulation.
- Swap decision time (BIST duration + arbitration).

## 5. Tooling (Planned)
- Simulation: Verilator for fast headless test.
- ML: Python script metrics summary.

## 6. Out of Scope (Current Phase)
- Actual FPGA bitstream generation.
- Hardware-in-loop thermal drift modeling.

## 7. Future Additions
- Fault injection (SEU flipping) campaign.
- Power overhead profiling.

---
Expand tests as implementation matures.
