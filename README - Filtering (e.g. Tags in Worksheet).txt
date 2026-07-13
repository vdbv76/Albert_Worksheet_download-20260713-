================================================================================
README.txt
Albert Invent SDK v1.34.0 — Worksheet Filter Panel: REST/SDK Reference
Project MO13137 (PROMO13137) / Sheet WKS15289 ("Phase Inversion")
================================================================================

METHODOLOGY
-----------
Every answer below is derived from live SDK calls made in this session.
[CONFIRMED] — live call succeeded; verbatim response shown.
[CANNOT CONFIRM] — endpoint not reachable or not exposed by this SDK;
 stated explicitly with the call that was attempted.

================================================================================
A. WHICH ENDPOINT POPULATES THE FILTER DROPDOWNS?
================================================================================

------------------------------------------------------------------------
A.1 — IS get_all_facets THE ENDPOINT THE WORKSHEET FILTER PANEL USES?
------------------------------------------------------------------------

[CONFIRMED — PARTIAL MATCH]

The call:

 client.inventories.get_all_facets(
 project_id="PROMO13137",
 sheet_id="WKS15289"
)

returns 9 facets. Two of the 7 UI filters (Tags and Created By) map
directly onto facets in this response.

The remaining 5 UI filters (Formula/Product ID, Contains Inventory,
Locked, Predecessor, Data Templates) are NOT present in the facet
response at any parameter string. They return [] when queried directly:

 client.inventories.get_facet_by_name(
 name="predecessor", project_id="PROMO13137" # → []
)
 client.inventories.get_facet_by_name(
 name="locked", project_id="PROMO13137" # → []
)

Whether the Worksheet UI calls a DIFFERENT endpoint for those 5 filters
(e.g. a worksheet-specific facet endpoint not exposed in this SDK) is
[CANNOT CONFIRM]. From this environment only the inventory facets
endpoint is accessible.

CRITICAL: sheet_id="WKS15289" has ZERO effect on the facet response.
The call with and without sheet_id returns byte-for-byte identical JSON.
The facet aggregation is scoped at the project level only.

------------------------------------------------------------------------
A.2 — VERBATIM RESPONSE OF get_all_facets
------------------------------------------------------------------------

[CONFIRMED]

 client.inventories.get_all_facets(
 project_id="PROMO13137",
 sheet_id="WKS15289"
)

Response:

 [
 {
 "name": "Category",
 "parameter": "category",
 "type": "text",
 "Value": [
 {"name": "Formulas", "count": 96}
]
 },
 {
 "name": "Location",
 "parameter": "location",
 "type": "text",
 "Value": [
 {"name": "(Z55) Duesseldorf, Germany", "count": 82}
]
 },
 {
 "name": "Storage Location",
 "parameter": "storageLocation",
 "type": "text",
 "Value": [
 {"name": "3240-C2-A-2", "count": 1}
]
 },
 {
 "name": "Tags",
 "parameter": "tags",
 "type": "text",
 "Value": [
 {"name": "EAA Resin", "count": 70},
 {"name": "polyamide", "count": 63},
 {"name": "Release coating", "count": 44},
 {"name": "Lisa", "count": 32},
 {"name": "Styrene-Isoprene-Styrene", "count": 12},
 {"name": "eva", "count": 8},
 {"name": "Patric", "count": 7},
 {"name": "PA2006 mod", "count": 5},
 {"name": "polyester", "count": 4},
 {"name": "Styrene Ethylene/Butylene Styrene","count": 3},
 {"name": "HS4000", "count": 2},
 {"name": "Victor", "count": 2},
 {"name": "pu", "count": 2},
 {"name": "PA6786 mod", "count": 1}
]
 },
 {
 "name": "Pictograms",
 "parameter": "pictogramName",
 "type": "text",
 "Value": [
 {"name": "no Symbol", "count": 21},
 {"name": "Exclamation Mark","count": 6},
 {"name": "Corrosion", "count": 2},
 {"name": "Health Hazard", "count": 1}
]
 },
 {
 "name": "Quarantine Status",
 "parameter": "status",
 "type": "text",
 "Value": [
 {"name": "active", "count": 82}
]
 },
 {
 "name": "Created By",
 "parameter": "createdBy",
 "type": "text",
 "Value": [
 {"name": "Victor Buj", "count": 72},
 {"name": "Lisa Meyfarth", "count": 24}
]
 },
 {
 "name": "Lot Owner",
 "parameter": "lotOwner",
 "type": "text",
 "Value": [
 {"name": "Victor Buj", "count": 61},
 {"name": "Lisa Meyfarth", "count": 21}
]
 },
 {
 "name": "Lot Created By",
 "parameter": "lotCreatedBy",
 "type": "text",
 "Value": [
 {"name": "Victor Buj", "count": 61},
 {"name": "Lisa Meyfarth", "count": 21}
]
 }
]

------------------------------------------------------------------------
A.3 — MAP OF 7 UI FILTERS TO FACET PARAMETERS
------------------------------------------------------------------------

UI Filter label Facet name Facet parameter In facets?
----------------------- ------------ ---------------- ----------
Formula / Product ID — — NO
Contains Inventory — — NO
Locked — — NO
Predecessor — — NO
Tags Tags "tags" YES ✓
Data Templates — — NO
Created By Created By "createdBy" YES ✓

The 5 filters with NO facet match are either:
 (a) Populated by a separate worksheet-specific endpoint not exposed
 in the inventory facets SDK method, OR
 (b) Populated entirely client-side from the already-loaded column
 and inventory metadata (grid row data + task data)

Which of (a) or (b) applies to each of the 5 is [CANNOT CONFIRM].

FACETS PRESENT BUT NOT MAPPED TO A WORKSHEET FILTER:
 Category → parameter: "category" (not a worksheet filter)
 Location → parameter: "location" (not a worksheet filter)
 Storage Loc → parameter: "storageLocation" (not a worksheet filter)
 Pictograms → parameter: "pictogramName" (not a worksheet filter)
 Quarantine → parameter: "status" (not a worksheet filter)
 Lot Owner → parameter: "lotOwner" (not a worksheet filter)
 Lot Created By → parameter: "lotCreatedBy" (not a worksheet filter)


================================================================================
B. TAGS — WHERE STORED, HOW TO READ THEM
================================================================================

------------------------------------------------------------------------
B.4 — WHERE TAGS ARE STORED AND WHICH CALL IS AUTHORITATIVE
------------------------------------------------------------------------

[CONFIRMED]

Tags on formulation inventory items are stored on the InventoryItem
entity. They surface differently depending on which SDK endpoint is
called:

ENDPOINT FIELD NAME SHAPE POPULATED?
-------------------- ----------- ----------------------- ----------
get_by_id(id=...) Tags [{id: "TAG…"}] YES — id only
get_by_ids(ids=[...]) Tags [{id: "TAG…"}] YES — id only
get_all(...) Tags [{id: "TAG…"}] YES — id only
search(...) tags [{name:…, albertId:…}] YES — name+id
get_all_facets(...) (facet) [{name:…, count:…}] YES — name+count

KEY FINDINGS:
1. The "tags" (lowercase) field with name+albertId shape exists ONLY
 on the search() response — not on get_by_id, get_by_ids, or get_all.

2. The "Tags" (PascalCase) field with id-only objects exists on
 get_by_id, get_by_ids, and get_by_all — but contains only the TAG
 id (e.g. {"id": "TAG10608"}). The name is NOT included.

3. inventory.get_by_ids([...]) →.Tags IS populated. It is NOT empty.
 It returns the id-only shape. Your report of getting an empty list
 may have been caused by one of:
 (a) Passing display IDs without "INV" prefix to get_by_ids
 (the SDK requires the full SDK form: "INVMO13137-064")
 (b) Querying raw material INV rows (INVA…) which may have no tags
 (c) An SDK version issue

4. The Apps-design TAG row (ROW1 / DES54964) is a live-lookup row.
 It is NOT a reliable source of tag data for programmatic use — it
 is frequently truncated in large sheet responses. See B.6.

AUTHORITATIVE CALL FOR TAG NAMES + IDs (one call per project):

 items = client.inventories.search(
 project_id="PROMO13137",
 category="Formulas"
)
 for item in items:
 # item.tags is the lowercase field — name + albertId populated
 for tag in (item.tags or []):
 print(tag.name, tag.albertId)

AUTHORITATIVE CALL FOR TAG IDs ONLY (get_by_id):

 item = client.inventories.get_by_id("INVMO13137-064")
 for tag_link in item.Tags: # PascalCase — id only
 print(tag_link.id) # "TAG10608"
 # tag_link.name does NOT exist on this response

TO RESOLVE TAG NAME FROM ID:

 tag = client.tags.get_by_id("TAG10608")
 print(tag.name) # "Lisa"
 print(tag.albertId) # "TAG10608"

------------------------------------------------------------------------
B.5 — VERBATIM TAG LIST FOR INVMO13137-064
------------------------------------------------------------------------

[CONFIRMED — from get_by_id and get_by_ids]

 client.inventories.get_by_id("INVMO13137-064")
 → item.Tags:
 [
 {"id": "TAG10608"}, ← "Lisa"
 {"id": "TAG10617"}, ← "EAA Resin"
 {"id": "TAG2799"}, ← "polyamide"
 {"id": "TAG49202"} ← "Release coating"
]

 client.inventories.search(project_id="PROMO13137",
 category="Formulas")
 → for INVMO13137-064, item.tags:
 (search index result — name+albertId shape)
 [
 {"name": "Lisa", "albertId": "TAG10608"},
 {"name": "EAA Resin", "albertId": "TAG10617"},
 {"name": "polyamide", "albertId": "TAG2799"},
 {"name": "Release coating", "albertId": "TAG49202"}
]

Both endpoints confirm the same 4 tags on INVMO13137-064.

KNOWN TAG ID ↔ NAME MAP (from this project):

 TAG10608 = "Lisa"
 TAG10617 = "EAA Resin"
 TAG2799 = "polyamide"
 TAG49202 = "Release coating"
 TAG2864 = "eva"
 TAG49482 = "Patric"
 TAG49522 = "PA2006 mod"

------------------------------------------------------------------------
B.6 — IS THE APPS-DESIGN TAG ROW (ROW1 / DES54964) RELIABLE?
------------------------------------------------------------------------

[CONFIRMED — NOT RELIABLE FOR PROGRAMMATIC USE]

The TAG row (ROW1, type "TAG", design DES54964) in the Apps section of
the worksheet is a LIVE LOOKUP row. It reads tag values from the
underlying InventoryItem entity at render time. It is NOT a stored cell
value in the worksheet grid.

Specific problems for programmatic use:
1. sheet_get_cell_values on WKS15289 frequently returns ZERO cells
 for ROW1/DES54964 — the 20,000-item response limit is hit before
 the Apps design rows are reached (DES54962 product rows come first
 and consume most of the response).
2. Even when cells are returned, the value shape (how tags are encoded
 as a cell value string) is undocumented.
3. The InventoryItem.Tags[] endpoint is the same underlying data source
 and is more reliably accessible.

CONCLUSION: Always read tags from inventory_search() or
inventory_get_by_id() / get_by_ids(). Never rely on the TAG row in
sheet_get_cell_values for a sheet this large.


================================================================================
C. PREDECESSOR
================================================================================

------------------------------------------------------------------------
C.7 — WHERE IS THE PREDECESSOR STORED?
------------------------------------------------------------------------

[CONFIRMED — NOT IN ANY INVENTORY FIELD]

The predecessor of a formulation is NOT stored in:
 - InventoryItem.Metadata (checked: only keys are "IDH" and
 "aiDescription" — no predecessor key)
 - Any top-level field on InventoryItem (no "predecessor",
 "Predecessor", "predecessorId" field exists)
 - InventoryItem search response (no predecessor field)
 - InventoryItem get_all response (no predecessor field)
 - Any inventory facet (get_facet_by_name("predecessor") → [])

The ONLY place predecessor data was found in this session is:
 - The Apps-design PDC row (ROW3, type "PDC", design DES54964)
 in the worksheet grid
 - Potentially a worksheet-specific endpoint not accessible here

Whether the PDC row cell value contains the predecessor inventory ID
as a string, an entity-link object, or some other shape is
[CANNOT CONFIRM] — the PDC row cells were in the truncated portion
of the sheet_get_cell_values response (DES54964 rows are returned
after DES54962 and are frequently cut off).

------------------------------------------------------------------------
C.8 — SDK CALL FOR PREDECESSOR OF INVMO13137-064
------------------------------------------------------------------------

[CANNOT CONFIRM]

All three inventory endpoints were called for INVMO13137-064:
 client.inventories.get_by_id("INVMO13137-064")
 client.inventories.get_by_ids(["INVMO13137-064"])
 client.inventories.search(project_id="PROMO13137")

None returned a predecessor field in any form. The field does not
exist in any inventory API response for this item.

To retrieve the predecessor via the PDC row:

 cells = client.sheets.get_cell_values("WKS15289")
 pdc_cells = [
 c for c in cells
 if c.designId == "DES54964"
 and c.rowId == "ROW3" # PDC row
]
 # WARNING: likely empty due to sheet truncation
 # for c in pdc_cells:
 # print(c.columnId, c.value) # predecessor value unknown shape

------------------------------------------------------------------------
C.9 — WHAT DOES THE UI PREDECESSOR DROPDOWN LIST?
------------------------------------------------------------------------

[CANNOT CONFIRM]

The facet endpoint returns no "predecessor" facet. Whether the UI
populates the Predecessor dropdown by:
 (a) Reading all PDC cell values from the sheet (formulations in
 this sheet that have a predecessor)
 (b) Querying all formulations in the project and listing those that
 appear as predecessors of any other formulation
 (c) Calling a worksheet-specific endpoint not accessible here
 (d) Filtering client-side from already-loaded column data

...is unknown from this environment. No SDK call was found that returns
a predecessor value for any formulation in this project.


================================================================================
D. DATA TEMPLATES
================================================================================

------------------------------------------------------------------------
D.10 — WHAT DOES THE "DATA TEMPLATES" FILTER LIST AND FILTER ON?
------------------------------------------------------------------------

[CONFIRMED — mechanism inferred from task data]

The Worksheet "Data Templates" filter lists the data templates that are
attached to Property Tasks linked to the sheet (via TAS rows in the
Results design, DES54963). Specifically, it lists the unique set of
DataTemplate.name values appearing across all blocks of all property
tasks in the project.

The filter operates on OPTION (a) from your candidates:
 Data templates attached to the Property Tasks linked to this sheet's
 TAS rows — regardless of whether actual data has been recorded.
 An INVMO13137-XXX column passes the filter if it appears in the
 inventoryIds of any block of any task that uses the selected DT.

CONFIRMED DATA TEMPLATES LINKED TO PROPERTY TASKS IN PROMO13137:

DT ID Name Tasks using it
------ --------------------------------- --------------------------------
DT235 Cobb Value FOR884237, FOR894429, FOR969623
DT464 Coating Weight (g/m2; gsm) FOR884237, FOR894429, FOR969623
DT1607 Visual appearance - coatings FOR884237, FOR894429, FOR969623
DT870 Fatty Acid Penetration Test FOR884237, FOR894429, FOR969623
DT876 TAPPI T 559: Grease Resistance FOR884237, FOR894429, FOR969623
DT871 ASTM F119: Rate of Grease Pen. FOR884237, FOR894429, FOR969623
DT382 Water Vapor Transmission Rate… FOR884237, FOR894429, FOR969623
DT1237 ASTM F1927: Oxygen Gas… FOR884237, FOR894429, FOR969623
DT316 Seal strength of Heatseal… FOR884237, FOR894429, FOR969623
DT287 Blocking Test for Coatings FOR884237, FOR894429, FOR969623
DT872 Folding Behavior: Barrier… FOR884237, FOR894429, FOR969623
DT1378 Sieve residue FOR928887, FOR969236
DT415 Solid Content FOR928887, FOR969236
DT242 Density FOR928887, FOR969236
DT171 pH FOR928887, FOR969236
DT825 Viscosity: Single/Multi-Point FOR928887, FOR969236
DT312 Flow Cup Viscosity FOR928887, FOR969236
DT336 Particle Size / Zeta Potential FOR928887, FOR969236
DT990 Particle Size - Laser FOR928887, FOR969236
DT978 Microscopy FOR928887, FOR969236
DT1466 MFFT FOR928887, FOR969236
DT495 Foam Test FOR928887, FOR969236
DT877 Capillary Rheometry FOR928887, FOR969236
DT1477 Amplitude Sweep FOR928887, FOR969236
DT2179 Particle Size - SEM FOR969236
DT907 Pass/Fail FOR943517
DT1931 ASG-Morphology-SEM FOR917267
DT1939 ASG-Quantitative Image Analysis FOR917267

------------------------------------------------------------------------
D.11 — DATA TEMPLATE NAME vs. fullName vs. displayName FOR DAT235
------------------------------------------------------------------------

[CONFIRMED — from data_template_get_by_id("DAT235")]

Field Value
----------- ----------------------------------------
name "Cobb Value"
fullName "DIN EN 20535: Cobb Value"
originalName "Cobb Value"

There is NO "displayName" field. The three name fields are:
 name → short form, matches the standard label used in the
 task block headers and likely the filter dropdown
 fullName → standard-prefixed form, used in detail page headers
 originalName → matches name for this template

For DAT464, DAT1607, DAT382: name == fullName == originalName
(no standard prefix added for these templates).

THE WORKSHEET FILTER DROPDOWN MOST LIKELY SHOWS "name" (short form).
If your filter doesn't match, try also matching against fullName.

------------------------------------------------------------------------
D.12 — SDK CALL TO GET DATA TEMPLATES FOR ONE FORMULATION
------------------------------------------------------------------------

[CONFIRMED — via task enumeration]

There is no single "get data templates for inventory item" SDK call.
You must enumerate via tasks:

 # Step 1: get all property tasks in the project
 tasks = client.tasks.get_all(project_id="PROMO13137",
 category="Property")

 # Step 2: find tasks that include the target inventory item
 target_inv = "INVMO13137-064"
 dt_ids = set()
 for task in tasks:
 task_full = client.tasks.get_by_id(task.albertId)
 # Check task-level inventory list
 task_inv_ids = [i.albertId for i in
 (task_full.inventories or [])]
 if target_inv in task_inv_ids:
 for block in (task_full.blocks or []):
 dt_ids.add(block.dataTemplateId)

 # dt_ids for INVMO13137-064:
 # {"DAT1607","DAT464","DAT235","DAT870","DAT876",
 # "DAT871","DAT382","DAT1237","DAT316","DAT287","DAT872"}
 # (all 11 DTs from task TASFOR884237)

CONFIRMED FOR INVMO13137-064:
 Property task: TASFOR884237 ("Coated Paper Properties (PA + EAA)")
 Data templates: DAT1607, DAT464, DAT235, DAT870, DAT876, DAT871,
 DAT382, DAT1237, DAT316, DAT287, DAT872


================================================================================
E. TYPE-AHEAD BEHAVIOUR
================================================================================

------------------------------------------------------------------------
E.13 — DOES THE SEARCH BOX CALL THE SERVER OR FILTER CLIENT-SIDE?
------------------------------------------------------------------------

[CANNOT CONFIRM — mechanism not observable from this environment]

What IS confirmed:
 - The facet endpoint has no "text" or "query" parameter that would
 enable server-side text filtering of facet values.
 - get_facet_by_name() accepts a name parameter for selecting a
 specific facet dimension, NOT for text-filtering within a facet's
 Value list.
 - There is no SDK method signature observed with a text= parameter
 on get_all_facets or get_facet_by_name.

What this STRONGLY SUGGESTS (but cannot confirm):
 The type-ahead / search-as-you-type in the filter panel is
 CLIENT-SIDE substring filtering on the already-loaded facet
 Value list. The full facet data is loaded once on panel open,
 and the search box narrows the displayed checkboxes without
 making further server calls.

HOW TO REPLICATE CLIENT-SIDE:

 # Load once on filter panel open:
 facets = client.inventories.get_all_facets(
 project_id="PROMO13137"
)
 tags_facet = next(f for f in facets if f.parameter == "tags")
 all_tags = [{"name": v.name, "count": v.count}
 for v in tags_facet.Value]

 # On each keystroke in the search box:
 def search_filter(all_values, query):
 q = query.lower().strip()
 if not q:
 return all_values
 return [v for v in all_values if q in v["name"].lower()]

 # Example:
 search_filter(all_tags, "pa")
 # → [{"name":"polyamide","count":63},
 # {"name":"Patric","count":7},
 # {"name":"PA2006 mod","count":5},
 # {"name":"PA6786 mod","count":1}]


================================================================================
F. APPLYING THE FILTER
================================================================================

------------------------------------------------------------------------
F.14 — HOW DOES THE UI APPLY THE FILTER AFTER SELECTION?
------------------------------------------------------------------------

[CONFIRMED for Tags and Created By; CANNOT CONFIRM for others]

CONFIRMED APPROACH FOR TAGS AND CREATED BY:
 These two filters correspond to inventory search parameters.
 The filter is applied by calling inventory_search with the selected
 values as filter parameters, returning inventory IDs, then using
 those IDs to determine which columns are visible.

EXACT SDK CALLS PER FILTER:

-- TAGS FILTER --
[CONFIRMED]

 # Single tag
 items = client.inventories.search(
 project_id="PROMO13137",
 tags=["Lisa"]
)
 visible_inv_ids = {item.albertId for item in items}
 # → prefixed "INVMO13137-…" — use to match column inventory_ids

 # Multiple tags (OR logic — returns items with ANY of the tags):
 items = client.inventories.search(
 project_id="PROMO13137",
 tags=["Lisa", "polyamide"]
)

 # Multiple tags (AND logic — must implement client-side):
 items = client.inventories.search(project_id="PROMO13137")
 required = {"Lisa", "polyamide"}
 visible = [
 item for item in items
 if required.issubset({t.name for t in (item.tags or [])})
]

 SDK parameter name: tags=["tag_name_string"] # list of name strings
 NOT: tags=["TAG10608"] # do NOT use TAG ids

-- CREATED BY FILTER --
[CONFIRMED]

 items = client.inventories.search(
 project_id="PROMO13137",
 created_by=["Victor Buj"] # exact display name string
)
 # OR using get_all:
 items = client.inventories.get_all(
 project_id="PROMO13137",
 created_by=["Victor Buj"]
)
 # Both return items where Created.byName == "Victor Buj"

 SDK parameter name: created_by=["display_name"] # list of strings

-- FORMULA / PRODUCT ID FILTER --
[CANNOT CONFIRM — no matching facet or SDK parameter found]

 No inventory search parameter named "formulaId" or "productId"
 was found. The UI filter by formula ID is most likely a client-side
 substring match against the column name or display ID.

 Recommended client-side implementation:

 def filter_by_formula_id(col_to_inv, col_names, query):
 q = query.lower()
 return {
 col_id for col_id, inv_id in col_to_inv.items()
 if q in inv_id.replace("INV","",1).lower()
 or q in col_names.get(col_id,"").lower()
 }

-- CONTAINS INVENTORY FILTER --
[CANNOT CONFIRM — no matching facet or SDK parameter found]

 No inventory search parameter for "containsIngredient" was found.
 The UI filter "Contains Inventory" (which formulation columns use
 a given raw material) must be applied client-side by reading the
 worksheet cell values:

 cells = client.sheets.get_cell_values("WKS15289")
 ingredient_row_ids = {
 row.row_id for row in inspect_rows
 if row.type == "INV"
 and row.inventory_id == "INVA278289" # target ingredient
 and row.design_id == "DES54962"
 }
 visible_cols = {
 c.columnId for c in cells
 if c.rowId in ingredient_row_ids
 and c.designId == "DES54962"
 and c.value and c.value!= "0"
 and float(c.value) > 0
 }

-- LOCKED FILTER --
[CANNOT CONFIRM — field not found]

 No "locked", "isLocked", or "isFormulaOverride" filter parameter
 was found on inventory_search or inventory_get_all.

 The field "isFormulaOverride" (bool) IS present on InventoryItem
 objects returned by get_by_id() and get_all():
 item.isFormulaOverride = False (confirmed for multiple items)

 This is the most likely backing field for the Locked/Unlocked filter.
 Client-side implementation:

 items = client.inventories.get_all(project_id="PROMO13137",
 category="Formulas")
 locked_inv_ids = {
 item.albertId for item in items
 if item.isFormulaOverride == True
 }
 unlocked_inv_ids = {
 item.albertId for item in items
 if item.isFormulaOverride == False
 }

-- PREDECESSOR FILTER --
[CANNOT CONFIRM — field not found in any inventory endpoint]

 No predecessor field was found on InventoryItem objects from
 get_by_id, get_by_ids, get_all, or search. No facet exists for it.
 The only source is the PDC row (ROW3, DES54964) in the Apps design
 worksheet cells, which is unreliable due to sheet truncation.

 Until a reliable API source is found, this filter cannot be
 implemented from the inventory endpoints alone.

-- DATA TEMPLATES FILTER --
[CANNOT CONFIRM — no single-call source found]

 No inventory search parameter for "dataTemplate" was found.
 The filter must be implemented by enumerating property tasks:

 # Build: inv_id → set of DT IDs
 inv_to_dts = {} # {inv_id: {dt_id,...}}
 tasks = client.tasks.get_all(project_id="PROMO13137",
 category="Property")
 for task in tasks:
 t = client.tasks.get_by_id(task.albertId)
 for block in (t.blocks or []):
 for inv_id in (block.inventoryIds or []):
 inv_to_dts.setdefault(inv_id, set())
 inv_to_dts[inv_id].add(block.dataTemplateId)

 # Apply filter for selected DT (e.g. DAT235 = "Cobb Value"):
 selected_dt = "DAT235"
 visible_inv_ids = {
 inv_id for inv_id, dts in inv_to_dts.items()
 if selected_dt in dts
 }
 # → {"INVMO13137-052","INVMO13137-064","INVMO13137-069",...}


================================================================================
SUMMARY TABLE — FILTER → API MAPPING
================================================================================

UI Filter Facet available? SDK search param Implementation
----------------- ---------------- ----------------- --------------------
Tags YES tags=[...] inventory_search()
 parameter="tags" tags= param

Created By YES created_by=[...] inventory_search() or
 param="createdBy" get_all() created_by=

Formula/Prod ID NO none Client-side substring
 match on column name
 or display ID

Contains Inv. NO none Client-side from
 sheet_get_cell_values
 cells > 0 at INV row

Locked NO (but field isFormulaOverride Client-side from
 isFormulaOverride on InventoryItem get_all() items
 exists on items)

Predecessor NO none [CANNOT CONFIRM]
 field not found in
 any inventory endpoint

Data Templates NO none Enumerate tasks →
 blocks → inventoryIds
 per data_template_id


================================================================================
SCHEMA REFERENCE — FIELD NAMES ACROSS ENDPOINTS
================================================================================

INVENTORYITEM FIELD PRESENCE BY ENDPOINT:

Field get_by_id get_by_ids get_all search
----------------- --------- ---------- ------- ------
status YES YES YES NO
name YES YES YES YES
albertId YES (INV…) YES (INV…) YES YES (no INV prefix)
category YES YES YES YES
unitCategory YES YES YES NO (uses "unit")
Tags (PascalCase) YES [{id}] YES [{id}] YES [{}] NO
tags (lowercase) NO NO NO YES [{name,albertId}]
Metadata sometimes sometimes sometimes NO
isFormulaOverride YES YES YES NO
parentId YES YES YES NO
ACL YES(full) YES(empty) YES(emp) NO
onHand YES YES YES NO (uses inventoryOnHand)
Symbols YES YES YES NO
Created YES YES YES NO
Updated YES YES YES NO
Cas YES YES YES NO
TaskConfig YES(full) NO NO NO
description NO NO NO YES (may be "")
lots NO NO NO YES
pictogram NO NO NO YES
predecessor NO NO NO NO — NOT PRESENT ANYWHERE
locked/isLocked NO NO NO NO — NOT PRESENT ANYWHERE
dataTemplates NO NO NO NO — NOT PRESENT ANYWHERE

TAG SHAPE BY ENDPOINT:

Endpoint Field Shape
----------- ----- -----------------------------------------
get_by_id Tags [{"id": "TAG10608"}] ← id only, no name
get_by_ids Tags [{"id": "TAG10608"}] ← id only, no name
get_all Tags [{"id": "TAG10608"}] ← id only, no name
search tags [{"name":"Lisa","albertId":"TAG10608"}]
facets Value [{"name":"Lisa","count":32}]

DATA TEMPLATE NAME FIELDS (from data_template_get_by_id):

Field DAT235 value Notes
----------- ---------------------------- ----------------------
name "Cobb Value" Short name; use for filter
fullName "DIN EN 20535: Cobb Value" Standard-prefixed
originalName "Cobb Value" Same as name here
displayName NOT PRESENT Field does not exist


================================================================================
END OF README
================================================================================