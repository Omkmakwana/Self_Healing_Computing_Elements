// shm_main.c
// System Health Manager (SHM) firmware skeleton
// Handles guardian alerts, triggers BIST, commands partial reconfiguration (stubbed)

#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <stdbool.h>

// ------------------ Configuration ------------------
#define MAX_GUARDIANS 8
#define ANOMALY_THRESHOLD_CRIT 700
#define ANOMALY_THRESHOLD_WARN 400

// ------------------ Data Structures ----------------
typedef enum {
    EV_NONE = 0,
    EV_ALERT,
    EV_BIST_RESULT,
    EV_PR_RESULT
} event_type_t;

typedef struct {
    uint16_t block_id;
    uint16_t anomaly_score;
    uint16_t bist_result; // 0=unknown,1=pass,2=fail
    uint32_t feature_crc;
    uint64_t timestamp_us;
} guardian_alert_t;

typedef enum {
    ST_MONITOR = 0,
    ST_VERIFY,
    ST_SWAP,
    ST_DEGRADED
} shm_state_t;

// ------------------ Globals (stub) ------------------
static shm_state_t g_state = ST_MONITOR;
static guardian_alert_t g_last_alert;
static bool g_bist_in_progress = false;
static bool g_pr_in_progress = false;

// ------------------ Hardware Abstraction Stubs ------
static uint64_t get_time_us(void) { return 0; }
static void log_event(const char *msg) { printf("[LOG] %s\n", msg); }
static void trigger_bist(uint16_t block_id) { (void)block_id; g_bist_in_progress = true; log_event("BIST triggered"); }
static int  poll_bist(uint16_t block_id) { (void)block_id; if(g_bist_in_progress){ g_bist_in_progress=false; return 1; } return 0; }
static void start_partial_reconfig(uint16_t block_id) { (void)block_id; g_pr_in_progress = true; log_event("PR start"); }
static int  poll_partial_reconfig(void) { if(g_pr_in_progress){ g_pr_in_progress=false; return 1; } return 0; }

// Simulated guardian alert fetch (would come from memory-mapped FIFO / IRQ)
static bool fetch_guardian_alert(guardian_alert_t *out) {
    (void)out;
    return false; // no alert by default in stub
}

// ------------------ State Machine Logic -------------
static void handle_monitor(void) {
    guardian_alert_t alert;
    if(fetch_guardian_alert(&alert)) {
        g_last_alert = alert;
        if(alert.anomaly_score >= ANOMALY_THRESHOLD_WARN) {
            log_event("Anomaly detected -> VERIFY");
            g_state = ST_VERIFY;
            trigger_bist(alert.block_id);
        }
    }
}

static void handle_verify(void) {
    if(poll_bist(g_last_alert.block_id)) {
        // For now assume pass => if score critical, swap anyway
        if(g_last_alert.anomaly_score >= ANOMALY_THRESHOLD_CRIT) {
            log_event("Critical anomaly -> SWAP");
            g_state = ST_SWAP;
            start_partial_reconfig(g_last_alert.block_id);
        } else {
            log_event("BIST pass. Return to MONITOR");
            g_state = ST_MONITOR;
        }
    }
}

static void handle_swap(void) {
    if(poll_partial_reconfig()) {
        log_event("PR success. Return to MONITOR");
        g_state = ST_MONITOR;
    }
}

static void handle_degraded(void) {
    // Placeholder degraded handling
}

// ------------------ Main Loop -----------------------
int main(void) {
    log_event("SHM firmware starting");
    while(1) {
        switch(g_state) {
            case ST_MONITOR: handle_monitor(); break;
            case ST_VERIFY:  handle_verify(); break;
            case ST_SWAP:    handle_swap(); break;
            case ST_DEGRADED:handle_degraded(); break;
            default: g_state = ST_MONITOR; break;
        }
        // Insert low-power wait or scheduling tick
    }
    return 0;
}
