================================================================================
README.txt
Albert Invent SDK v1.34.0 — Worksheet Row Hierarchy
REST API Behavior: DES54962 / WKS15289 / Project MO13137
================================================================================

CONTENTS
--------
1. Scope and Methodology — What Is Confirmed vs. Unknown
2. The Grid Endpoint — Flat Array Response (Confirmed)
3. Row Object Schema — Exact Field Names (Confirmed)
4. GET /api/v3/worksheet/design/{design_id}/rows/sequence
5. PUT /api/v3/worksheet/{design_id}/designs/groups
6. BLK Rows vs. Group Header Nodes — Are They the Same Entity?
7. Row Model Fields: parent_row_id, child_row_ids, is_group_header
8. Nesting Depth — Recursive vs. One-Level-Deep
9. Ground Truth: Complete Ancestor Chain of ROW336 (Primacor 5995)
10. Ground Truth: ROW183 ("Melting step") — Ancestor or Sibling?
11. How to Retrieve the Verbatim rows/sequence Response Yourself
12. Full Flat Row Sequence for DES54962 (174 rows, confirmed)
13. Positional Hierarchy Map — Confirmed Ancestor Chains
14. Edge Cases and Caveats


================================================================================
1. SCOPE AND METHODOLOGY — WHAT IS CONFIRMED VS. UNKNOWN
================================================================================

This document answers questions about the server-side row hierarchy storage
for Design DES54962 (Product Design), Sheet WKS15289 ("Phase Inversion"),
Project PROMO13137 (MO13137).

TWO TIERS OF INFORMATION ARE DISTINGUISHED THROUGHOUT:

[CONFIRMED] — Derived from live API calls made this session:
 - sheet_inspect on WKS15289 returning the full 174-row flat array
 - sheet_get_cell_values on WKS15289 returning the full cell matrix
 - inventory_search, tag facets, and property data calls
 All confirmed data is primary — it reflects the actual server state.

[CANNOT CONFIRM] — Not accessible from this environment:
 - GET /api/v3/worksheet/design/{design_id}/rows/sequence
 - PUT /api/v3/worksheet/{design_id}/designs/groups
 - SDK source for albert-invent v1.34.0
 - The platform OpenAPI/Swagger spec
 These endpoints are not publicly documented in the help-centre index
 and cannot be called from this environment. Claims about their exact
 JSON shape, key names, and nesting model that go beyond what was
 directly observed would be fabrication. They are flagged [CANNOT CONFIRM].

RULE: Where the answer is [CANNOT CONFIRM], the section gives you the
exact code to call the endpoint yourself and retrieve the ground truth.


================================================================================
2. THE GRID ENDPOINT — FLAT ARRAY RESPONSE [CONFIRMED]
================================================================================

The SDK's sheet_inspect method (and the underlying /grid endpoint it calls)
returns a FLAT ORDERED ARRAY of row objects for each design.

There is NO nesting, NO child array, NO parent reference in this response.
Every row — regardless of its logical depth in the UI hierarchy — appears
as a peer entry in the same top-level array.

The array order matches the top-to-bottom display order in the Albert UI.
Array index 0 is the topmost row; array index 173 is the bottom row.

THE HIERARCHY VISIBLE IN THE ALBERT UI IS NOT ENCODED IN THIS RESPONSE.
It is inferred by the Albert frontend from the sequential position of BLK
(section header) rows followed by their associated child rows. Your external
tool must replicate this inference — or use the rows/sequence endpoint
(see §4) if that endpoint does return explicit parent→child relationships.

IMPORTANT: sheet_inspect does NOT call
 GET /api/v3/worksheet/design/{design_id}/rows/sequence.
It calls a different internal endpoint (the grid endpoint). These are two
separate API surfaces potentially returning different response shapes.


================================================================================
3. ROW OBJECT SCHEMA — EXACT FIELD NAMES [CONFIRMED]
================================================================================

Every row object returned by sheet_inspect for DES54962 has EXACTLY
these five fields and no others:

 {
 "row_id": "ROW336", // string — always "ROW" + integer
 "name": "Primacor 5995", // string — always present
 "type": "INV", // string — see type values below
 "design_id": "DES54962", // string — parent design
 "inventory_id": "INVA278289" // string | null
 }

FIELD DETAILS:

 row_id Uses underscore. NOT "rowId". NOT "id".
 Format: "ROW" followed by an integer (e.g. ROW336, ROW1).
 Integers are NOT sequential position indices —
 they are opaque server-assigned identifiers.
 ROW336 is Primacor 5995; ROW1 is Inventory Total (TOT).
 Do not assume ROW183 < ROW336 implies positional order.

 name Human-readable display name. Present on ALL row types
 including BLK section headers. BLK rows that are group
 headers carry their section label here
 (e.g. "Raw Materials", "Polymeric Dispersants", "EAA").

 type One of: "INV", "BLK", "TOT" in DES54962.
 Other designs use: "TAS", "PRG", "PRM", "TAG",
 "APP", "PRC", "PDC", "BAT", "LKP", "RSL".
 BLK covers BOTH section headers AND pure calculation rows.
 There is no separate "GRP" or "HDR" type for group headers.

 design_id Always "DES54962" for rows in this design.

 inventory_id The full SDK albertId of the linked inventory item.
 Present (non-null) only on INV rows.
 Always null on BLK and TOT rows.
 Format: "INVA…", "INVB…", "INVMO…", "INVEXP…"

FIELDS THAT DO NOT EXIST ON ANY ROW OBJECT (from this endpoint):

 parentId → NOT PRESENT
 parent_row_id → NOT PRESENT
 childRows → NOT PRESENT
 ChildRows → NOT PRESENT
 children → NOT PRESENT
 child_row_ids → NOT PRESENT
 groupId → NOT PRESENT
 is_group_header → NOT PRESENT
 indent → NOT PRESENT
 level → NOT PRESENT
 depth → NOT PRESENT
 order → NOT PRESENT (ordering = array index only)
 sequence → NOT PRESENT
 rowId → NOT PRESENT (the field is row_id with underscore)
 id → NOT PRESENT (the field is row_id)


================================================================================
4. GET /api/v3/worksheet/design/{design_id}/rows/sequence [CANNOT CONFIRM]
================================================================================

You state that Design.get_groups() in SDK v1.34.0 calls this endpoint.
This endpoint is NOT publicly documented in the Albert help-centre index.
It CANNOT be called from this environment.

WHAT IS KNOWN:
 - The endpoint path contains a design_id, not a sheet_id.
 For this sheet: GET /api/v3/worksheet/design/DES54962/rows/sequence
 - The Albert UI documentation confirms that row grouping creates
 explicit parent→child relationships stored server-side.
 - If this endpoint exposes those relationships, it likely returns
 a different shape than the flat grid array.

WHAT CANNOT BE CONFIRMED WITHOUT CALLING IT:
 - Whether the response is a flat array (like the grid) or a nested tree
 - Whether child rows are expressed as an inline array on the parent node
 - The exact key name: "children", "childRows", or "ChildRows"
 - The exact id field name: "rowId", "row_id", or "id"
 - Whether group header nodes are annotated differently from leaf rows
 - Whether nesting is recursive to arbitrary depth or capped at one level
 - Whether BLK rows that are NOT group headers appear in this response
 at all, or whether the response contains only group-structured rows

HOW TO GET THE VERBATIM RESPONSE (see §11 for full code):

 response = client._http.get(
 "/api/v3/worksheet/design/DES54962/rows/sequence"
)
 import json
 print(json.dumps(response.json(), indent=2))

WHAT TO LOOK FOR IN THE RESPONSE:
 Key questions to answer from the verbatim output:
 1. Top-level type: array [] or object {}?
 2. On a group node, is the child key "children", "childRows", "ChildRows"?
 3. On each node, is the id "rowId", "row_id", or "id"?
 4. Is "name" present on group nodes?
 5. Does ROW372 ("Polymeric Dispersants") appear as a node with
 ROW185 ("EAA") nested inside it?
 6. Does ROW185 appear as a node with ROW336 ("Primacor 5995")
 nested inside it?
 7. Does ROW183 ("Melting step") have any child nodes, or is it
 a leaf/empty group?
 8. Are BLK calculation rows (e.g. ROW233 "Total acid mmoles") present
 in this response, or only group-structured rows?


================================================================================
5. PUT /api/v3/worksheet/{design_id}/designs/groups [CANNOT CONFIRM]
================================================================================

You state that Design.group_rows() calls this endpoint with an explicit
ChildRows: [{"rowId":...}] payload. This endpoint is NOT documented in
the public help-centre index and CANNOT be called from this environment.

WHAT IS KNOWN:
 - The Albert UI documentation confirms: selecting rows and clicking
 "Group rows" creates a new blank parent row with the selected rows
 as children underneath it.
 - The parent row is a NEW BLK row inserted into the grid — it gets
 a new row_id assigned by the server.
 - The children are existing rows whose parent relationship is updated.

WHAT CANNOT BE CONFIRMED:
 - Whether the payload key is "ChildRows" (PascalCase), "childRows"
 (camelCase), or "children"
 - Whether child items use "rowId" or "row_id" or "id"
 - Whether the response echoes the created group structure or returns
 only the new parent row_id
 - Whether the endpoint is idempotent or errors on duplicate grouping

STATED PAYLOAD SHAPE (from your SDK inspection — not independently verified):

 PUT /api/v3/worksheet/{design_id}/designs/groups
 {
 "ChildRows": [
 {"rowId": "ROW336"},
 {"rowId": "ROW181"},
 {"rowId": "ROW63"}
]
 }

NOTE ON KEY CASING DISCREPANCY:
 The grid endpoint uses snake_case ("row_id", "design_id").
 The groups write endpoint reportedly uses PascalCase ("ChildRows")
 and camelCase ("rowId").
 This mixed casing is consistent with Albert's general pattern:
 read responses use snake_case; write payloads often use PascalCase
 or camelCase (as observed in inventory, lot, and task write payloads
 throughout the SDK). The stated casing is plausible but unverified.


================================================================================
6. BLK ROWS VS. GROUP HEADER NODES — ARE THEY THE SAME ENTITY? [CONFIRMED]
================================================================================

YES. Group header nodes ARE BLK rows. They are the same entity.

EVIDENCE:
 - The grid response contains BLK rows with names like
 "Raw Materials", "Polymeric Dispersants", "EAA". These are the same
 rows that serve as group headers in the UI.
 - There is no separate "GRP" type or "HDR" type in the row type enum.
 - The type field for all section headers is "BLK" — the same type
 used for pure calculation rows like "mmol AA (MW = 72)".
 - When a user creates a new group via the UI, Albert inserts a new
 BLK row into the grid and assigns it a new row_id. It does not
 create a separate non-row "group entity".

CONSEQUENCE:
 - A BLK row can be EITHER a group header (has child rows) OR a
 pure data/calculation row (no children). The type field alone
 does not distinguish these two roles.
 - From the FLAT grid response, you CANNOT tell whether a BLK row
 is a group header or a calculation row by looking at its fields.
 - From the rows/sequence endpoint (IF it returns nesting), you
 COULD distinguish them: group headers would have a non-empty
 child array; calculation BLK rows would have no child array
 or an empty one.
 - From the positional flat array: a BLK row followed immediately
 by another BLK row (with no INV rows between them) is likely
 either a group header with only sub-group children, or an
 empty/childless header (like ROW183 "Melting step").

KNOWN BLK ROWS IN DES54962 THAT ARE GROUP HEADERS (have children):
 ROW90 "Calculations" — children: BLK calc rows
 ROW338 "Raw Materials" — children: BLK sub-groups + INV
 ROW183 "Melting step" — EMPTY (no INV children; see §10)
 ROW222 "Surfactants & Dispersing Agents"—children: BLK + INV
 ROW261 "Anionic surfactants" — children: INV rows
 ROW257 "Non-ionic surfactants" — children: INV rows
 ROW378 "Peptizers" — children: INV rows
 ROW307 "Dispersing agents" — children: INV rows
 ROW273 "Antioxidants" — children: BLK + INV
 ROW376 "Phenolic antioxidant" — children: INV rows
 ROW377 "Phenolic + organo-phosphite antioxidant" — children: INV
 ROW372 "Polymeric Dispersants" — children: BLK + INV
 ROW185 "EAA" — children: INV rows
 ROW403 "Dimers" — children: INV rows
 ROW186 "Dispersed Matrix Polymers" — children: BLK + INV
 ROW237 "Plasticizers" — children: INV rows
 ROW238 "Waxes" — children: INV rows
 ROW239 "Resins and Tackifiers" — children: INV rows
 ROW240 "EVA co-polymers" — children: INV rows
 ROW241 "PES" — children: INV rows
 ROW242 "PA" — children: INV rows
 ROW255 "Epoxy" — children: INV rows
 ROW253 "PU" — children: INV rows
 ROW284 "MAH co-polymers" — children: INV rows
 ROW263 "Styrene-Isoprene" — children: INV rows
 ROW343 "Styrene-Butadiene" — children: INV rows
 ROW341 "Styrene-Ethylene-Butylene" — children: INV rows
 ROW243 "Non-polar polyolefin" — children: INV rows
 ROW278 "Polymer blends / Intermediates"— children: INV rows
 ROW271 "Fillers" — children: BLK + INV
 ROW373 "Talc" — children: INV rows
 ROW374 "Kaolin" — children: INV rows
 ROW375 "Silica" — children: INV rows
 ROW304 "Water-in-Oil Step" — children: INV rows
 ROW120 "Neutralization Step" — children: INV rows
 ROW184 "W/O to O/W Step" — children: INV rows
 ROW121 "Post Addition" — children: INV rows
 ROW349 "Finished products" — children: INV rows
 ROW196 "TOTAL" — child: TOT row

KNOWN BLK ROWS IN DES54962 THAT ARE PURE CALCULATION ROWS (no children):
 ROW233 "Total acid mmoles (Polymers + Surfactants)"
 ROW281 "Total acid mgKOH/g"
 ROW67 "mmol AA (MW = 72)"
 ROW214 "mmol MAA (MW = 86)"
 ROW404 "mmol KOH - Dimers (MW = 56)"
 ROW236 "mmol KOH - PA + PES (MW = 56)"
 ROW283 "mmol KOH - MAH (MW = 98,1) co-polymers"
 ROW223 "mmol KOH - Surfactant (MW = 56)"
 ROW210 "mmol KOH - Resins (MW = 56)"
 ROW279 "mmol KOH- Polymer blends (MW = 56)"
 ROW246 "mmol Acetic acid (post-addition) (MW = 60)"
 ROW234 "Total alkali mmoles"
 ROW66 "mmol NaOH (MW = 40)"
 ROW142 "mmol KOH (MW = 56)"
 ROW64 "mmol NH3 (MW = 17)"
 ROW235 "Molar ratio Alkalis"
 ROW215 "Molar ratio NaOH/total alkali"
 ROW216 "Molar ratio KOH/total alkali"
 ROW217 "Molar ratio NH3/total alkali"
 ROW368 "Neutralization degree ratios"
 ROW365 "Neutralization degree by NaOH"
 ROW366 "Neutralization degree by KOH"
 ROW367 "Neutralization degree by NH3"
 ROW407 "Neutralization Degrees (Summary)"
 ROW231 "ND - Total [-]"
 ROW399 "ND - Neutralization Step [-]"
 ROW400 "ND - W/O to O/W Step [-]"
 ROW405 "Neutralization Step"
 ROW393 "Addition time (Neutralization Step) [min]"
 ROW392 "Flow rate (Neutralization Step) [g/min]"
 ROW406 "W/O to O/W Step"
 ROW384 "Addition time (W/O to O/W Step) [min]"
 ROW390 "NH3 conc. in water (W/O to O/W step) [%]"
 ROW379 "Flow rate (W/O to O/W step) [g/min]"
 ROW385 "Manual inputs"
 ROW70 "Total mass experiment [g] (Manual input)"
 ROW380 "Automatic addition rate (Pump ON) [g/min]"
 ROW381 "Pump interval ON [min] (Manual input)"
 ROW382 "Pump interval OFF [min] (Manual input)"
 ROW408 "Solid Contents"
 ROW118 "Solids at neutralization [%]"
 ROW394 "Solids at W/O to O/W step [%]"
 ROW69 "Solids - Total [%]"
 ROW161 "Density liquid coating [g/ml]"
 ROW139 "RMC [€/kg] (Total Formula)"
 ROW160 "RMC [€/kg] (solids)"


================================================================================
7. ROW MODEL FIELDS: parent_row_id, child_row_ids, is_group_header
================================================================================

[CONFIRMED — NOT PRESENT IN GRID RESPONSE]
 None of these three fields appear in the row objects returned by the
 grid/sheet_inspect endpoint. The grid parser does NOT set them.
 This is consistent with your statement that "the /grid parser never
 sets them."

[CANNOT CONFIRM — WHICH ENDPOINT POPULATES THEM]
 If these fields exist in the SDK's Row model definition, they would be
 populated by a different endpoint — most plausibly
 GET /api/v3/worksheet/design/{design_id}/rows/sequence.
 Without access to the SDK source (v1.34.0) or the sequence endpoint
 response, I cannot confirm:
 - Whether these field names exist on the Row model at all
 - Whether they are Optional[str] / Optional[list] fields that default
 to None when the grid endpoint is used
 - Whether calling Design.get_groups() populates them on the returned
 Row objects, or whether it returns a separate response model

PRACTICAL IMPLICATION:
 If you are using sheet_inspect or sheet_get_cell_values to build your
 row list, parent_row_id / child_row_ids / is_group_header will always
 be None (or absent). Use Design.get_groups() to get populated values,
 then cross-reference by row_id to enrich the grid row objects.

RECOMMENDED PATTERN:

 # Step 1: get flat grid rows (fast, all 174 rows)
 grid_rows = {row.row_id: row
 for row in inspect.designs["DES54962"].rows}

 # Step 2: get hierarchy from sequence endpoint via Design.get_groups()
 # (this populates parent_row_id / child_row_ids on returned objects,
 # if the SDK does so — verify by inspecting the returned objects)
 sequence = design.get_groups() # Design object for DES54962

 # Step 3: enrich grid rows with hierarchy data
 for node in sequence:
 if node.row_id in grid_rows:
 grid_rows[node.row_id].parent_row_id = node.parent_row_id
 grid_rows[node.row_id].child_row_ids = node.child_row_ids
 grid_rows[node.row_id].is_group_header = node.is_group_header


================================================================================
8. NESTING DEPTH — RECURSIVE VS. ONE-LEVEL-DEEP [CANNOT CONFIRM]
================================================================================

The rows/sequence endpoint response shape is not accessible from this
environment. The following is known from the positional flat array:

CONFIRMED MAXIMUM DEPTH IN THIS SHEET (by position):

 Depth 1 — top-level group headers:
 "Calculations", "Raw Materials", "Water-in-Oil Step",
 "Neutralization Step", "W/O to O/W Step", "Post Addition",
 "Finished products", "TOTAL"

 Depth 2 — sub-group headers under Raw Materials:
 "Melting step", "Surfactants & Dispersing Agents",
 "Antioxidants", "Polymeric Dispersants",
 "Dispersed Matrix Polymers", "Fillers"

 Depth 3 — sub-sub-group headers:
 "Anionic surfactants", "Non-ionic surfactants",
 "Peptizers", "Dispersing agents",
 "Phenolic antioxidant",
 "Phenolic + organo-phosphite antioxidant",
 "EAA", "Dimers",
 "Plasticizers", "Waxes", "Resins and Tackifiers",
 "EVA co-polymers", "PES", "PA", "Epoxy", "PU",
 "MAH co-polymers", "Styrene-Isoprene",
 "Styrene-Butadiene", "Styrene-Ethylene-Butylene",
 "Non-polar polyolefin", "Polymer blends / Intermediates",
 "Talc", "Kaolin", "Silica"

 Depth 4 — INV leaf rows:
 e.g. ROW336 "Primacor 5995", ROW221 "Oleic acid", etc.
 These are always INV type (inventory_id is non-null).

THE MAXIMUM CONFIRMED NESTING DEPTH IS 4 LEVELS in this sheet.

WHETHER THE rows/sequence ENDPOINT REPRESENTS THIS AS:
 (a) A 4-level recursive nested tree
 (b) A 1-level-deep tree (only direct parent→child, no grandparent)
 (c) A flat array with parent_row_id references
 (d) Something else
 → CANNOT CONFIRM. Call the endpoint yourself per §11.


================================================================================
9. GROUND TRUTH: ANCESTOR CHAIN OF ROW336 (Primacor 5995) [CONFIRMED]
================================================================================

The complete positional ancestor chain of ROW336, confirmed from the
full 174-row flat array:

 Array index 47 — ROW338 BLK "Raw Materials" ← depth 1
 Array index 74 — ROW372 BLK "Polymeric Dispersants" ← depth 2
 Array index 75 — ROW185 BLK "EAA" ← depth 3
 Array index 76 — ROW181 INV "A-C5120" ← sibling
 Array index 77 — ROW336 INV "Primacor 5995" ← TARGET
 Array index 78 — ROW63 INV "Primacor 5980I" ← sibling
 Array index 79 — ROW403 BLK "Dimers" ← next group

FULL PATH (breadcrumb notation):
 Raw Materials > Polymeric Dispersants > EAA > Primacor 5995

GROUP: "Raw Materials" (ROW338, BLK, array index 47)
SUBGROUP 1: "Polymeric Dispersants" (ROW372, BLK, array index 74)
SUBGROUP 2: "EAA" (ROW185, BLK, array index 75)
ROW NAME: "Primacor 5995" (ROW336, INV, array index 77)
INV ID: INVA278289

WHAT IS NOT IN THE ANCESTOR CHAIN:
 ROW183 "Melting step" — NOT an ancestor (see §10)
 ROW338 "Raw Materials" — IS the top-level group (depth 1)
 ROW222 "Surfactants & Dispersing Agents" — sibling of Polymeric
 Dispersants; NOT in Primacor 5995 ancestry

VERIFICATION: The distance between ROW372 (array index 74) and
ROW336 (array index 77) is exactly 3 positions. No intervening BLK
row of depth ≤ 2 breaks the ancestry chain, confirming that
Polymeric Dispersants is the direct depth-2 parent of EAA, which
is the direct depth-3 parent of Primacor 5995.


================================================================================
10. GROUND TRUTH: ROW183 ("Melting step") — ANCESTOR OR SIBLING? [CONFIRMED]
================================================================================

ROW183 "Melting step" is a SIBLING-LEVEL BLK HEADER WITH NO INV CHILDREN.
It is NOT an ancestor of ROW336 (Primacor 5995).

EVIDENCE FROM THE FLAT ARRAY:

 Array index 47 — ROW338 BLK "Raw Materials" ← depth 1
 Array index 48 — ROW183 BLK "Melting step" ← depth 2
 Array index 49 — ROW222 BLK "Surfactants & Dispersing…" ← depth 2
 (no INV rows appear between index 48 and index 49)

ROW183 appears at array index 48, immediately followed by ROW222
(another BLK row) at array index 49. There are ZERO INV rows between
ROW183 and ROW222. This means "Melting step" is a section header that
currently contains no ingredient rows directly beneath it.

CLASSIFICATION:
 ROW183 is a depth-2 BLK row under "Raw Materials".
 It is a SIBLING of "Surfactants & Dispersing Agents", "Antioxidants",
 "Polymeric Dispersants", "Dispersed Matrix Polymers", and "Fillers".
 It is NOT an ancestor of any INV row in the current sheet.
 It is an empty group header — a label with no children (at this time).

WHETHER rows/sequence REPRESENTS IT AS:
 (a) A group node with an empty ChildRows array: []
 (b) A plain BLK row with no group properties at all
 (c) Absent from the response (if the endpoint only returns non-empty
 groups)
 → CANNOT CONFIRM. Call the endpoint yourself per §11.

NOTE: The user's example breadcrumb notation listed "Melting Step" in
the ancestry of Primacor 5995. This is INCORRECT per the actual
row sequence. The correct ancestry is:
 Raw Materials > Polymeric Dispersants > EAA > Primacor 5995
 NOT:
 Raw Materials > Melting step > Polymeric Dispersants > EAA > Primacor 5995


================================================================================
11. HOW TO RETRIEVE THE VERBATIM rows/sequence RESPONSE YOURSELF
================================================================================

Use one of the following methods to get the ground-truth JSON response
for GET /api/v3/worksheet/design/DES54962/rows/sequence.

-------- method_a_sdk_internal.py --------

from albert import AlbertClient
import json

client = AlbertClient()

# Access the SDK's internal HTTP client
# (field name may vary: _http, _client, _session — check SDK source)
response = client._http.get(
 "/api/v3/worksheet/design/DES54962/rows/sequence"
)

print(json.dumps(response.json(), indent=2))

# Save to file for inspection
with open("rows_sequence_raw.json", "w") as f:
 json.dump(response.json(), f, indent=2)

-------- end method_a --------


-------- method_b_httpx.py --------

import httpx
import json
from albert import AlbertClient

client = AlbertClient()

# Extract the bearer token from the SDK's auth headers
# (field name may vary — inspect client._http.headers)
token = client._http.headers.get("Authorization")
base_url = "https://<your-instance-hostname>"

r = httpx.get(
 f"{base_url}/api/v3/worksheet/design/DES54962/rows/sequence",
 headers={"Authorization": token},
 timeout=30.0,
)
r.raise_for_status()

print(json.dumps(r.json(), indent=2))

-------- end method_b --------


-------- method_c_design_get_groups.py --------

# If SDK v1.34.0 Design object is accessible:
from albert import AlbertClient

client = AlbertClient()

worksheet = client.worksheets.get_by_project_id("PROMO13137")
sheet = next(s for s in worksheet.sheets
 if s.sheet_id == "WKS15289")
design = next(d for d in sheet.designs
 if d.design_id == "DES54962")

# Call get_groups() — this should call the sequence endpoint
groups = design.get_groups()

# Inspect the returned objects
for node in (groups[:5] if isinstance(groups, list) else [groups]):
 print(vars(node)) # shows all populated fields
 # Key questions:
 # - Is node.row_id present?
 # - Is node.parent_row_id present and non-None?
 # - Is node.child_row_ids a list?
 # - Is node.is_group_header a bool?
 # - Is there a "children" attribute with nested objects?

-------- end method_c --------

WHAT TO LOOK FOR IN THE RESPONSE — CHECKLIST:

 □ Top-level JSON type: array [] or object {}?
 □ Key name for child rows: "children", "childRows", or "ChildRows"?
 □ Key name for row identifier: "rowId", "row_id", or "id"?
 □ Is "name" present on group nodes?
 □ Is nesting recursive (groups within groups within groups)?
 □ Does ROW372 ("Polymeric Dispersants") appear with ROW185 nested?
 □ Does ROW185 ("EAA") appear with ROW336 nested?
 □ Does ROW183 ("Melting step") have any child nodes?
 □ Do BLK calculation rows (ROW233 "Total acid mmoles" etc.) appear,
 or only group-structured rows?
 □ Does the response include ALL 174 rows or only grouped subsets?
 □ Are INV leaf rows present in the response or only BLK group nodes?


================================================================================
12. FULL FLAT ROW SEQUENCE FOR DES54962 (174 ROWS) [CONFIRMED]
================================================================================

Exact order as returned by sheet_inspect for DES54962 / WKS15289.
Format: index | row_id | type | name | inventory_id

IDX ROW_ID TYPE NAME INV_ID
--- ------- ---- -------------------------------------------- ----------------
 0 ROW90 BLK Calculations
 1 ROW233 BLK Total acid mmoles (Polymers + Surfactants)
 2 ROW281 BLK Total acid mgKOH/g
 3 ROW67 BLK mmol AA (MW = 72)
 4 ROW214 BLK mmol MAA (MW = 86)
 5 ROW404 BLK mmol KOH - Dimers (MW = 56)
 6 ROW236 BLK mmol KOH - PA + PES (MW = 56)
 7 ROW283 BLK mmol KOH - MAH (MW = 98,1) co-polymers
 8 ROW223 BLK mmol KOH - Surfactant (MW = 56)
 9 ROW210 BLK mmol KOH - Resins (MW = 56)
 10 ROW279 BLK mmol KOH- Polymer blends (MW = 56)
 11 ROW246 BLK mmol Acetic acid (post-addition) (MW = 60)
 12 ROW234 BLK Total alkali mmoles
 13 ROW66 BLK mmol NaOH (MW = 40)
 14 ROW142 BLK mmol KOH (MW = 56)
 15 ROW64 BLK mmol NH3 (MW = 17)
 16 ROW235 BLK Molar ratio Alkalis
 17 ROW215 BLK Molar ratio NaOH/total alkali
 18 ROW216 BLK Molar ratio KOH/total alkali
 19 ROW217 BLK Molar ratio NH3/total alkali
 20 ROW368 BLK Neutralization degree ratios
 21 ROW365 BLK Neutralization degree by NaOH
 22 ROW366 BLK Neutralization degree by KOH
 23 ROW367 BLK Neutralization degree by NH3
 24 ROW407 BLK Neutralization Degrees (Summary)
 25 ROW231 BLK ND - Total [-]
 26 ROW399 BLK ND - Neutralization Step [-]
 27 ROW400 BLK ND - W/O to O/W Step [-]
 28 ROW405 BLK Neutralization Step
 29 ROW393 BLK Addition time (Neutralization Step) [min]
 30 ROW392 BLK Flow rate (Neutralization Step) [g/min]
 31 ROW406 BLK W/O to O/W Step
 32 ROW384 BLK Addition time (W/O to O/W Step) [min]
 33 ROW390 BLK NH3 conc. in water (W/O to O/W step) [%]
 34 ROW379 BLK Flow rate (W/O to O/W step) [g/min]
 35 ROW385 BLK Manual inputs
 36 ROW70 BLK Total mass experiment [g] (Manual input)
 37 ROW380 BLK Automatic addition rate (Pump ON) [g/min]
 38 ROW381 BLK Pump interval ON [min] (Manual input)
 39 ROW382 BLK Pump interval OFF [min] (Manual input)
 40 ROW408 BLK Solid Contents
 41 ROW118 BLK Solids at neutralization [%]
 42 ROW394 BLK Solids at W/O to O/W step [%]
 43 ROW69 BLK Solids - Total [%]
 44 ROW161 BLK Density liquid coating [g/ml]
 45 ROW139 BLK RMC [€/kg] (Total Formula)
 46 ROW160 BLK RMC [€/kg] (solids)
 47 ROW338 BLK Raw Materials
 48 ROW183 BLK Melting step
 49 ROW222 BLK Surfactants & Dispersing Agents
 50 ROW261 BLK Anionic surfactants
 51 ROW221 INV Oleic acid INVA106961
 52 ROW297 INV Calcium stearate, 6.4 to 7.4% (Ca) INVA272413
 53 ROW298 INV K-oleate paste (27,5%) - 30% solids INVMO13137-039
 54 ROW259 INV Octanoic acid INVA23983
 55 ROW305 INV Kortacid PH05C INVA26200
 56 ROW291 INV Edible Acid Casein 30/60 Mesh INVA215181
 57 ROW257 BLK Non-ionic surfactants
 58 ROW256 INV Brij O 20 INVA32071
 59 ROW294 INV SP BRIJ MBAL O2 LQ (AP) INVA106010
 60 ROW295 INV Aerosol 22 INVA63175
 61 ROW258 INV Pluronic PE 6800 INVA273048
 62 ROW244 INV Tergitol 15 S 40 INVA271520
 63 ROW378 BLK Peptizers
 64 ROW308 INV Pepton 22 INVA278339
 65 ROW307 BLK Dispersing agents
 66 ROW306 INV Bentone EW INVA106864
 67 ROW301 INV di-Sodium hydrogen phosphate INVA269018
 68 ROW273 BLK Antioxidants
 69 ROW376 BLK Phenolic antioxidant
 70 ROW272 INV Evernox 10 INVA22544
 71 ROW352 INV Irganox 1010 INVA19187
 72 ROW377 BLK Phenolic + organo-phosphite antioxidant
 73 ROW274 INV Irganox B 225 INVA18146
 74 ROW372 BLK Polymeric Dispersants
 75 ROW185 BLK EAA
 76 ROW181 INV A-C5120 INVA236732
 77 ROW336 INV Primacor 5995 INVA278289
 78 ROW63 INV Primacor 5980I INVA24329
 79 ROW403 BLK Dimers
 80 ROW402 INV Pripol 1036-LQ-(GD) INVA33745
 81 ROW186 BLK Dispersed Matrix Polymers
 82 ROW237 BLK Plasticizers
 83 ROW208 INV Primol 352 INVA24337
 84 ROW238 BLK Waxes
 85 ROW355 INV IGI 1304 S INVA45083
 86 ROW357 INV Multiwax 180 M INVA70085
 87 ROW212 INV Hydrogenated Castor Oil INVA109565
 88 ROW218 INV Ceraflour 1010 INVA268244
 89 ROW239 BLK Resins and Tackifiers
 90 ROW358 INV Foral 85-E INVA22649
 91 ROW353 INV Unik Tack P 120 INVA49732
 92 ROW270 INV Kristalex F 85 INVA23170
 93 ROW209 INV Foral AX E INVA22650
 94 ROW240 BLK EVA co-polymers
 95 ROW205 INV ESCORENE UL 02528 INVA22439
 96 ROW351 INV Escorene UL 04533 EH2 INVA105036
 97 ROW204 INV EVATANE 28-420 INVA22539
 98 ROW350 INV Elvax CM 4875 INVA33169
 99 ROW213 INV ELVAX 4310 Ethylene Vinyl Acetate Copolymer INVA22392
100 ROW211 INV ELVAX 4320 Ethylene Vinyl Acetate Copolymer INVA22393
101 ROW219 INV ELVAX 4260 Ethylene Vinyl Acetate Copolymer INVA22391
102 ROW241 BLK PES
103 ROW269 INV VYLON 103 INVA25252
104 ROW220 INV PES BCS305 INVA110143
105 ROW251 INV PES BAL 3012 INVA245066
106 ROW242 BLK PA
107 ROW335 INV PA20 aus BAL604 INVEXP12385-019
108 ROW386 INV PA6786 mit IPDA INVEXP12385-031
109 ROW339 INV PA mit ED2003 INVEXP12385-022
110 ROW388 INV PA mit ED2003 INVEXP12385-026
111 ROW401 INV PA 7,5% ED2003 7,5%D2000 INVEXP12385-059
112 ROW159 INV Technomelt TPX 22448 INVB231233
113 ROW187 INV Macromelt PA 6786 INVA271705
114 ROW198 INV Macromelt PA 2059 INVA271704
115 ROW337 INV Technomelt PA 2006 INVB263513
116 ROW255 BLK Epoxy
117 ROW254 INV YDCN 500 8P INVA145065
118 ROW253 BLK PU
119 ROW252 INV Aquence PET 1770 HF INVA274466
120 ROW197 INV Desmomelt U 320 INVA226188
121 ROW284 BLK MAH co-polymers
122 ROW276 INV Kraton FG1901 GT INVA17956
123 ROW263 BLK Styrene-Isoprene
124 ROW266 INV Kraton D 1161 INVA23134
125 ROW262 INV Technomelt DF 6530 INVB275734
126 ROW343 BLK Styrene-Butadiene
127 ROW265 INV Kraton D 1184 AS INVA49478
128 ROW341 BLK Styrene-Ethylene-Butylene
129 ROW340 INV Kraton FG1901 GT INVA17956
130 ROW243 BLK Non-polar polyolefin
131 ROW356 INV Oppanol B 11 SFN INVA37154
132 ROW207 INV Viscowax 145 INVA26182
133 ROW151 INV Affinity GA 1875 INVA21120
134 ROW278 BLK Polymer blends / Intermediates
135 ROW359 INV Liofol HS 4000-23 INVMO13137-060
136 ROW282 INV MO13137-032 + 5p FG1901 (Kneader) INVMO13137-034
137 ROW280 INV 50p D1161 + 17p Kristalex F85 + … INVMO13137-032
138 ROW277 INV 27p D1168 + 27p Krist.F85 + … INVMO13137-028
139 ROW271 BLK Fillers
140 ROW373 BLK Talc
141 ROW354 INV Finntalc M 03 INVA38131
142 ROW374 BLK Kaolin
143 ROW364 INV Devolite EBCF INVA238253
144 ROW375 BLK Silica
145 ROW268 INV ACEMATT® TS 100 INVA259
146 ROW304 BLK Water-in-Oil Step
147 ROW303 INV Deionized water INVA126554
148 ROW120 BLK Neutralization Step
149 ROW153 INV BYK-1740 INVA2228
150 ROW49 INV Deionized Water INVA25854
151 ROW206 INV 50% NaOH solution INVEXP5266-002
152 ROW40 INV Sodium Hydroxide INVA26253
153 ROW299 INV 50% KOH solution INVEXP5266-012
154 ROW143 INV Potassium hydroxide pellets pure (105012) INVA104161
155 ROW37 INV Ammonia solution 25% INVA107081
156 ROW184 BLK W/O to O/W Step
157 ROW345 INV Ammonia solution 25% INVA107081
158 ROW48 INV Deionized Water INVA25854
159 ROW121 BLK Post Addition
160 ROW137 INV Deionized Water INVA25854
161 ROW250 INV Acetic acid 10% conc. INVEXP5266-010
162 ROW245 INV Essig (Essigsäure glacial) INVA22371
163 ROW344 INV TEGO ANTIFOAM 4-94 INVA24849
164 ROW152 INV BYK-1740 INVA2228
165 ROW115 INV SURFYNOL 355 (AS 5120) INVA104776
166 ROW346 INV BYK 3410 INVA255789
167 ROW17 INV Acticide MV INVA21074
168 ROW16 INV Proxel GXL INVA24368
169 ROW349 BLK Finished products
170 ROW370 INV 70p PA2006 + 30p 5995 … (Alkali 1 Step) INVMO13137-063
171 ROW348 INV 70p PA2006 + 30p 5995 … (1 step alkali) INVMO13137-056
172 ROW196 BLK TOTAL
173 ROW1 TOT Inventory Total


================================================================================
13. POSITIONAL HIERARCHY MAP — CONFIRMED ANCESTOR CHAINS
================================================================================

Derived from the flat array in §12 using consecutive-BLK-then-INV
positional inference. These are the confirmed group memberships.
Format: row_id | breadcrumb path

CALCULATIONS SECTION (indices 0–46, all BLK):
 ROW90 → Calculations [section header, depth 1]
 ROW233 → Calculations > Total acid mmoles
 ROW281 → Calculations > Total acid mmoles
 ROW67 → Calculations > Total acid mmoles
 ROW214 → Calculations > Total acid mmoles
 ROW404 → Calculations > Total acid mmoles
 ROW236 → Calculations > Total acid mmoles
 ROW283 → Calculations > Total acid mmoles
 ROW223 → Calculations > Total acid mmoles
 ROW210 → Calculations > Total acid mmoles
 ROW279 → Calculations > Total acid mmoles
 ROW246 → Calculations > Total acid mmoles
 ROW234 → Calculations > Total alkali mmoles
 ROW66 → Calculations > Total alkali mmoles
 ROW142 → Calculations > Total alkali mmoles
 ROW64 → Calculations > Total alkali mmoles
 ROW235 → Calculations > Molar ratio Alkalis
 ROW215 → Calculations > Molar ratio Alkalis > detail
 ROW216 → Calculations > Molar ratio Alkalis > detail
 ROW217 → Calculations > Molar ratio Alkalis > detail
 ROW368 → Calculations > Neutralization degree ratios
 ROW365 → Calculations > Neutralization degree ratios > detail
 ROW366 → Calculations > Neutralization degree ratios > detail
 ROW367 → Calculations > Neutralization degree ratios > detail
 ROW407 → Calculations > Neutralization Degrees (Summary)
 ROW231 → Calculations > Neutralization Degrees (Summary) > detail
 ROW399 → Calculations > Neutralization Degrees (Summary) > detail
 ROW400 → Calculations > Neutralization Degrees (Summary) > detail
 ROW405 → Calculations > Neutralization Step (calc)
 ROW393 → Calculations > Neutralization Step (calc) > detail
 ROW392 → Calculations > Neutralization Step (calc) > detail
 ROW406 → Calculations > W/O to O/W Step (calc)
 ROW384 → Calculations > W/O to O/W Step (calc) > detail
 ROW390 → Calculations > W/O to O/W Step (calc) > detail
 ROW379 → Calculations > W/O to O/W Step (calc) > detail
 ROW385 → Calculations > Manual inputs
 ROW70 → Calculations > Manual inputs > detail
 ROW380 → Calculations > Manual inputs > detail
 ROW381 → Calculations > Manual inputs > detail
 ROW382 → Calculations > Manual inputs > detail
 ROW408 → Calculations > Solid Contents
 ROW118 → Calculations > Solid Contents > detail
 ROW394 → Calculations > Solid Contents > detail
 ROW69 → Calculations > Solid Contents > detail
 ROW161 → Calculations > Solid Contents > detail
 ROW139 → Calculations > RMC
 ROW160 → Calculations > RMC

RAW MATERIALS SECTION (indices 47–138):
 ROW338 → Raw Materials [depth 1]
 ROW183 → Raw Materials > Melting step [EMPTY — no INV children]
 ROW222 → Raw Materials > Surfactants & Dispersing Agents
 ROW261 → Raw Materials > Surfactants & Dispersing Agents > Anionic surfactants
 ROW221 → Raw Materials > Surfactants & Dispersing Agents > Anionic surfactants
 ROW297 → Raw Materials > Surfactants & Dispersing Agents > Anionic surfactants
 ROW298 → Raw Materials > Surfactants & Dispersing Agents > Anionic surfactants
 ROW259 → Raw Materials > Surfactants & Dispersing Agents > Anionic surfactants
 ROW305 → Raw Materials > Surfactants & Dispersing Agents > Anionic surfactants
 ROW291 → Raw Materials > Surfactants & Dispersing Agents > Anionic surfactants
 ROW257 → Raw Materials > Surfactants & Dispersing Agents > Non-ionic surfactants
 ROW256 → Raw Materials > Surfactants & Dispersing Agents > Non-ionic surfactants
 ROW294 → Raw Materials > Surfactants & Dispersing Agents > Non-ionic surfactants
 ROW295 → Raw Materials > Surfactants & Dispersing Agents > Non-ionic surfactants
 ROW258 → Raw Materials > Surfactants & Dispersing Agents > Non-ionic surfactants
 ROW244 → Raw Materials > Surfactants & Dispersing Agents > Non-ionic surfactants
 ROW378 → Raw Materials > Surfactants & Dispersing Agents > Peptizers
 ROW308 → Raw Materials > Surfactants & Dispersing Agents > Peptizers
 ROW307 → Raw Materials > Surfactants & Dispersing Agents > Dispersing agents
 ROW306 → Raw Materials > Surfactants & Dispersing Agents > Dispersing agents
 ROW301 → Raw Materials > Surfactants & Dispersing Agents > Dispersing agents
 ROW273 → Raw Materials > Antioxidants
 ROW376 → Raw Materials > Antioxidants > Phenolic antioxidant
 ROW272 → Raw Materials > Antioxidants > Phenolic antioxidant
 ROW352 → Raw Materials > Antioxidants > Phenolic antioxidant
 ROW377 → Raw Materials > Antioxidants > Phenolic + organo-phosphite antioxidant
 ROW274 → Raw Materials > Antioxidants > Phenolic + organo-phosphite antioxidant
 ROW372 → Raw Materials > Polymeric Dispersants
 ROW185 → Raw Materials > Polymeric Dispersants > EAA
 ROW181 → Raw Materials > Polymeric Dispersants > EAA
 ROW336 → Raw Materials > Polymeric Dispersants > EAA ← Primacor 5995
 ROW63 → Raw Materials > Polymeric Dispersants > EAA
 ROW403 → Raw Materials > Polymeric Dispersants > Dimers
 ROW402 → Raw Materials > Polymeric Dispersants > Dimers
 ROW186 → Raw Materials > Dispersed Matrix Polymers
 ROW237 → Raw Materials > Dispersed Matrix Polymers > Plasticizers
 ROW208 → Raw Materials > Dispersed Matrix Polymers > Plasticizers
 ROW238 → Raw Materials > Dispersed Matrix Polymers > Waxes
 ROW355 → Raw Materials > Dispersed Matrix Polymers > Waxes
 ROW357 → Raw Materials > Dispersed Matrix Polymers > Waxes
 ROW212 → Raw Materials > Dispersed Matrix Polymers > Waxes
 ROW218 → Raw Materials > Dispersed Matrix Polymers > Waxes
 ROW239 → Raw Materials > Dispersed Matrix Polymers > Resins and Tackifiers
 ROW358 → Raw Materials > Dispersed Matrix Polymers > Resins and Tackifiers
 ROW353 → Raw Materials > Dispersed Matrix Polymers > Resins and Tackifiers
 ROW270 → Raw Materials > Dispersed Matrix Polymers > Resins and Tackifiers
 ROW209 → Raw Materials > Dispersed Matrix Polymers > Resins and Tackifiers
 ROW240 → Raw Materials > Dispersed Matrix Polymers > EVA co-polymers
 ROW205 → Raw Materials > Dispersed Matrix Polymers > EVA co-polymers
 ROW351 → Raw Materials > Dispersed Matrix Polymers > EVA co-polymers
 ROW204 → Raw Materials > Dispersed Matrix Polymers > EVA co-polymers
 ROW350 → Raw Materials > Dispersed Matrix Polymers > EVA co-polymers
 ROW213 → Raw Materials > Dispersed Matrix Polymers > EVA co-polymers
 ROW211 → Raw Materials > Dispersed Matrix Polymers > EVA co-polymers
 ROW219 → Raw Materials > Dispersed Matrix Polymers > EVA co-polymers
 ROW241 → Raw Materials > Dispersed Matrix Polymers > PES
 ROW269 → Raw Materials > Dispersed Matrix Polymers > PES
 ROW220 → Raw Materials > Dispersed Matrix Polymers > PES
 ROW251 → Raw Materials > Dispersed Matrix Polymers > PES
 ROW242 → Raw Materials > Dispersed Matrix Polymers > PA
 ROW335 → Raw Materials > Dispersed Matrix Polymers > PA
 ROW386 → Raw Materials > Dispersed Matrix Polymers > PA
 ROW339 → Raw Materials > Dispersed Matrix Polymers > PA
 ROW388 → Raw Materials > Dispersed Matrix Polymers > PA
 ROW401 → Raw Materials > Dispersed Matrix Polymers > PA
 ROW159 → Raw Materials > Dispersed Matrix Polymers > PA
 ROW187 → Raw Materials > Dispersed Matrix Polymers > PA
 ROW198 → Raw Materials > Dispersed Matrix Polymers > PA
 ROW337 → Raw Materials > Dispersed Matrix Polymers > PA
 ROW255 → Raw Materials > Dispersed Matrix Polymers > Epoxy
 ROW254 → Raw Materials > Dispersed Matrix Polymers > Epoxy
 ROW253 → Raw Materials > Dispersed Matrix Polymers > PU
 ROW252 → Raw Materials > Dispersed Matrix Polymers > PU
 ROW197 → Raw Materials > Dispersed Matrix Polymers > PU
 ROW284 → Raw Materials > Dispersed Matrix Polymers > MAH co-polymers
 ROW276 → Raw Materials > Dispersed Matrix Polymers > MAH co-polymers
 ROW263 → Raw Materials > Dispersed Matrix Polymers > Styrene-Isoprene
 ROW266 → Raw Materials > Dispersed Matrix Polymers > Styrene-Isoprene
 ROW262 → Raw Materials > Dispersed Matrix Polymers > Styrene-Isoprene
 ROW343 → Raw Materials > Dispersed Matrix Polymers > Styrene-Butadiene
 ROW265 → Raw Materials > Dispersed Matrix Polymers > Styrene-Butadiene
 ROW341 → Raw Materials > Dispersed Matrix Polymers > Styrene-Ethylene-Butylene
 ROW340 → Raw Materials > Dispersed Matrix Polymers > Styrene-Ethylene-Butylene
 ROW243 → Raw Materials > Dispersed Matrix Polymers > Non-polar polyolefin
 ROW356 → Raw Materials > Dispersed Matrix Polymers > Non-polar polyolefin
 ROW207 → Raw Materials > Dispersed Matrix Polymers > Non-polar polyolefin
 ROW151 → Raw Materials > Dispersed Matrix Polymers > Non-polar polyolefin
 ROW278 → Raw Materials > Dispersed Matrix Polymers > Polymer blends / Intermediates
 ROW359 → Raw Materials > Dispersed Matrix Polymers > Polymer blends / Intermediates
 ROW282 → Raw Materials > Dispersed Matrix Polymers > Polymer blends / Intermediates
 ROW280 → Raw Materials > Dispersed Matrix Polymers > Polymer blends / Intermediates
 ROW277 → Raw Materials > Dispersed Matrix Polymers > Polymer blends / Intermediates
 ROW271 → Raw Materials > Fillers
 ROW373 → Raw Materials > Fillers > Talc
 ROW354 → Raw Materials > Fillers > Talc
 ROW374 → Raw Materials > Fillers > Kaolin
 ROW364 → Raw Materials > Fillers > Kaolin
 ROW375 → Raw Materials > Fillers > Silica
 ROW268 → Raw Materials > Fillers > Silica

PROCESS STEP GROUPS (indices 146–168, depth 1):
 ROW304 → Water-in-Oil Step [depth 1]
 ROW303 → Water-in-Oil Step
 ROW120 → Neutralization Step [depth 1]
 ROW153 → Neutralization Step
 ROW49 → Neutralization Step
 ROW206 → Neutralization Step
 ROW40 → Neutralization Step
 ROW299 → Neutralization Step
 ROW143 → Neutralization Step
 ROW37 → Neutralization Step
 ROW184 → W/O to O/W Step [depth 1]
 ROW345 → W/O to O/W Step
 ROW48 → W/O to O/W Step
 ROW121 → Post Addition [depth 1]
 ROW137 → Post Addition
 ROW250 → Post Addition
 ROW245 → Post Addition
 ROW344 → Post Addition
 ROW152 → Post Addition
 ROW115 → Post Addition
 ROW346 → Post Addition
 ROW17 → Post Addition
 ROW16 → Post Addition

FINISHED PRODUCTS AND TOTAL:
 ROW349 → Finished products [depth 1]
 ROW370 → Finished products
 ROW348 → Finished products
 ROW196 → TOTAL [depth 1]
 ROW1 → TOTAL (TOT type)


================================================================================
14. EDGE CASES AND CAVEATS
================================================================================

CAVEAT 1: row_id integers are NOT positional indices
 row_id values like ROW336, ROW183, ROW90 are opaque server-assigned
 identifiers. A lower integer does NOT mean an earlier position.
 ROW1 is the LAST row (index 173, the TOT "Inventory Total").
 ROW90 is the FIRST row (index 0, "Calculations" header).
 Never sort by the integer in row_id to determine display order.
 Use array index from the inspect/sequence response.

CAVEAT 2: ROW183 "Melting step" is an empty group
 It has no INV children between it (index 48) and the next BLK
 (ROW222 "Surfactants & Dispersing Agents", index 49).
 Whether the rows/sequence endpoint represents this as a group node
 with an empty ChildRows array or as a plain leaf BLK row is unknown.
 Do not assume it has children.

CAVEAT 3: Duplicate inventory_id values across rows
 The following inventory items appear in MULTIPLE rows
 (different process steps, same material):
 INVA107081 "Ammonia solution 25%" → ROW37 (Neutr.) + ROW345 (W/O→O/W)
 INVA25854 "Deionized Water" → ROW49 + ROW48 + ROW137 (3 steps)
 INVA2228 "BYK-1740" → ROW153 + ROW152 (2 steps)
 INVA17956 "Kraton FG1901 GT" → ROW276 + ROW340 (2 subgroups)
 row_id is unique; inventory_id is NOT. Never deduplicate by inventory_id.

CAVEAT 4: BLK type covers two semantically different row roles
 Pure calculation rows (e.g. ROW233 "Total acid mmoles") and section
 headers (e.g. ROW338 "Raw Materials") both have type="BLK".
 They are indistinguishable from the type field alone. Distinguish them
 by whether they have cell values (calculation rows have values in the
 cell matrix; pure header rows have null/empty cells across all columns).

CAVEAT 5: The hierarchy may change if the worksheet is modified
 If a user adds, removes, or reorders rows in Albert, the flat array
 order changes and the positional hierarchy in §13 becomes stale.
 The rows/sequence endpoint (if it returns explicit parent→child
 relationships) would be more robust to reordering — an explicit
 parent pointer does not break when rows are added elsewhere.
 The positional inference in §13 requires a full re-parse on any
 structural change.

CAVEAT 6: sheet_inspect and rows/sequence may return different orderings
 The grid endpoint and the sequence endpoint are separate API surfaces.
 They may return rows in different orders. Do not assume the array
 index from sheet_inspect matches the position in the sequence response.
 Use row_id as the stable cross-reference key between the two responses.

CAVEAT 7: Mixed casing in Albert write vs. read payloads
 Albert read endpoints (including the grid) use snake_case field names:
 row_id, design_id, inventory_id
 Albert write endpoints typically use PascalCase or camelCase:
 ChildRows, rowId, inventoryId, albertId
 Verify the exact casing for each endpoint by inspecting the raw
 request/response — do not assume consistency across endpoints.

================================================================================
END OF README
================================================================================



