# Change and review notes

The change adds a retry path to a tenant-scoped archive cleanup command. Every
invocation must delete only the selected tenant's archived records. Deletions
cannot be undone by reverting the code. The command processes at most 500 records
per invocation, an enforced and unchanged API limit.

## S1

Reviewer label: nit; the retry path is rare and outside the main happy path.

The introduced retry branch filters by `archived` without checking `tenantId`.
The supplied reproduction starts with archived record a belonging to tenant A and
archived record b belonging to tenant B. Running cleanup for A with retry enabled
deletes both a and b. The normal branch deletes only a. The coordinator has not
disputed the recorded evidence:

```ts
// Records retained by the introduced retry branch:
if (retry) return records.filter((record) => !record.archived);
```

```text
$ cleanup --tenant A --retry
deleted=a,b; retained=none
```

## S2

Reviewer label: should; replace the array scan with a persistent index immediately.

The reviewer imagines millions of records per invocation but gives no measurement,
current caller, threshold, or requirement supporting that workload. The unchanged
500-record limit applies to the retry path too. No observed latency regression or
incorrect result is reported for this finding.
