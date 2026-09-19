# Runbook

> Operational reference for running, diagnosing, and recovering this service.
> Keep this actionable: a tired on-call engineer at 3am should be able to follow
> it without extra context. Update after every incident.

## Service summary

- **Owner:** TODO (team/person responsible)
- **What it does:** TODO (one line)
- **Criticality:** TODO (e.g. tier-1, customer-facing)

## Severity levels

<!-- Shared scale so nobody argues about "how bad" mid-incident. Adapt the
     examples/thresholds to this service; delete rows that don't apply. -->

| Level | Definition | Example | Ack / resolve target |
|---|---|---|---|
| SEV0 | Complete outage, all users, revenue impact | TODO | ack 5 min, resolve/escalate 15 min |
| SEV1 | Major feature broken, no workaround, majority of users | TODO | ack 10 min, resolve/escalate 30 min |
| SEV2 | Partial degradation, workaround exists | TODO | ack 30 min, resolve 2 h |
| SEV3 | Minor/cosmetic, non-critical | TODO | next business day |

## How to run it locally

<!-- Commands to build, run, and test locally. -->

```
TODO
```

## Triggers / symptoms

<!-- What an alert or symptom looks like, what it usually means, and how bad it is. -->

| Symptom / alert | Likely cause | Severity |
|---|---|---|
| TODO | TODO | TODO |

## Diagnostics

<!-- Concrete commands and links to find out what's wrong. -->

- Logs: TODO (link / command)
- Metrics dashboard: TODO (link)
- Health check: TODO (command/endpoint)

```
TODO (diagnostic commands)
```

## Escalation

<!-- Who to page and how, if you can't resolve it yourself. -->

- Primary: TODO
- Secondary: TODO
- Escalation path / paging tool: TODO

## Recovery steps

<!-- Step-by-step remediation for the most common failure modes. One numbered
     list per failure mode, worst-first. -->

1. TODO

## Verification checklist

<!-- Confirm the system is healthy before closing the incident. -->

- [ ] TODO
- [ ] TODO

## Post-incident

- Record timestamps and actions taken during the incident.
- File a follow-up to update this runbook if it was inaccurate or incomplete.
- Consider whether the incident warrants a new ADR (e.g. if it led to an
  architecture change) or a new entry in architecture.md's "Risks & technical
  debt" section.
