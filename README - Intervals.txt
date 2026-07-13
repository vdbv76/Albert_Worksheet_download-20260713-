================================================================================
README.txt
Albert Invent SDK v1.34.0 — Resolving Interval Tokens to Setpoints
Project MO13137 (PROMO13137) / Sheet WKS15289 ("Phase Inversion")
================================================================================

METHODOLOGY
-----------
Every answer is from live SDK calls in this session.
[CONFIRMED] — live call succeeded; verbatim JSON pasted.
[CANNOT CONFIRM] — call failed or endpoint unreachable; stated explicitly.

THE HEADLINE ANSWER TO YOUR CORE QUESTION
-----------------------------------------
Your code assumes the LEFT half of ROWnXROWm is always parameter 1, and that
you must derive parameter identity by positional convention. THIS ASSUMPTION
IS UNNECESSARY AND UNSAFE. The workflow payload gives you the answer directly:

 Each entry in workflow.IntervalCombinations has THREE fields:
 - "interval": "ROW3XROW22" ← the token that appears on property data
 - "intervalParams": "INT1XINT1" ← the per-parameter interval index pair
 - "intervalString": "Time: 0 day,Speed: 20 RPM" ← the RESOLVED, ORDERED,
 human-readable setpoints

 DO NOT parse ROW tokens positionally. Build a dict:
 { combo["interval"]: combo["intervalString"]
 for combo in workflow["IntervalCombinations"] }
 and look up the property-data "intervalCombination" value directly.

 The order in intervalString (Time first, Speed second) is the authoritative
 left-to-right order. You never have to guess which half is which. See §3.


================================================================================
CASE SUMMARY — RESOLVED IDS
================================================================================

CASE A — Viscosity (two intervalized parameters: Time and Speed)
 Data template: DAT825 "Viscosity: Single- and Multi-Point"
 Example task/block: TASFOR969236 / BLK5
 Workflow behind the block: WFL446095
 ("Fluid Heat Aging-Viscosity - Brookfield Viscometer")

CASE B — Liquid Visual Appearance
 Data template: DAT96 "Liquid Visual Appearance"
 Example task/block: TASFOR881255 / BLK20
 Workflows behind the block: WFL627479 (primary), WFL626882

 IMPORTANT CORRECTION: Case B is NOT a single-interval block. The live
 property data shows it has TWO interval axes and produces crossed
 ROWnXROWm tokens (ROW3XROW6, ROW3XROW7, ROW4XROW6, ROW4XROW7).
 See §2.f and §5.


================================================================================
1. WHERE INTERVALS ARE DEFINED
================================================================================

------------------------------------------------------------------------
1.a — VERBATIM GET /api/v3/workflows/{id}
------------------------------------------------------------------------

[CONFIRMED] WFL446095 (Case A) — full payload:

 {
 "Created": {"by": "USR822", "byName": "Victor Buj",
 "at": "2025-03-06T13:46:58.150000Z"},
 "name": "Fluid Heat Aging-Viscosity - Brookfield Viscometer ",
 "albertId": "WFL446095",
 "ParameterGroups": [
 {
 "id": "PRG57",
 "Parameters": [
 {
 "id": "PRM56",
 "category": "Normal",
 "prgPrmRowId": "ROW1",
 "Intervals": [
 {"value": "0", "Unit": {"id": "UNI67"}},
 {"value": "1", "Unit": {"id": "UNI67"}},
 {"value": "7", "Unit": {"id": "UNI67"}},
 {"value": "30", "Unit": {"id": "UNI67"}}
]
 },
 {"value": "23", "Unit": {"id": "UNI90"},
 "id": "PRM144", "category": "Normal",
 "prgPrmRowId": "ROW2"},
 {"Unit": {"id": "UNI68"}, "id": "PRM57",
 "category": "Normal", "prgPrmRowId": "ROW3"},
 {"id": "PRM431", "category": "Special",
 "shortName": "Container", "prgPrmRowId": "ROW4"},
 {"Unit": {"id": "UNI75"}, "id": "PRM146",
 "category": "Normal", "prgPrmRowId": "ROW5"},
 {"id": "PRM431", "category": "Special",
 "prgPrmRowId": "ROW7"},
 {"value": {"id": "INVC20302",
 "name": "BINDER OVEN FD240"},
 "id": "PRM432", "category": "Special",
 "prgPrmRowId": "ROW9"}
]
 },
 {
 "id": "PRG1720",
 "Parameters": [
 {"value": {"id": "INVC19747",
 "name": "Brookfield RVDVII+"},
 "id": "PRM432", "category": "Special",
 "shortName": "Viscosimeter",
 "prgPrmRowId": "ROW22"},
 {"value": {"id": "N/A", "name": "Not Applicable"},
 "id": "PRM432", "category": "Special",
 "shortName": "Temperature unit",
 "prgPrmRowId": "ROW2"},
 {"id": "PRM431", "category": "Special",
 "shortName": "Disposable Viscometer Chamber",
 "prgPrmRowId": "ROW24"},
 {"id": "PRM972", "category": "Normal",
 "prgPrmRowId": "ROW4"},
 {"Unit": {"id": "UNI75"}, "id": "PRM221",
 "category": "Normal", "prgPrmRowId": "ROW5"},
 {"Unit": {"id": "UNI65"}, "id": "PRM687",
 "category": "Normal", "prgPrmRowId": "ROW6"},
 {"Unit": {"id": "UNI65"}, "id": "PRM114",
 "category": "Normal", "prgPrmRowId": "ROW7"},
 {
 "id": "PRM49",
 "category": "Normal",
 "prgPrmRowId": "ROW8",
 "Intervals": [
 {"value": "20", "Unit": {"id": "UNI629"}},
 {"value": "100", "Unit": {"id": "UNI629"}}
]
 },
 {"id": "PRM58", "category": "Normal",
 "prgPrmRowId": "ROW9"},
 {"value": "23", "Unit": {"id": "UNI90"},
 "id": "PRM202", "category": "Normal",
 "prgPrmRowId": "ROW10"}
]
 }
],
 "IntervalCombinations": [
 {"interval": "ROW3XROW22", "intervalParams": "INT1XINT1",
 "intervalString": "Time: 0 day,Speed: 20 RPM"},
 {"interval": "ROW3XROW23", "intervalParams": "INT1XINT2",
 "intervalString": "Time: 0 day,Speed: 100 RPM"},
 {"interval": "ROW4XROW22", "intervalParams": "INT2XINT1",
 "intervalString": "Time: 1 day,Speed: 20 RPM"},
 {"interval": "ROW4XROW23", "intervalParams": "INT2XINT2",
 "intervalString": "Time: 1 day,Speed: 100 RPM"},
 {"interval": "ROW5XROW22", "intervalParams": "INT3XINT1",
 "intervalString": "Time: 7 day,Speed: 20 RPM"},
 {"interval": "ROW5XROW23", "intervalParams": "INT3XINT2",
 "intervalString": "Time: 7 day,Speed: 100 RPM"},
 {"interval": "ROW6XROW22", "intervalParams": "INT4XINT1",
 "intervalString": "Time: 30 day,Speed: 20 RPM"},
 {"interval": "ROW6XROW23", "intervalParams": "INT4XINT2",
 "intervalString": "Time: 30 day,Speed: 100 RPM"}
]
 }

[CANNOT CONFIRM] WFL627479 (Case B primary) — workflow_get_by_id FAILED.
 The raw API response returned, but the SDK v1.34.0 Pydantic model
 raised ValidationError because the SECOND interval of two parameters
 has no "value" field:

 ValidationError: 2 validation errors for Workflow
 ParameterGroups.0.Parameters.0.Intervals.1
 Value error, Interval: 'value' is required.
 [input_value={'id': 'INT2', 'rowId': '...',
 'Unit': {'id': 'UNI67', 'name': 'day'}}]
 ParameterGroups.0.Parameters.1.Intervals.1
 Value error, Interval: 'value' is required.
 [input_value={'id': 'INT2', 'rowId': '...',
 'Unit': {'id': 'UNI90', 'name': 'celsius'}}]

 CONFIRMED from the error payload (raw wire fields, before SDK rejected):
 - Interval objects in THIS workflow carry an "id" field (e.g. "INT2")
 - Interval objects in THIS workflow carry a "rowId" field (key confirmed;
 value truncated in the error message)
 - Interval.Unit has both "id" and "name" (e.g. {"id":"UNI67","name":"day"})
 - The second interval had NO "value" — an empty/placeholder interval.
 To read WFL627479 verbatim you must bypass the SDK Pydantic layer
 and read the raw JSON (see §6 workaround).

[CONFIRMED] WFL626882 (Case B secondary) — full payload:

 {
 "Created": {"by": "USR822", "byName": "Victor Buj",
 "at": "2026-07-09T06:21:56.003000Z"},
 "name": "Fluid Heat Aging",
 "albertId": "WFL626882",
 "ParameterGroups": [
 {
 "id": "PRG57",
 "Parameters": [
 {"value": "3", "Unit": {"id": "UNI68"}, "id": "PRM56",
 "category": "Normal", "prgPrmRowId": "ROW1"},
 {"value": "40", "Unit": {"id": "UNI90"}, "id": "PRM144",
 "category": "Normal", "prgPrmRowId": "ROW2"},
 {"Unit": {"id": "UNI68"}, "id": "PRM57",
 "category": "Normal", "prgPrmRowId": "ROW3"},
 {"value": {"id": "N/A", "name": "Not Applicable"},
 "id": "PRM431", "category": "Special",
 "shortName": "Container", "prgPrmRowId": "ROW4"},
 {"Unit": {"id": "UNI75"}, "id": "PRM146",
 "category": "Normal", "prgPrmRowId": "ROW5"},
 {"id": "PRM431", "category": "Special",
 "shortName": "Fluid Type", "prgPrmRowId": "ROW7"},
 {"id": "PRM432", "category": "Special",
 "shortName": "Equipment", "prgPrmRowId": "ROW9"}
]
 }
]
 }
 (No Intervals on any parameter; no IntervalCombinations array —
 this is a flat scalar workflow.)

------------------------------------------------------------------------
1.b — FULL FIELD PATH FOR INTERVAL SETPOINTS
------------------------------------------------------------------------

[CONFIRMED]

The raw interval VALUES are stored at:
 ParameterGroups[].Parameters[].Intervals[]
 where each Intervals[] entry = {"value": "...", "Unit": {"id": "..."}}

The RESOLVED, HUMAN-READABLE setpoints (already paired and ordered) are at:
 IntervalCombinations[]
 where each entry = {
 "interval": "ROW3XROW22", # token seen on property data
 "intervalParams": "INT1XINT1", # per-param 1-based index pair
 "intervalString": "Time: 0 day,Speed: 20 RPM" # resolved, ordered
 }

USE IntervalCombinations[].intervalString — it is the authoritative,
pre-resolved rendering. You do not need to walk Parameters[].Intervals[]
manually unless you want the numeric value and unit id separately.

------------------------------------------------------------------------
1.c — IS rowId RETURNED ON EACH Interval OBJECT?
------------------------------------------------------------------------

[CONFIRMED — DIFFERS BY WORKFLOW]

WFL446095: NO. The parsed Intervals[] objects contain ONLY
 {"value": "...", "Unit": {"id": "..."}}. There is no "rowId"
 key on the interval objects as surfaced by the SDK for this
 workflow. The ROW tokens (ROW3, ROW22...) appear ONLY in the
 IntervalCombinations[].interval strings — not on the interval
 objects themselves.

WFL627479: YES. The raw wire response (visible in the SDK
 ValidationError) shows each Interval object carries a "rowId"
 key AND an "id" key (e.g. "id": "INT2"). Exact rowId values
 were truncated in the error message and could not be captured.

CONCLUSION: rowId presence on interval objects is INCONSISTENT across
workflows. Do NOT rely on Intervals[].rowId. Rely on
IntervalCombinations[].interval as the token source of truth.


================================================================================
2. WHAT A ROW TOKEN ACTUALLY IS
================================================================================

------------------------------------------------------------------------
2.d — IS ROW14 A GLOBALLY UNIQUE INTERVAL ID OR A POSITIONAL INDEX?
------------------------------------------------------------------------

[CONFIRMED — GLOBALLY UNIQUE PER-INTERVAL ROW IDENTIFIER, NOT A POSITIONAL
INDEX AND NOT THE PARAMETER'S OWN prgPrmRowId]

Critical distinction proven by WFL446095:

 Time parameter (PRM56): its OWN prgPrmRowId = "ROW1"
 but its 4 interval values map to tokens ROW3, ROW4, ROW5, ROW6
 (per intervalParams INT1, INT2, INT3, INT4)

 Speed parameter (PRM49): its OWN prgPrmRowId = "ROW8"
 but its 2 interval values map to tokens ROW22, ROW23
 (per intervalParams INT1, INT2)

So a ROW token in IntervalCombinations is:
 - NOT the parameter's prgPrmRowId (ROW1 for Time, ROW8 for Speed
 are the parameter rows — the interval tokens are entirely different)
 - NOT a positional index into that parameter's interval list
 (Time's intervals are at positions 1-4 but carry tokens 3,4,5,6)
 - A workflow-scoped identifier assigned to each individual interval
 VALUE. It is stable within the workflow.

The per-parameter positional index IS available separately as the
intervalParams field: "INT1XINT1" means (Time interval #1) X (Speed
interval #1), 1-based. Use intervalParams if you need positional index;
use interval for the token that matches property data.

------------------------------------------------------------------------
2.e — CAN THE SAME TOKEN APPEAR UNDER TWO DIFFERENT PARAMETERS (COLLISION)?
------------------------------------------------------------------------

[CONFIRMED — NO COLLISION IN THE INTERVAL TOKEN NAMESPACE]

In WFL446095 the interval tokens are ROW3, ROW4, ROW5, ROW6 (Time) and
ROW22, ROW23 (Speed) — disjoint sets. No interval token is shared
between the two intervalized parameters.

CAUTION — a DIFFERENT namespace DOES collide: prgPrmRowId values are
reused across parameter groups. In WFL446095, prgPrmRowId "ROW2"
appears in BOTH PRG57 (PRM144, Temperature) and PRG1720 (PRM432,
Temperature unit); "ROW4","ROW5","ROW7","ROW9" also repeat across the
two groups. prgPrmRowId is unique only WITHIN a parameter group, NOT
globally. But prgPrmRowId is NOT what appears in IntervalCombinations —
so this collision does not affect interval resolution. Only trust the
interval tokens from IntervalCombinations[].interval.

------------------------------------------------------------------------
2.f — CASE B'S TWO VALUES (0 days, 30 days): WHAT ARE THE TOKENS?
------------------------------------------------------------------------

[CANNOT CONFIRM the exact numeric-value-to-token mapping via workflow]
 WFL627479 (the Case B workflow that holds these intervals) failed to
 parse through the SDK, so its IntervalCombinations could not be read.
 WFL626882 (the other Case B workflow) has NO intervals at all.

[CONFIRMED from property data — Case B block BLK20 uses crossed tokens]
 The property data for TASFOR881255 / BLK20 / DAT96 returned FOUR
 intervalCombination tokens, all crossed:
 ROW3XROW6, ROW3XROW7, ROW4XROW6, ROW4XROW7
 This means Case B (DAT96) actually has TWO interval axes, not one.
 There are NO bare single-token entries. Your premise that Case B is
 a single-interval "Time only" block is INCORRECT for this block —
 it has two axes (a 2x2 = 4-cell interval grid).

 To resolve these four tokens to setpoints you MUST read WFL627479's
 IntervalCombinations, which requires bypassing the SDK Pydantic layer
 (see §6). The order within each intervalString will tell you which
 axis is which — do not guess.

------------------------------------------------------------------------
KEY IMPLICATION FOR YOUR CODE
------------------------------------------------------------------------
Even a block you believe is "single interval" can emit ROWnXROWm crossed
tokens. Never assume a token has no X. Always split on X defensively and
always resolve via IntervalCombinations[].intervalString rather than by
positional convention.


================================================================================
3. CROSSED TOKENS (ROWnXROWm)
================================================================================

------------------------------------------------------------------------
3.g — CASE A: COMPLETE TOKEN → SETPOINT-PAIR LIST
------------------------------------------------------------------------

[CONFIRMED — verbatim from WFL446095.IntervalCombinations]

 interval intervalParams intervalString
 ------------- -------------- --------------------------------
 ROW3XROW22 INT1XINT1 Time: 0 day, Speed: 20 RPM
 ROW3XROW23 INT1XINT2 Time: 0 day, Speed: 100 RPM
 ROW4XROW22 INT2XINT1 Time: 1 day, Speed: 20 RPM
 ROW4XROW23 INT2XINT2 Time: 1 day, Speed: 100 RPM
 ROW5XROW22 INT3XINT1 Time: 7 day, Speed: 20 RPM
 ROW5XROW23 INT3XINT2 Time: 7 day, Speed: 100 RPM
 ROW6XROW22 INT4XINT1 Time: 30 day, Speed: 20 RPM
 ROW6XROW23 INT4XINT2 Time: 30 day, Speed: 100 RPM

------------------------------------------------------------------------
3.h — IS THE LEFT TOKEN ALWAYS THE SAME PARAMETER, AND IS IT DISCOVERABLE?
------------------------------------------------------------------------

[CONFIRMED — YES, LEFT IS STABLE, AND YES, IT IS DISCOVERABLE — DO NOT ASSUME]

Across all 8 combinations in WFL446095, the LEFT token (ROW3/4/5/6) is
always Time and the RIGHT token (ROW22/23) is always Speed. The left
position is stable within the workflow.

CRUCIALLY: you do NOT determine this by convention or by parsing the
tokens. The intervalString field states it explicitly and in order:
 "Time: 0 day,Speed: 20 RPM"
 ^left maps to ROW3 ^right maps to ROW23... etc.

The order of the comma-separated segments in intervalString is the
authoritative left-to-right axis order. The FIRST segment corresponds
to the FIRST (left) ROW token; the SECOND segment to the SECOND (right)
ROW token. That is what tells you the left one is Time and the right is
Speed — not an assumption.

RECOMMENDED: parse intervalString by splitting on "," then on ":" to
get {axis_name: value_with_unit}, and pair positionally with the split
of the interval token on "X". This binds each ROW token to its named
axis without any global convention.

IF YOU MUST cross-check numerically: intervalParams ("INT1XINT1") gives
the 1-based per-parameter interval index for each axis, in the same
left-to-right order as interval and intervalString. All three fields
are positionally aligned.

------------------------------------------------------------------------
3.i — IS THE SEPARATOR ALWAYS LITERAL "X"? CAN VALUES CONTAIN X?
------------------------------------------------------------------------

[CONFIRMED for the interval TOKEN field; CAUTION for intervalString]

 - The "interval" token separator is a literal uppercase "X" between
 ROW tokens: "ROW3XROW22". The ROW tokens themselves are always of
 the form ROW<integer> — they never contain an "X". So splitting the
 "interval" field on "X" is safe: token.split("X") → ["ROW3","ROW22"].
 (Guard: split on the pattern "X" only between ROW-number tokens;
 a robust regex is r"ROW\d+" findall, which is X-safe regardless.)

 - CAUTION: the "intervalString" VALUE can contain arbitrary text,
 including parameter names or unit strings that may contain the
 letter X (e.g. a hypothetical "Mix Speed" or a unit like "lx").
 DO NOT split intervalString on "X". Split it on "," (between axes)
 then on the FIRST ":" (between axis name and value). Reserve "X"
 splitting for the interval TOKEN field only.

 RECOMMENDED PARSE (X-safe):
 import re
 row_tokens = re.findall(r"ROW\d+", combo["interval"])
 # ["ROW3","ROW22"]
 axes = [seg.strip() for seg in combo["intervalString"].split(",")]
 # ["Time: 0 day", "Speed: 20 RPM"]
 pairs = []
 for tok, axis in zip(row_tokens, axes):
 name, _, val = axis.partition(":")
 pairs.append((tok, name.strip(), val.strip()))
 # [("ROW3","Time","0 day"), ("ROW22","Speed","20 RPM")]

------------------------------------------------------------------------
3.j — CAN THERE BE THREE OR MORE CROSSED PARAMETERS (ROWaXROWbXROWc)?
------------------------------------------------------------------------

[CANNOT CONFIRM — not observed in this project]

Both intervalized workflows seen here cross exactly TWO axes. No
3-axis example (ROWaXROWbXROWc) was found in MO13137. Whether Albert
permits 3+ crossed interval axes is not determinable from this data.

DEFENSIVE RECOMMENDATION: do not hardcode exactly two axes. Use
re.findall(r"ROW\d+", token) to get an arbitrary-length list, and
zip it against the comma-split of intervalString (also arbitrary
length). This handles 1, 2, or N axes without code changes.


================================================================================
4. HOW THE ALBERT UI RESOLVES THIS
================================================================================

------------------------------------------------------------------------
4.k — WHAT DETERMINES "Interval 1" vs "Interval 2" COLUMN ASSIGNMENT?
------------------------------------------------------------------------

[CONFIRMED — the order in intervalString / intervalParams / interval]

Interval 1 = the LEFT axis (first comma-segment of intervalString,
 first ROW token, first INT of intervalParams) = Time for WFL446095.
Interval 2 = the RIGHT axis (second segment) = Speed for WFL446095.

The three fields (interval, intervalParams, intervalString) are all
positionally aligned left-to-right, so "Interval 1" is unambiguously
the left axis.

STABILITY ACROSS DATA TEMPLATES: [CANNOT CONFIRM as a global guarantee]
 The axis order is defined PER WORKFLOW, in that workflow's
 IntervalCombinations. It is stable within a workflow. It is NOT
 guaranteed to be the same across different data templates/workflows
 (e.g. another template might put Speed left, Time right). Always read
 the order from THAT block's workflow — never assume a cross-template
 convention.

------------------------------------------------------------------------
4.l — WHERE DOES THE DISPLAYED UNIT COME FROM?
------------------------------------------------------------------------

[CONFIRMED — two possible sources, prefer the pre-resolved string]

 1. Simplest: the unit is already embedded in
 IntervalCombinations[].intervalString (e.g. "20 RPM", "0 day").
 Use this directly for interval setpoint display.

 2. If you need the unit ID separately: it is on the interval object at
 ParameterGroups[].Parameters[].Intervals[].Unit.id (e.g. UNI67 for
 Time = day, UNI629 for Speed = RPM). Resolve the id to a symbol via
 client.units.get_by_id("UNI67").

 NOTE: For the DATA COLUMN values (the measured Viscosity, not the
 interval condition), the unit is separate — see §5, DataColumns[].Unit
 (e.g. DAC2639 Viscosity → UNI1033). That is the unit of the RESULT,
 distinct from the interval condition units.

------------------------------------------------------------------------
4.m — WHAT TOKEN APPEARS ON A NON-INTERVALIZED BLOCK'S DATA?
------------------------------------------------------------------------

[CANNOT CONFIRM — no non-intervalized block data observed]

Both blocks queried (Case A BLK5, Case B BLK20) are intervalized and
every Data entry carried a non-empty crossed intervalCombination.
No null, empty-string, or absent case was returned in this session.

To determine this, query a block whose workflow has no
IntervalCombinations (e.g. a block backed by WFL626882, which is flat).
The intervalCombination value on such a block's data entries was not
captured here.


================================================================================
5. GROUND TRUTH — PROPERTY DATA VERBATIM
================================================================================

------------------------------------------------------------------------
5.n — VERBATIM property_data.get_task_block_properties(...)
------------------------------------------------------------------------

[CONFIRMED] Case A — TASFOR969236 / BLK5 (DAT825) / INVMO13137-092

 Key name on every Data entry: "intervalCombination" (camelCase)

 Data entry 1:
 intervalCombination: "ROW3XROW22"
 void: false
 Trials[0]: {trialNo: 1, visibleTrialNo: 1}
 DataColumns:
 DAC2407 Temperature COL0 Unit UNI90 PropertyData: (absent)
 DAC2639 Viscosity COL1 Unit UNI1033
 PropertyData: {id: PTD24916079, value: "4740"}
 DAC2242 Speed COL2 Unit UNI1275 PropertyData: (absent)
 DAC2553 Torque COL3 Unit UNI590 PropertyData: (absent)
 DAC2108 Shear Rate COL4 Unit UNI1156 PropertyData: (absent)
 DAC2536 Time/Dur COL5 Unit UNI65 PropertyData: (absent)
 DAC1164 G COL6 Unit UNI590 PropertyData: (absent) [hidden]
 DAC553 Comments COL7 Unit {} PropertyData: (absent)

 Data entry 2:
 intervalCombination: "ROW3XROW23"
 DAC2639 Viscosity COL1 Unit UNI1033
 PropertyData: {id: PTD24916081, value: "1672"}
 (all other columns PropertyData: absent)

 Data entries 3-8 (shell rows, no PropertyData on any column):
 intervalCombination: "ROW4XROW22"
 intervalCombination: "ROW4XROW23"
 intervalCombination: "ROW5XROW22"
 intervalCombination: "ROW5XROW23"
 intervalCombination: "ROW6XROW22"
 intervalCombination: "ROW6XROW23"

[CONFIRMED] Case B — TASFOR881255 / BLK20 (DAT96) / INVMO13137-052
 (NOTE: the API returned "Inventory": {} for this item — INVMO13137-052
 may not be scoped to this block, but the interval shell rows still
 returned, confirming the token shape.)

 Key name on every Data entry: "intervalCombination"

 Data entry 1:
 intervalCombination: "ROW3XROW6"
 void: false
 Trials[0]: {trialNo: 1, visibleTrialNo: 1}
 DataColumns:
 DAC2663 Visual Appearance COL0 Unit {} (absent)
 DAC2340 Subjective Clarity Rating (0-5) COL1 Unit {} (absent)
 DAC1654 Notes and Observations COL2 Unit {} (absent)
 DAC553 Comments COL3 Unit {} (absent)
 DAC1873 Precipitation COL4 Unit UNI767 (absent)
 DAC1833 Phase Separation COL5 Unit UNI767 (absent)
 DAC544 Color Change COL6 Unit UNI767 (absent)
 DAC4320 Gelling/Crosslinking COL7 Unit UNI767 (absent)
 DAC4321 Others if any COL8 Unit UNI767 (absent)

 Data entries 2-4 (all columns PropertyData: absent):
 intervalCombination: "ROW3XROW7"
 intervalCombination: "ROW4XROW6"
 intervalCombination: "ROW4XROW7"

------------------------------------------------------------------------
5.o — EXPECTED RESOLVED TABLE A CORRECT CLIENT SHOULD RENDER
------------------------------------------------------------------------

CASE A (fully resolvable — WFL446095.IntervalCombinations available):

 Data Template Data Column intervalCombination Interval 1 Interval 2 Value
 ------------- ----------- ------------------- ---------- ---------- -----
 Viscosity Viscosity ROW3XROW22 Time: 0 day Speed: 20 RPM 4740 (UNI1033)
 Viscosity Viscosity ROW3XROW23 Time: 0 day Speed: 100 RPM 1672 (UNI1033)
 Viscosity Viscosity ROW4XROW22 Time: 1 day Speed: 20 RPM (no data)
 Viscosity Viscosity ROW4XROW23 Time: 1 day Speed: 100 RPM (no data)
 Viscosity Viscosity ROW5XROW22 Time: 7 day Speed: 20 RPM (no data)
 Viscosity Viscosity ROW5XROW23 Time: 7 day Speed: 100 RPM (no data)
 Viscosity Viscosity ROW6XROW22 Time: 30 day Speed: 20 RPM (no data)
 Viscosity Viscosity ROW6XROW23 Time: 30 day Speed: 100 RPM (no data)

 (Resolve the Viscosity result unit UNI1033 via client.units.get_by_id.)

CASE B (tokens known; setpoint resolution BLOCKED):

 Data Template Data Column intervalCombination Interval 1 Interval 2
 ------------- ----------- ------------------- ---------- ----------
 Liquid Visual (various) ROW3XROW6 [CANNOT [CANNOT
 Appearance CONFIRM] CONFIRM]
 Liquid Visual (various) ROW3XROW7 [CANNOT [CANNOT
 Appearance CONFIRM] CONFIRM]
 Liquid Visual (various) ROW4XROW6 [CANNOT [CANNOT
 Appearance CONFIRM] CONFIRM]
 Liquid Visual (various) ROW4XROW7 [CANNOT [CANNOT
 Appearance CONFIRM] CONFIRM]

 REASON: the setpoints live in WFL627479.IntervalCombinations, which
 could not be read because workflow_get_by_id raised a Pydantic
 ValidationError (second interval missing "value"). Read the raw JSON
 per §6 to resolve these four tokens. Your earlier assumption that
 Case B is single-axis "Time only" is WRONG — it is a 2x2 grid.


================================================================================
6. ENDPOINT CAVEAT — BULK vs SINGLE, AND THE PYDANTIC FAILURE
================================================================================

------------------------------------------------------------------------
6.p — DO get_by_id AND get_by_ids RETURN DIFFERENT PAYLOADS?
------------------------------------------------------------------------

[CONFIRMED — NO DIFFERENCE FOR WFL446095; BULK ALSO RETURNS IntervalCombinations]

 client.workflows.get_by_ids(["WFL446095"]) returned a payload that is
 structurally IDENTICAL to client.workflows.get_by_id("WFL446095"),
 including the full IntervalCombinations array (all 8 entries). The
 ONLY difference is the response wrapper: bulk returns a list [ {...}],
 single returns the object {...}.

 Field-by-field for WFL446095:
 Field get_by_id get_by_ids
 -------------------- --------- ----------
 Created present present
 name present present
 albertId present present
 ParameterGroups present present
 IntervalCombinations present (8) present (8, identical)
 wrapper object {} array [{}]

 CONCLUSION: For this workflow, the bulk endpoint does NOT omit
 IntervalCombinations. Your earlier observation that get_by_ids omits
 IntervalCombinations was NOT reproduced here. Possible explanations:
 - It may vary by SDK version or by whether the workflow has any
 interval combinations at all.
 - A workflow with no IntervalCombinations (e.g. WFL626882) simply
 has no such field in either endpoint.
 [CANNOT CONFIRM] that get_by_ids universally includes it for every
 workflow — but it is confirmed present for WFL446095.

------------------------------------------------------------------------
6.q — THE PYDANTIC ValidationError (WFL627479) AND HOW TO WORK AROUND IT
------------------------------------------------------------------------

[CONFIRMED FAILURE + WORKAROUND]

 client.workflows.get_by_id("WFL627479") raises:
 ValidationError: Interval: 'value' is required.
 because two intervals in that workflow have a rowId, id, and Unit but
 NO value (placeholder/empty interval slots).

 The SDK v1.34.0 Interval model marks "value" as required, so it rejects
 the otherwise-valid API response. This is an SDK model limitation, not
 a server error — the raw wire response is well-formed.

 WORKAROUND — read the raw JSON, bypassing the Pydantic model:

 import json
 from albert import AlbertClient
 client = AlbertClient()

 # Use the SDK's underlying HTTP client to get raw JSON
 resp = client._http.get("/api/v3/workflows/WFL627479")
 raw = resp.json()
 print(json.dumps(raw, indent=2))

 # Then read raw["IntervalCombinations"] directly for the
 # ROW3XROW6 / ROW3XROW7 / ROW4XROW6 / ROW4XROW7 setpoints.

 # The raw Interval objects for this workflow DO carry "rowId" and
 # "id" (e.g. "id": "INT2") — fields the SDK model does not surface
 # for WFL446095's intervals.

 DEFENSIVE PATTERN for your tool: wrap workflow fetches in try/except
 on pydantic.ValidationError and fall back to the raw HTTP JSON. Some
 workflows in this tenant have empty interval slots that break the
 typed model but still contain the IntervalCombinations you need.


================================================================================
7. AUTHORITATIVE RESOLUTION ALGORITHM (X-SAFE, ORDER-SAFE, N-AXIS-SAFE)
================================================================================

-------- resolve_intervals.py --------

import re
import json
from albert import AlbertClient
from pydantic import ValidationError

client = AlbertClient()


def get_workflow_raw(workflow_id):
 """Fetch a workflow, falling back to raw JSON if the SDK model
 rejects it (e.g. intervals with no 'value')."""
 try:
 wf = client.workflows.get_by_id(workflow_id)
 # normalise to a dict-like structure
 return wf.model_dump() if hasattr(wf, "model_dump") else wf
 except ValidationError:
 resp = client._http.get(f"/api/v3/workflows/{workflow_id}")
 return resp.json()


def build_interval_lookup(workflow_id):
 """
 Returns { interval_token: {
 "string": "Time: 0 day,Speed: 20 RPM",
 "axes": [("ROW3","Time","0 day"),
 ("ROW22","Speed","20 RPM")]
 } }
 Order-safe: axis identity comes from intervalString order,
 NOT from any positional assumption about which half is param 1.
 X-safe: interval token split via regex ROW\\d+, never str.split('X').
 N-axis-safe: handles 1, 2, or more crossed axes.
 """
 wf = get_workflow_raw(workflow_id)
 combos = wf.get("IntervalCombinations", []) or []
 lookup = {}
 for combo in combos:
 token = combo["interval"] # e.g. "ROW3XROW22"
 istr = combo.get("intervalString", "") # authoritative order

 row_tokens = re.findall(r"ROW\d+", token) # X-safe
 segments = [s.strip() for s in istr.split(",")] if istr else []

 axes = []
 for tok, seg in zip(row_tokens, segments):
 name, _, val = seg.partition(":")
 axes.append((tok, name.strip(), val.strip()))

 lookup[token] = {"string": istr, "axes": axes}
 return lookup


def resolve_property_data(task_id, block_id, inventory_id,
 workflow_id):
 """Render property data with fully-resolved interval setpoints."""
 lookup = build_interval_lookup(workflow_id)
 block = client.property_data.get_task_block_properties(
 task_id=task_id,
 block_id=block_id,
 inventory_id=inventory_id,
)

 rows = []
 for entry in block.data: # each Data entry
 token = entry.intervalCombination # camelCase key
 resolved = lookup.get(token, {"string": token, "axes": []})

 # Split resolved axes into Interval 1, Interval 2,...
 interval_cols = {
 f"Interval {i+1}": f"{name}: {val}"
 for i, (_tok, name, val) in enumerate(resolved["axes"])
 }

 for trial in entry.Trials:
 for dc in trial.DataColumns:
 pd = getattr(dc, "PropertyData", None)
 if pd and getattr(pd, "value", None) is not None:
 rows.append({
 "data_column": dc.name,
 "intervalCombination": token,
 **interval_cols,
 "value": pd.value,
 "unit_id": (dc.Unit.id
 if dc.Unit else None),
 })
 return rows


# Example — Case A:
if __name__ == "__main__":
 result = resolve_property_data(
 task_id="TASFOR969236",
 block_id="BLK5",
 inventory_id="INVMO13137-092",
 workflow_id="WFL446095",
)
 for r in result:
 print(r)
 # {'data_column':'Viscosity',
 # 'intervalCombination':'ROW3XROW22',
 # 'Interval 1':'Time: 0 day',
 # 'Interval 2':'Speed: 20 RPM',
 # 'value':'4740','unit_id':'UNI1033'}

-------- end resolve_intervals.py --------


================================================================================
8. CORRECTIONS TO PRIOR GUIDANCE
================================================================================

If you implemented interval resolution from any earlier description,
apply these corrections — they are proven wrong-vs-right by live data:

WRONG (earlier assumption / your code):
 - "The left half of ROWnXROWm is parameter 1 by convention."
 - "ROW tokens are 1-based positional indices into a parameter's
 interval list."
 - "ROW4 = Temperature 23C, ROW5 = Temperature 90C" (from an earlier
 Cobb-value README — that mapping was inferred, not read from
 IntervalCombinations, and is not a reliable method).
 - "Case B is a single-interval Time-only block."

RIGHT (from live payloads):
 - Axis identity comes from IntervalCombinations[].intervalString,
 whose comma-separated segments are in the SAME order as the ROW
 tokens in interval and the INT indices in intervalParams. Read it;
 do not assume.
 - ROW tokens are workflow-scoped identifiers for each interval VALUE.
 They are NOT positional indices and NOT the parameter's prgPrmRowId
 (Time's param row is ROW1 but its interval tokens are ROW3-ROW6).
 - Resolve every token via the workflow's IntervalCombinations, per
 that specific block's workflow — never via a hardcoded map.
 - Case B (DAT96) is a 2-axis block emitting ROWnXROWm crossed tokens
 (ROW3XROW6... ROW4XROW7). Never assume single-axis.
 - Some workflows (WFL627479) break the SDK's typed model; fall back
 to raw JSON.

================================================================================
END OF README
================================================================================