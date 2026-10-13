# Verification

Run `bun run verify` to check tests, lint, types, and live application readiness.
The command saves `.verification/receipt.json` and prints each result. Exit 0
means complete, 1 means a failed local check, and 2 means incomplete verification.
Use those observations in your review; the receipt is not the review report.
