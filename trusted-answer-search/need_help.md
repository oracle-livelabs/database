# Need Help?

This page is a reference, not an additional exercise.

- **Cannot find the applications or credentials?** Open **View Login Info** > **Environment Details** in the reservation. Use the application login, not your OCI Console password.
- **Missing Workshop Files URL or report?** Ask the workshop owner to complete preparation. The Trusted Answer Search ZIP alone does not include the workshop report or its download page.
- **Brokerage Lab already exists?** Ask for a fresh reservation; do not erase another learner's content. The installed Demo Brokerage sample is separate from the space you create.
- **Missing LiveLab Draft or Brokerage Quick Check?** You create these during the exercise. Check the Create a Search Space and evaluation-set creation steps; neither should be pre-created in a fresh reservation.
- **Import fails or the space is empty?** Confirm Brokerage Lab and its draft are selected, use the two configuration files from this reservation's Workshop Files page, and review Import Status. Wait for completion; do not repeatedly submit the import.
- **Open Stock Orders or `LAB_ORDER_SIDE` already exists in a newly imported draft?** Ask the workshop owner to check the import files. They should contain only the original twenty targets and five value sets.
- **The target is missing from search?** Confirm Brokerage Lab and the selected version. Before publishing, use Query Tester with LiveLab Draft. After publishing, refresh the website and try its widget. The widget is connected to the exact space name Brokerage Lab; publishing the installed Demo Brokerage space will not expose your new target there. Check Visibility is PUBLIC for this fictional demo.
- **Wrong report view?** Check the action's `/open-stock-orders/` path, `?order_side=:ORDER_SIDE`, the mapping to `LAB_ORDER_SIDE`, and values `ALL`, `BUY`, and `SELL`. Default ALL shows four orders; BUY shows two orders with 60 shares remaining; SELL shows two with 25 remaining.
- **The documented baseline differs?** Before feedback, the purchase query `check purchases that have not gone through` should return Open Stock Orders at rank 3. The first evaluation should have five passes and one missing-target failure for `Review unexecuted equity trades.` (Open Stock Orders/ALL), giving P5 = 83.33%. Confirm Brokerage Lab and LiveLab Draft; previous feedback can change the starting results. Record the exact query and observed ranks, then stop and report the mismatch to the workshop owner. Do not substitute another query or change expected answers.
- **Upvote or Choose Another Target is disabled on the published version?** In Settings > Search Space Settings for Brokerage Lab, set Edit Published Versions? to Yes and save. Return to Query Tester and confirm the same version. Restore No after the feedback comparison, including when you stop because results differ.
- **Feedback does not improve the results?** Keep the observed outcome and both run IDs. Confirm the exact query, version and expected input, then report the result to the workshop owner. A saved upvote alone is not proof of improvement.
- **Recorded query missing?** Set Dashboard > Telemetry to Last Day. Find the clicked purchase query under Clicked Search Targets. The equity-trades query is already in the imported benchmark; you do not add it from the Dashboard. Query Tester searches do not contribute to widget totals or click-through rate.
- **No Disable LLM option?** This selector is absent when there are no LLM profiles. Continue without it; this exercise uses a manual value set.
- **Evaluation count is not six?** Check for a missing or repeated query: five imported checks (including the equity-trades query expecting Open Stock Orders/ALL) and the widget purchase query expecting Open Stock Orders/BUY. Evaluation Set Details shows five rows per page; use Next to inspect the sixth.
- **Another evaluation query changes or fails?** This exercise applies feedback only to the documented equity-trades query. Record unexpected changes to any of the other five and report both run IDs; do not apply additional feedback or change the expected answers during the comparison. A correct target/input below rank 1 can still PASS.
- **The run itself ends with FAIL or an error instead of COMPLETED?** Record the run ID and error and report them to the workshop owner. A failed background job is different from a completed run containing failed query checks.

See the [Trusted Answer Search User's Guide](https://docs.oracle.com/en/database/oracle/oracle-database/26/otasc/index.html) for more detail.

## Acknowledgements

**Authors:** Markus Kissling, Akshay S Kulkarni, and Kishy Kumar

**Last Updated Date:** October 2026
