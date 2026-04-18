---
description: Find weakness by injecting faults BEFORE prod finds them. Use when system is past prototype, when designing failure modes, planning game days, or after an incident reveals a class of failures you don't test for.
mode: agent
---

# Chaos Engineering Skill

Production WILL break. Better to find out in a controlled drill than at 3am.

## When you're ready

Don't start chaos engineering before:
- [ ] Real users in production (otherwise unclear what to protect)
- [ ] Monitoring + alerting works (else you can't see impact)
- [ ] Rollback / kill-switch exists (else you can't stop)
- [ ] Team has incident response practice (else they panic)
- [ ] At least one prior real incident (or postmortem from elsewhere)

If not all → focus on test-strategy first.

## The chaos protocol

```
1. Hypothesis: "If X fails, system should still <behavior>"
2. Steady state: define metrics that prove healthy (latency p95, error rate, business metric)
3. Smallest blast radius: run on 1 instance / 1% traffic / 1 region first
4. Inject: do the failure
5. Observe: did steady state hold? Did alerts fire correctly?
6. Roll back immediately if customer impact
7. Document: hypothesis confirmed/disproven, gaps found, action items
8. Fix gaps before scaling chaos to wider radius
```

Skip step 3 → you cause an incident, not a drill.

## Failure modes to inject (in order of value)

| Failure | Frequency in nature | Easy to inject? |
|---|---|---|
| Single server crash | Often | Yes — `kill` process |
| Network latency to dependency | Often | `tc qdisc add ... netem delay 200ms` |
| Network packet loss | Sometimes | `tc qdisc add ... netem loss 5%` |
| Dependency returns 500 | Often | Toxiproxy / WireMock |
| Dependency slow (timeout) | Often | Toxiproxy / WireMock |
| DB primary failover | Sometimes | RDS / managed DB tooling |
| Region failure | Rarely but catastrophic | Multi-region only |
| Disk full | Sometimes | `dd if=/dev/zero of=fillme bs=1M count=10000` |
| CPU spike | Often | `stress-ng --cpu 4` |
| Memory pressure | Sometimes | `stress-ng --vm 4 --vm-bytes 2G` |
| Clock drift | Rarely but devastating | `date -s` (test environment) |
| DNS failure | Sometimes | Override resolver |
| Cert expiry | Predictable | Roll cert in test env |

Start with most-frequent. Region failure is exciting but rarely the right first drill.

## Tools

| Tool | Use for |
|---|---|
| **Chaos Monkey** (Netflix) | Random instance termination |
| **Litmus** | Kubernetes chaos workflows |
| **Chaos Mesh** | Kubernetes, broad fault types |
| **Gremlin** | Hosted, polished UI, less DIY |
| **Toxiproxy** | Network proxy with controllable faults |
| **WireMock / mountebank** | HTTP service simulation |
| **stress-ng / tc / iptables** | Linux primitives, free |
| **AWS FIS** | Native AWS chaos service |

For first chaos drill: do it manually. Tools come once you have a routine.

## Game days (the practice run)

Quarterly minimum. 2-4 hours.

Structure:
1. **Prep** (2 days before):
   - Define hypothesis + steady state
   - Schedule with on-call team aware
   - Status page reads "scheduled maintenance" if customer-impacting risk
   - Communicate plan + abort criteria
   - Pre-stage rollback

2. **Run** (90 min):
   - Inject fault
   - Watch dashboards live
   - Did alerts fire? Within how long?
   - Did the system degrade gracefully or cascade?
   - If catastrophic → rollback immediately

3. **Debrief** (30 min):
   - What went as expected?
   - What surprised you?
   - What gap exists in monitoring / rollback / docs?
   - Action items with owners + due dates

4. **Follow-up** (within 1 week):
   - File issues for each action item
   - Update runbooks based on findings
   - Schedule next game day

## Hypotheses by maturity level

### Beginner (your first chaos)
- "If primary DB instance goes down, app fails over within 30s"
- "If we kill 1 of N app servers, no requests fail"
- "If S3 returns 500 on uploads, we show user-friendly error"

### Intermediate
- "If payment provider is slow (5s), checkout shows progress, doesn't time out at user"
- "If half of cache nodes die, latency stays under 2x"
- "If internal API returns malformed JSON, we don't 500 — we degrade"

### Advanced
- "If region us-east-1 goes down, traffic shifts to us-west-2 within 90s with <0.1% error rate"
- "If clock skews 30s between nodes, distributed lock still works"
- "If DNS for one of our services fails, queue absorbs without dropping requests"

## Continuous chaos (in-prod, automated)

Once team is confident: run controlled chaos in prod continuously.

- 1 random instance terminated daily during business hours (Chaos Monkey original)
- Network latency injected to 1% of traffic randomly
- Dependency 500 injected for specific test users
- Auto-rollback if error rate > threshold

Feels scary. After 6 months, system is genuinely robust. Resilience is built, not assumed.

## What NOT to chaos-inject

- Customer data destruction (use real backup drill in isolation)
- Security controls (don't disable auth as a "chaos test")
- Rate limits (don't intentionally take down dependency for everyone)
- Anything during high-load business hours (Black Friday)
- Without coordination with on-call (don't surprise team)
- During incidents (one fire at a time)

## Anti-patterns

- "We don't need chaos, our tests pass" — tests cover known modes
- Chaos as performance demo (Netflix flex)
- No hypothesis (just breaking things isn't learning)
- Skip blast radius escalation (1 instance → all instances → region)
- Not debriefing (drill without learning is theater)
- Doing chaos without business buy-in (someone WILL freak out)
- Same drill every quarter (scenarios should evolve with system)
- Treating it as one-off project (it's a practice)

## Integration

- `nc-incident-response` — chaos drill = practice for real incident
- `nc-test-strategy` — chaos covers what unit tests can't
- `nc-observability` — alerts must fire correctly during chaos
- `nc-backup-recovery` — restore drill is a form of chaos
- `nc-kubernetes` — Litmus / Chaos Mesh for k8s
- `nc-debugging-advanced` — distributed system bugs surface during chaos
- `nc-company-os` — game day = SRE + Eng + EM exercise
