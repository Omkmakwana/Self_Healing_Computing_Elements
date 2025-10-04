# Synaptic Resilience Architecture (SRA)

> Self-Healing Computing Elements — Proactive, AI-driven fault prediction and instant FPGA partial reconfiguration.
> 
## 1. Problem Overview
Mission / defence-grade electronic systems must survive faults gracefully with **zero or minimal downtime**. Traditional redundancy reacts _after_ a failure. We need a system that **anticipates faults** and transparently re-routes computation before catastrophic failure propagates.

## 2. Proposed Solution (High-Level)
SRA embeds lightweight per-block AI "Guardian Modules" inside a partially reconfigurable FPGA fabric. Guardians continuously sense telemetry (temperature, voltage droop, timing margin, soft error counts) and perform on-device anomaly prediction using TinyML. A central **System Health Manager (SHM)** arbitrates decisions:

1. Monitor (stream metrics)
2. Predict (Guardian flags anomaly score > threshold)
3. Verify (trigger fast Built-In Self-Test)
4. Isolate (quarantine suspect region / freeze I/O)
5. Swap (activate cold spare region; load bitstream via Partial Reconfiguration)
6. Reroute (update interconnect / fabric routing tables)
7. Resume (mission continues seamlessly)

## 3. Key Innovations
- Shift from *reactive* to *proactive* hardware resilience.
- Distributed micro-AI (TinyML) per function block vs single centralized monitor.
- Deterministic failover path using pre-validated spare regions.
- Two-step False Positive mitigation: AI anomaly + BIST confirmation.

## 4. System Architecture
```
+--------------------+         +---------------------------+
| Guardian Module A  |  ...    | Guardian Module N        |
| (metrics + TinyML) |         | (metrics + TinyML)       |
+---------+----------+         +------------+-------------+
          |                                 |
          v                                 v
      +------------------- Aggregated Telemetry ------------------+
      |            System Health Manager (SHM)                    |
      |  - Policy Engine  - Spare Allocation  - PR Controller     |
      +----------+------------------------+-----------------------+
                 |                        |
                 v                        v
        Partial Reconfig Ctrl      Bitstream Repository
                 |                        |
                 v                        v
        Reconfig Region(s)  <---->  Non-Volatile Storage
```

### Components
- Guardian Module: Sensor IF + Feature Extractor + TinyML Inference + Alert.
- SHM Firmware: Runs on soft-core (MicroBlaze/Nios II) or external MCU.
- PR Controller: Vendor-specific ICAP/PCAP (Xilinx) or PR IP (Intel).
- Bitstream Repo: Signed partial bitstreams (active + spares).
- Telemetry Bus: AXI-Lite or custom lightweight status ring.

## 5. Data & ML Pipeline (TinyML)
| Stage | Purpose | Notes |
|-------|---------|-------|
| Sampling | Collect temp/voltage/timing jitter counters | 1–5 kHz typical |
| Feature Extraction | Rolling mean, slope, z-score, EWMA | Implement in hardware |
| Model | 1D Autoencoder or small Isolation Forest equivalent | Converted to TFLite Micro |
| Threshold Adaptation | Dynamic baseline tracking | Avoid drift false alarms |
| BIST Trigger | On anomaly > T1 | Fast deterministic pattern test |
| Switch Decision | BIST fail OR anomaly > T2 | Initiate PR swap |

## 6. Partial Reconfiguration Strategy
- Floorplan: Each critical logic function placed in a *Reconfigurable Partition (RP)* with at least one *Spare RP*.
- Prebuilt Bitstreams: Active + Spare variants share static region interface (bus macros / partition pins).
- Swap Latency Target: < 10 ms (depends on bitstream size & configuration clock).
- Integrity: Bitstreams cryptographically hashed + optionally signed.
- State Transfer: Use shadow registers / dual-port BRAM snapshot before isolation.

## 7. Reliability & Risk Mitigation
| Risk | Mitigation |
|------|------------|
| False Positive | BIST confirmation tier; hysteresis on anomaly score |
| PR Failure | Retry w/ backup spare; maintain last-known-good ID |
| Model Drift | Periodic recalibration window during low-load periods |
| Sensor Noise | Median / EWMA filtering in hardware preprocessor |
| Overhead | Tiny (<5k LUT) Guardian budget; schedule inference sparsely |

## 8. Development Roadmap
| Phase | Milestone |
|-------|-----------|
| 0 | Repo scaffold & docs |
| 1 | Guardian telemetry stub + SHM skeleton |
| 2 | TinyML model training & integration (simulation) |
| 3 | Partial Reconfig flow (single block hot-swap) |
| 4 | Multi-block scaling + spare arbitration |
| 5 | Security hardening (bitstream signing) |
| 6 | Optimization & benchmarking |

## 9. Build / Tooling (Planned)
- HDL Sim: Verilator / Questa (user choice)
- Synthesis / PR: Vendor toolchain (Vivado / Quartus) — not included in repo.
- ML: Python 3.11, TensorFlow / tflite-runtime.
- Firmware: GCC toolchain for chosen soft-core or ARM Cortex-M.

## 10. Getting Started
1. Fill placeholders (Problem Statement ID, Team info).
2. Train sample anomaly model: `python ml/train_anomaly.py` (to be added).
3. Generate TFLite model → place in `ml/models/guardian_model.tflite`.
4. Simulate Guardian HDL with synthetic anomaly injection.
5. Integrate with SHM firmware state machine.

## 11. License
TBD (Add appropriate open-source license if desired).

## 12. References (Add Later)
- IEEE: Fault Tolerance in FPGAs
- Xilinx UG909 Partial Reconfiguration
- TinyML Anomaly Detection Whitepapers
- BIST methodologies survey papers

---
Documentation is intentionally modular—extend each section as implementation progresses.
