================================================================================
README.txt
Albert Invent — Worksheet Export SDK Reference
Project: MO13137 — Secondary Dispersions by Phase Inversion Process
Sheet: WKS15289 — "Phase Inversion"
================================================================================

CONTENTS
--------
1. Project & Sheet Identifiers
2. Worksheet Architecture Overview
3. Row Types — Storage, Resolution, and API Behavior
4. Design 1 — Product Design (DES54962)
5. Design 2 — Process Design (DES68130)
6. Design 3 — Apps Design (DES54964)
7. Design 4 — Results Design (DES54963)
8. Calculated BLK Rows — Formula vs Evaluated Values
9. Column Visibility and Experiment Filtering
10. Results Linkage — Task → Block → Interval → Cell
11. intervalCombination String Resolution
12. Bulk Property Data Export — Endpoint Comparison
13. Process Design Parameters — Storage and Retrieval
14. Classification Metadata — API Field Reference
15. Recommended pandas Export Pattern (End-to-End Code)
16. Known Limitations and Caveats


================================================================================
1. PROJECT & SHEET IDENTIFIERS
================================================================================

Entity Display ID SDK albertId Notes
---------------------- -------------- ------------------ --------------------
Project MO13137 PROMO13137 "Secondary Dispersions
 by Phase Inversion"
Worksheet (project-level) WKS15289 Sheet: "Phase
 Inversion"
Product Design — DES54962 Formulation grid
Process Design — DES68130 Synthesis parameters
Apps Design — DES54964 Metadata / tags
Results Design — DES54963 Measured properties

Formulation columns: 109 INV-type columns, COL120–COL238 range
 Display IDs: MO13137-001 through MO13137-095+
 SDK IDs: INVMO13137-001 through INVMO13137-095+

Total rows: 281 (170 product + 81 process + 7 apps + 23 results)
Total columns: 144 (2 DEF + 3 LKP + 28 BLK + 2 RSL + 109 INV)


================================================================================
2. WORKSHEET ARCHITECTURE OVERVIEW
================================================================================

An Albert Worksheet is a multi-design grid. Each "design" is an independent
row namespace sharing the same column set (the 109 formulation columns).
Designs are identified by their designId and rendered as separate sections
in the UI ("Product Design", "Process Design", "Apps", "Results").

The worksheet object is retrieved via:

 client.worksheets.get_by_project_id("PROMO13137")

Cell values (the actual data) are retrieved separately via:

 client.sheets.get_cell_values(sheet_id="WKS15289")

Each cell in the response has:
 {
 "rowId": "ROW233",
 "columnId": "COL206",
 "designId": "DES54962",
 "value": "33.983" # string; may be numeric string or formula
 }

There is NO per-design or per-column filter on get_cell_values.
The call returns the full matrix. For large sheets (this one has ~281 × 144
cells), the response is very large and may be truncated. See §16 for caveats.


================================================================================
3. ROW TYPES — STORAGE, RESOLUTION, AND API BEHAVIOR
================================================================================

Row Design(s) Value storage Returned by Separate call
type it appears in location get_cell_values? required?
----- ------------- --------------------- ------------------ --------------
INV DES54962 Worksheet grid cell YES — numeric No
 (user-entered qty) string

BLK DES54962, Worksheet grid cell YES — formula Evaluate
 DES54964 (formula string or string OR pre- client-side if
 plain text) evaluated number formula string
 (see §8)

TOT DES54962 Auto-sum of INV rows; YES — numeric No
 Albert computes on string
 write

PRG DES68130 Section header only; Row metadata only No cell value
 links to INVPRG… (no cell value) to extract

PRM DES68130 Worksheet grid cell YES — plain value No
 (user-entered param string or number
 value per column)

TAS DES54963 Section header; YES — aggregated YES for trial-
 aggregated result avg value pulled level: use
 pulled live from from property task property_data_
 Property Task entity get_all_task_
 properties()

TAG DES54964 Tags stored on NOT reliably YES —
 ROW1 InventoryItem entity returned (large inventory_
 (not in grid cell) sheets truncate get_by_id()
 before TAG rows) →.tags[]

APP DES54964 Linked entity Row metadata YES —
 ROW120 (INVAPR1); live + linked ID inventory_
 lookup get_by_id()

PRC DES54964 Computed dynamically NOT returned as YES —
 ROW2 from lot pricing; raw cell value pricing_get_by_
 avg/min/max inventory_id()

PDC DES54964 Predecessor NOT a grid cell; YES —
 ROW3 inventoryId on pulled from inv. inventory_
 InventoryItem entity metadata get_by_id()
 →.predecessor

BAT DES54964 Linked Lot/BatchTask NOT a grid cell; YES —
 ROW4 entities on inv item count shown in UI lot_get_all(
 parent_id=...)

LKP DES54962 Attribute pulled from YES — pre- No (attribute
 COL85 (IDH) InventoryItem at resolved string already resolved
 COL117 (RSN) render time in cell value)
 COL239 (Tags)

RSL DES54962 Linked SDS/substance YES — numeric No
 COL204, data (Flash point, string
 COL205 Acid Number)


================================================================================
4. DESIGN 1 — PRODUCT DESIGN (DES54962)
================================================================================

170 rows total: 84 INV rows, 85 BLK rows, 1 TOT row.

--- 4.1 INV Rows (84 rows) ---

Each INV row represents one inventory item (raw material or intermediate).
The cell value at (INV row, formulation column) is the quantity of that
material in that formulation (in parts or grams).

Material categories (BLK section headers group the INV rows):

 Category Representative items
 ------------------------------ -----------------------------------------
 Polymeric Dispersants / EAA A-C5120 (INVA236732),
 Primacor 5995 (INVA278289),
 Primacor 5980I (INVA24329)
 Dispersed Matrix Polymers Technomelt PA 2006 (INVB263513),
 Macromelt PA 6786 (INVA271705),
 PES BCS305 (INVA110143),
 Desmomelt U 320 (INVA226188),
 Elvax 4310/4320 (INVA22392/22393),
 Kraton D 1161 (INVA23134)
 Surfactants & Dispersing Tergitol 15-S-40 (INVA271520),
 Agents Oleic acid (INVA106961),
 Brij O 20 (INVA32071),
 Pluronic PE 6800 (INVA273048)
 Antioxidants Irganox 1010 (INVA19187),
 Irganox B 225 (INVA18146)
 Waxes / Resins / Plasticizers Foral AX-E (INVA22650),
 Kristalex F85 (INVA23170),
 Ceraflour 1010 (INVA268244)
 Neutralisation agents Ammonia solution 25% (INVA107081),
 50% KOH solution (INVEXP5266-012),
 50% NaOH solution (INVEXP5266-002)
 Water additions Deionised water (INVA25854, INVA126554)
 — appears in multiple process steps
 Post-addition additives Acetic acid (INVEXP5266-010),
 TEGO Antifoam 4-94 (INVA24849),
 BYK 3410 (INVA255789),
 Proxel GXL (INVA24368),
 Acticide MV (INVA21074)
 Intermediates / Blends INVMO13137-028, -032, -034, -039,
 -056, -060, -063 used as starting
 materials in later formulation columns

--- 4.2 BLK Calculation Rows (85 rows) ---

These rows hold formula strings or pre-evaluated numbers. Full list of
calculation groups:

Group Key rows (rowId)
------------------------------ -----------------------------------------
Molar acid calculations ROW67 (mmol AA, MW=72)
 ROW214 (mmol MAA, MW=86)
 ROW233 (Total acid mmoles)
 ROW281 (Total acid mgKOH/g)

Neutralisation agent calcs ROW64 (mmol NH3, MW=17)
 ROW142 (mmol KOH, MW=56)
 ROW66 (mmol NaOH, MW=40)
 ROW236 (mmol KOH — PA+PES)
 ROW223 (mmol KOH — Surfactant)
 ROW210 (mmol KOH — Resins)
 ROW283 (mmol KOH — MAH copolymers)
 ROW404 (mmol KOH — Dimers)
 ROW279 (mmol KOH — Polymer blends)
 ROW246 (mmol Acetic acid post-addition)
 ROW234 (Total alkali mmoles)

Molar ratios ROW215 (NaOH/total alkali)
 ROW216 (KOH/total alkali)
 ROW217 (NH3/total alkali)

Neutralisation Degree (ND) ROW231 (ND-Total [-])
 ROW399 (ND — Neutralisation Step)
 ROW400 (ND — W/O to O/W Step)
 ROW365 (ND by NaOH)
 ROW366 (ND by KOH)
 ROW367 (ND by NH3)

Process flow calcs ROW393 (Addition time, Neutr. Step [min])
 ROW392 (Flow rate, Neutr. Step [g/min])
 ROW384 (Addition time, W/O→O/W [min])
 ROW379 (Flow rate, W/O→O/W [g/min])
 ROW390 (NH3 conc. in water [%])
 ROW70 (Total mass experiment [g])
 ROW380 (Pump rate [g/min])
 ROW381 (Pump interval ON [min])
 ROW382 (Pump interval OFF [min])

Solids & density ROW118 (Solids at neutralisation [%])
 ROW394 (Solids at W/O→O/W step [%])
 ROW69 (Total solids [%])
 ROW161 (Density liquid coating [g/mL])

Cost ROW139 (RMC [€/kg] full formula)
 ROW160 (RMC [€/kg] solids only)

--- 4.3 BLK Property Columns (28 columns — column definitions, not rows) ---

These are COLUMN headers on the grid. Values are entered as plain numbers
by users in the INV row × property column cell intersections.

Column Name
---------- -----------------------------------------------
COL138 RM Description
COL4 RM solid content [%]
COL88 RMC [€/kg]
COL141 MAA content [%]
COL119 AA content [%]
COL153 Acid number SAP P92 [mg KOH/g]
COL125 Acid number — Calculations [mg KOH/g]
COL133 Tg [°C]
COL154 Amine number — SAP P92 [mg KOH/g]
COL143 Amine number — Calculations [mg KOH/g]
COL176 MAH content [%]
COL124 Melting point [°C]
COL132 Vicat softening temp [°C]
COL130 Melt index (190°C, 2.16 kg) [g/10 min]
COL129 R&B [°C]
COL152 Moles EO
COL161 CMC [ppm]
COL160 Cloud point [°C]
COL151 HLB
COL123 Brookfield
COL131 Tensile strength at break [MPa]
COL122 Elongation at break [%]
COL150 Molecular weight [g/mol]
COL109 Density RM
COL139 3 % w/o water
COL121 4 pph calc.
COL145 2 %
COL86 1 Composition

--- 4.4 TOT Row ---

ROW1 (DES54962, type TOT) — "Inventory Total"
Auto-sums all INV row quantities per formulation column.
Returned as a pre-evaluated numeric string by get_cell_values.

NOTE: ROW1 in DES54964 is the TAG row — different design, same rowId token.
Always filter by designId when resolving rowId.


================================================================================
5. DESIGN 2 — PROCESS DESIGN (DES68130)
================================================================================

81 rows total: 8 PRG rows (parameter group headers) + 73 PRM rows (parameters).

Per-column parameter values are stored IN THE WORKSHEET GRID CELLS.
The PRG entity (INVPRG…) defines only the schema. The cell at
(PRM row, formulation column) holds the recorded value for that parameter
for that formulation.

Parameter Group Display SDK ID Row Parameter count
------------------ ------- ----------- ----- ---------------
Reactor Description PG3599 INVPRG3599 ROW40 9 parameters
Blending of PG3600 INVPRG3600 ROW60 7 parameters
Polymers
Neutralisation Step PG3601 INVPRG3601 ROW74 13 parameters
W/O to O/W Step PG3602 INVPRG3602 ROW91 17 parameters
Post Addition Step PG3609 INVPRG3609 ROW241 14 parameters
Cooling Process PG3603 INVPRG3603 ROW103 7 parameters
Filtration PG3604 INVPRG3604 ROW145 2 parameters
APP_COAT_Coating PG3605 INVPRG3605 ROW172 23 parameters
of Paper
 TOTAL: 92 rows (8 PRG + 84 PRM
 — inspect returns 73
 distinct PRM definitions)

--- Reactor Description (INVPRG3599, ROW40) ---
ROW42 Reactor Description INVPRM4901
ROW39 Reactor volume INVPRM4746
ROW37 Reactor geometry INVPRM4747
ROW34 Reactor internal diameter INVPRM4748
ROW33 Stirrer Geometry INVPRM4641
ROW38 Stirrer Diameter INVPRM4751
ROW41 Distance stirrer→bottom INVPRM4900
ROW36 Heating Media INVPRM4897
ROW35 Cooling Media INVPRM4899

--- Blending of Polymers (INVPRG3600, ROW60) ---
ROW58 Temperature Set Point INVPRM2049
ROW57 Temperature Measured INVPRM4902
ROW92 Stirring Speed INVPRM1093
ROW59 Stirring Time INVPRM1303
ROW61 Vacuum INVPRM445
ROW62 Vacuum Time INVPRM1636
ROW63 Vacuum Temperature INVPRM1665

--- Neutralisation Step (INVPRG3601, ROW74) ---
ROW72 Temperature Set Point INVPRM2049
ROW71 Temperature Measured INVPRM4902
ROW75 Stirring Speed INVPRM1093
ROW67 Alkali addition process INVPRM4903
ROW66 Steps Nr INVPRM4904
ROW64 Stirring time after step INVPRM4906
ROW65 Automatic addition rate INVPRM4905
ROW205 Pump Setting INVPRM4913
ROW76 Stirring time after full INVPRM4908
 alkali addition
ROW70 Vacuum INVPRM445
ROW69 Vacuum Time INVPRM1636
ROW68 Vacuum Temperature INVPRM1665
ROW243 Total addition time INVPRM5010

--- W/O to O/W Step (INVPRG3602, ROW91) ---
ROW90 Temperature Set Point INVPRM2049
ROW89 Temperature Measured INVPRM4902
ROW82 Stirring Speed INVPRM1093
ROW210 pH of Water INVPRM5004
ROW209 Alkali INVPRM5005
ROW81 Water addition process INVPRM4909
ROW85 Steps Nr INVPRM4904
ROW83 Stirring time after step INVPRM4906
ROW84 Automatic addition rate INVPRM4905
ROW94 Pump Setting INVPRM4913
ROW80 Pump interval ON INVPRM4910
ROW79 Pump interval OFF INVPRM4911
ROW211 Total addition time INVPRM5010
ROW93 Solids at visual PI point INVPRM4912
ROW88 Vacuum INVPRM445
ROW87 Vacuum Time INVPRM1636
ROW86 Vacuum Temperature INVPRM1665

--- Post Addition Step (INVPRG3609, ROW241) ---
ROW240 Temperature Set Point INVPRM2049
ROW239 Temperature Measured INVPRM4902
ROW232 Stirring Speed INVPRM1093
ROW231 Water addition process INVPRM4909
ROW235 Steps Nr INVPRM4904
ROW233 Stirring time after step INVPRM4906
ROW234 Automatic addition rate INVPRM4905
ROW227 Pump Setting INVPRM4913
ROW230 Pump interval ON INVPRM4910
ROW229 Pump interval OFF INVPRM4911
ROW228 Solids at visual PI point INVPRM4912
ROW238 Vacuum INVPRM445
ROW237 Vacuum Time INVPRM1636
ROW236 Vacuum Temperature INVPRM1665

--- Cooling Process (INVPRG3603, ROW103) ---
ROW101 Temperature Set Point INVPRM2049
ROW96 Temperature Discharge INVPRM4914
ROW97 Stirring Speed INVPRM1093
ROW102 Stirring Time INVPRM1303
ROW100 Vacuum INVPRM445
ROW99 Vacuum Time INVPRM1636
ROW98 Vacuum Temperature INVPRM1665

--- Filtration (INVPRG3604, ROW145) ---
ROW144 Filter Mesh Size INVPRM240
ROW143 Filter Material INVPRM135

--- APP_COAT_Coating of Paper (INVPRG3605, ROW172) ---
ROW162 Consumables INVPRM431
ROW161 Coated surface INVPRM1915
ROW153 Manual vs Automatic INVPRM4116
ROW163 Equipment (base) INVPRM432
ROW165 Equipment (top) INVPRM432
ROW158 Multi-coating system? INVPRM4720
ROW160 Formulas (base) INVPRM433
ROW157 Base Coating Lot Nr. INVPRM4547
ROW154 Dilution INVPRM1655
ROW159 Formulas (top) INVPRM433
ROW155 Top Coating Lot Nr. INVPRM4548
ROW171 Base coating appl. method INVPRM3668
ROW164 Base coating applicator INVPRM3669
ROW156 Base coating speed INVPRM3670
ROW152 Base coating drying temp INVPRM3671
ROW151 Base coating drying time INVPRM3680
ROW206 Equipment (corona) INVPRM432
ROW207 Corona Power INVPRM1322
ROW208 Number of Cycles INVPRM216
ROW170 Top coating appl. method INVPRM3675
ROW169 Top coating applicator INVPRM3676
ROW168 Top coating speed INVPRM3677
ROW167 Top coating drying temp INVPRM3678
ROW166 Top coating drying time INVPRM3679

To retrieve all 73 parameter values for one formulation column:

 cells = client.sheets.get_cell_values(sheet_id="WKS15289")
 process_cells = [
 c for c in cells
 if c.designId == "DES68130" and c.columnId == "COL206"
]
 # COL206 = INVMO13137-064


================================================================================
6. DESIGN 3 — APPS DESIGN (DES54964)
================================================================================

7 rows total.

ROW ID Name Type Notes
------ -------------------- ---- -------------------------------------------
ROW1 Tags TAG Tags from InventoryItem.tags[]; NOT reliably
 returned by get_cell_values on large sheets.
 Use inventory_get_by_id() →.tags instead.
ROW120 Responsible Chemistry APP Links to INVAPR1 (application entity).
 Resolve via inventory_get_by_id().
ROW2 Pricing PRC Computed from lot pricing; avg/min/max.
 Use pricing_get_by_inventory_id().
ROW3 Predecessor PDC Predecessor formula ID stored on
 InventoryItem.metadata.predecessor.
 Use inventory_get_by_id() →.predecessor.
ROW4 Batches BAT Linked Lot/BatchTask entities.
 Use lot_get_all(parent_id=<INVMO13137-XXX>).
ROW5 Purpose BLK Free-text; stored in grid cell.
 Read from get_cell_values, designId=DES54964,
 rowId=ROW5.
ROW6 Result BLK Free-text; stored in grid cell.
 Read from get_cell_values, designId=DES54964,
 rowId=ROW6.


================================================================================
7. DESIGN 4 — RESULTS DESIGN (DES54963)
================================================================================

23 rows total: 21 TAS rows + 2 BLK archive dividers.

TAS rows (property tasks):

ROW ID Task name
------- ----------------------------------------------------------
ROW46061 Liquid Coating Properties (PA + EAA)
ROW44529 Coated Paper Properties (PA modifications + EAA)
ROW39713 Liquid Coating Properties (PA modifications + EAA)
ROW27293 Liquid Coating Properties (PA + EAA)
ROW27287 Dispersion Process (Pass/Fail)
ROW24325 Liquid Coating Properties (PA + EVA)
ROW21406 Liquid Coating Properties (PA + EAA)
ROW10959 Liquid Coating Properties (SIS + EAA)
ROW1915 Liquid Coating Properties
ROW10309 Coated Paper Properties
ROW8089 Liquid Coating Properties (PA + EAA)
ROW4506 Properties of Coated Sample (Solide Lucent)
ROW12373 APP_COAT_SEM
ROW6497 APP_Coat - Heat Seal (oPP Corona / A to A) (600N, 1 sec)
ROW6359 APP_Coat - Heat Seal (PET Corona / A to A) (600N, 1 sec)
ROW5193 APP_Coat - Heat Seal (ALU / A to A) (600N, 1 sec)
ROW6164 APP_Coat - Heat Seal (ALU/PP) (600N, 1 sec)
ROW5969 APP_Coat - Heat Seal (ALU/PET) (600N, 1 sec)
ROW5331 APP_Coat - Heat Seal (ALU/PE) (600N, 1 sec)
ROW4448 SEM Dry Film
ROW4131 Medical Package — Properties of Coated Sample

BLK archive dividers:
ROW21405 "Archived Data"
ROW10938 "Liquid properties (Archive)"

Known Property Task → SDK ID mapping (active tasks):

Task name Display ID SDK ID
-------------------------------------------- ----------- ----------------
Coated Paper Properties (PA + EAA) FOR884237 TASFOR884237
Coated Paper Properties (SIS + EAA) FOR894429 TASFOR894429
Coated Paper Properties (PA modifications + FOR969623 TASFOR969623
EAA)
Liquid Coating Properties (PA + EVA) FOR928887 TASFOR928887
Liquid Coating Properties (PA + EAA) FOR881255 TASFOR881255
Liquid Coating Properties (Secondary disp.) FOR805346 TASFOR805346
Liquid Coating Properties (SIS + EAA) FOR849721 TASFOR849721
Liquid Coating Properties (PA mod. + EAA) FOR969236 TASFOR969236

Data templates in "Coated Paper Properties" tasks (shared by FOR884237,
FOR894429, FOR969623):

Data Template Display SDK ID
---------------------------------- ------- --------
Visual appearance — coatings DT1607 DAT1607
Blocking Test DT287 DAT287
Folding Behavior DT872 DAT872
Coating Weight (g/m2; gsm) DT464 DAT464
DIN EN 20535: Cobb Value DT235 DAT235
Fatty Acid Penetration Test DT870 DAT870
TAPPI T 559: Grease Resistance DT876 DAT876
ASTM F119: Rate of Grease Pen. DT871 DAT871
WVTR DT382 DAT382
ASTM F1927: Oxygen GTR DT1237 DAT1237
Seal strength of Heatseal coatings DT316 DAT316

Cobb Value (DAT235) specific detail:
 Block ID in FOR884237: BLK3
 Workflow: WFL348441 ("Determination of Cobb value")
 Parameter Group: PRG1942
 Data Column: DAC534 ("Cobb (t) - Value")
 Unit: UNI1074 (g/m²)
 Intervals:
 ROW4 → Temperature: 23°C
 ROW5 → Temperature: 90°C


================================================================================
8. CALCULATED BLK ROWS — FORMULA vs EVALUATED VALUES
================================================================================

Albert supports 394 Excel-compatible functions in worksheet cells
(SUM, SUMPRODUCT, IF, FILTER, etc.). Formulas are entered with a leading "=".

API BEHAVIOR:
- get_cell_values returns the STORED cell content.
- For formula cells: this MAY be the formula string (e.g. "=ROW233/ROW234")
 OR a pre-evaluated numeric string, depending on whether Albert has
 materialised the result on the last save.
- For this sheet (WKS15289): empirically, the calculation BLK rows return
 pre-evaluated numeric values (e.g. ROW233 → "34.070" for COL206).
 Albert appears to cache results on write for this project.
- There is NO dedicated "evaluated values" endpoint separate from
 get_cell_values.

DETECTING FORMULA vs VALUE:
 for cell in cells:
 if cell.value and cell.value.startswith("="):
 # formula string — evaluate client-side
 else:
 # pre-evaluated or plain text

CLIENT-SIDE EVALUATION:
- If you receive formula strings, you need the full row dependency graph.
- Row references in Albert formulas use rowId tokens (e.g. ROW233, ROW64).
- Build a dict: { rowId: { columnId: float_value } } from all INV cells,
 then substitute into each formula expression per column.
- Circular references are not supported by Albert.

BLK PROPERTY COLUMNS (COL4, COL88, COL133, etc.):
- These are plain numeric values entered by users — no formula evaluation
 needed. get_cell_values returns them directly as numeric strings.


================================================================================
9. COLUMN VISIBILITY AND EXPERIMENT FILTERING
================================================================================

HIDDEN COLUMN STATE:
- Stored server-side as a boolean flag on the column object (persistent
 across sessions, shared across users on the project).
- get_cell_values returns ALL columns regardless of hidden state.
- Hidden columns still participate in formula calculations.
- There is no include_hidden=false parameter on get_cell_values.

TO READ HIDDEN FLAGS:
 inspect = client.sheets.inspect(sheet_id="WKS15289")
 hidden_cols = [col.columnId for col in inspect.columns if col.hidden]

COLUMN ORDERING:
- The API returns columns in UI display order.
- Pinned columns (left of the divider) appear first in the array.
- Unpinned columns follow in their saved order.

UI FILTER TYPES (client-side only — NOT persisted as API objects):
 1. Formula / Product ID filter
 2. Inventory type filter
 3. Locked / Unlocked filter
 4. Predecessor filter
 5. Tags filter
 6. Data Templates filter
 7. Created By filter

These 7 filters control UI display only. They are not saved as server-side
view or filter objects. The API always returns the full unfiltered set.
Re-implement these filters client-side using column metadata from
sheet_inspect + inventory_get_by_id for tag/creator data.

FOCUS VIEW (per-column row filter):
- Hides rows that have no value in the focused column.
- UI-only; no API equivalent.

TAG-BASED COLUMN FILTERING (recommended pattern):

 inventories = client.inventories.get_all(project_id="PROMO13137")
 lisa_cols = [
 inv.albertId for inv in inventories
 if any(t.name == "Lisa" for t in (inv.tags or []))
]
 # Use lisa_cols as a column filter when slicing the cell values matrix.


================================================================================
10. RESULTS LINKAGE — TASK → BLOCK → INTERVAL → CELL
================================================================================

ENTITY CHAIN:

 PropertyTask (e.g. TASFOR884237)
 └── Block (e.g. BLK3)
 ├── DataTemplate (DAT235)
 │ └── DataColumn (DAC534 — "Cobb (t) - Value", unit UNI1074)
 └── Workflow (WFL348441)
 └── ParameterGroup (PRG1942)
 └── IntervalCombinations
 ├── ROW4 → Temperature 23°C
 └── ROW5 → Temperature 90°C

KEY IDENTIFIER FIELDS:

SDK field Example value Maps to
-------------------------- -------------------- ----------------------------
task.albertId TASFOR884237 Worksheet TAS row linked task
block.blockId BLK3 Sub-block within the task
block.dataTemplateId DAT235 Data template (DT235 display)
dataColumn.albertId DAC534 Result column "Cobb (t)-Value"
dataColumn.unit.albertId UNI1074 g/m²
intervalCombination.id ROW5 Interval → Temperature 90°C
trial.trialNo 1, 2, … Replicate within block
inventory.albertId INVMO13137-064 Formulation column COL206
lot.albertId LOTB357302 Optional lot traceability

HOW A VALUE LANDS IN A WORKSHEET CELL:
1. The TAS row in DES54963 links to a PropertyTask via albertId.
2. Albert checks whether a formulation's inventoryId appears in any block
 of that task.
3. The worksheet cell shows the aggregated (averaged) result across all
 trials for that inventory × dataColumn × intervalCombination.
4. Completed task data auto-syncs and overwrites prior inline values.
5. Per-trial values are NOT shown in the grid — they require a direct
 property data API call.


================================================================================
11. INTERVALCOMBINATION STRING RESOLUTION
================================================================================

FORMAT: "ROW{n}" for single-parameter intervals,
 "ROW{n}XROW{m}" for two-parameter (crossed) intervals.

The ROW tokens are 1-based position indices within the ordered interval
list of each parameter — NOT worksheet row IDs.

RESOLUTION STEPS:

 # 1. Fetch the workflow for the block
 workflow = client.workflows.get_by_id("WFL348441")

 # 2. Read workflow.IntervalCombinations
 # Each entry has the form:
 # Single parameter:
 # {
 # "id": "ROW4",
 # "parameterName": "Temperature",
 # "value": "23",
 # "unit": "°C"
 # }
 # Two-parameter cross:
 # {
 # "id": "ROW4XROW2",
 # "param1Name": "Temperature",
 # "param1Value": "90",
 # "param2Name": "Time",
 # "param2Value": "24",
 # "param2Unit": "h"
 # }

CONFIRMED MAPPING for WFL348441 (Determination of Cobb value):

 Interval ID Parameter Value
 ----------- ------------- -----
 ROW4 Temperature 23°C
 ROW5 Temperature 90°C

IMPORTANT: ROW4/ROW5 here are interval position indices. They are
UNRELATED to the worksheet rowId "ROW4" or "ROW5" in DES54964.
Always resolve via the workflow's IntervalCombinations array.


================================================================================
12. BULK PROPERTY DATA EXPORT — ENDPOINT COMPARISON
================================================================================

Approach SDK method Speed Notes
-------------------- ---------------------------------- -------- -----------
Per block × inv property_data_get_task_block_ Slowest 1 call per
 properties(task_id, block_id, (block×inv)
 inventory_id) ~1,050 calls
 for 21 tasks

Per task (all property_data_get_all_task_ FASTEST 1 call per
blocks) ← RECOMMENDED properties(task_id) task. 21
 calls total.
 Returns all
 blocks, all
 inventories,
 all intervals,
 all trials.

Property data search property_data_search( Medium Must scope
 project_ids=["PROMO13137"]) with at least
 one filter.
 List filter
 fields capped
 at ~6–8 IDs
 per call
 (URL length).
 Paginated.

Worksheet/report No dedicated bulk REST export N/A No single-
export endpoint endpoint exists call JSON/CSV
 grid dump.

PAGINATION:
- property_data_get_all_task_properties: no pagination within a task
 (returns all data in one response per task).
- property_data_search: use limit + offset or start_key (SDK version
 dependent). No published per-call rate limit; stay below ~10 concurrent
 requests as a safe default.

REPORTS API NOTE:
- The Reports module generates async analytics reports using ReportTemplate
 entities. It does NOT return a raw grid dump and does NOT respect
 UI hidden-column filters. It is not suitable for programmatic bulk export.

PROPERTY DATA REPORT FIELD NAMES (for column mapping when using Reports API):

 Task ID Task Name
 Data Template ID Data Template Name
 Product / Formula ID Product / Formula Name
 Result Value Value (log)
 Block Interval Interval 1 Interval 2
 Interval 1 Parameter Interval 1 Value
 Interval 2 Parameter Interval 2 Value
 Lot Number Manufacturer Lot Number
 Parameter Groups Parameter Group ID Parameter Group Name
 Parameter Parameter Value
 Row (trial row identifier within a Data Template)


================================================================================
13. PROCESS DESIGN PARAMETERS — STORAGE AND RETRIEVAL
================================================================================

VALUES ARE STORED IN THE WORKSHEET GRID CELLS — not in the PRG/PRM
entity definitions, not in workflow entities, not in task records.

The PRG entity (INVPRG…) defines only the SCHEMA (parameter names, units).
Per-column values live exclusively in the worksheet cell at
(PRM rowId, formulation columnId).

RETRIEVAL — all 73 parameters for one formulation column:

 cells = client.sheets.get_cell_values(sheet_id="WKS15289")
 col_id = "COL206" # INVMO13137-064
 process_params = {
 c.rowId: c.value
 for c in cells
 if c.designId == "DES68130" and c.columnId == col_id
 and c.value is not None
 }
 # process_params = { "ROW58": "120", "ROW92": "500",... }

 # Map rowId → parameter name using the PRM table in §5.

BATCH TASK INHERITANCE:
- When a Batch Task is created from the worksheet, only parameters that
 have a value entered in the worksheet cell are carried into the task.
- Batch Tasks display these values in their Process Design section by
 reading from the worksheet's stored cell data at creation time.
- Modifying cell values AFTER batch task creation does NOT retroactively
 update the task's parameter values.

LARGE SHEET TRUNCATION NOTE:
- WKS15289 is large (~281 × 144 cells). In practice, get_cell_values
 returns DES54962 rows first, then DES54963, DES54964, DES68130 last.
- DES68130 process parameter rows frequently fall in the truncated
 portion of the response. See §16 for workarounds.


================================================================================
14. CLASSIFICATION METADATA — API FIELD REFERENCE
================================================================================

For a given formulation inventory ID (e.g. INVMO13137-064):

Metadata type SDK call Field path in response
--------------- ------------------------------------ -----------------------
Tags inventory_get_by_id(.tags[]
 id="INVMO13137-064").albertId (e.g. TAG10608)
.name (e.g. "Lisa")

Predecessor inventory_get_by_id(.metadata.predecessor
 id="INVMO13137-064") (string, e.g.
 "MO13137-056")

Batches / Lots lot_get_all( [].albertId (LOT…)
 parent_id="INVMO13137-064") [].taskId (batch task)
 [].amount
 [].unit

Purpose / Result sheet_get_cell_values("WKS15289").value (plain text)
notes (ROW5/6) → filter designId="DES54964",
 rowId="ROW5" or "ROW6",
 columnId=<target col>

Data Template task_get_by_id(.blocks[].dataTemplateId
membership task_id="TASFOR884237").blocks[].inventoryIds[]

Created By inventory_get_by_id(.Created.byName
 id="INVMO13137-064").Created.by (USR…)
.Created.at (ISO8601)

IDH number sheet_get_cell_values or.value (pre-resolved
(COL85) inventory_get_by_id →.metadata.idh string from LKP col)

RSN code sheet_get_cell_values or.value (pre-resolved
(COL117) inventory_get_by_id →.metadata.rsn string from LKP col)

Inventory tags inventory_get_by_id or.tags[].name
(Tags LKP col, inventory_search(project_id= array of tag objects
COL239) "PROMO13137")

Flash point sheet_get_cell_values (COL205).value (numeric string)
(RSL col) or substance/SDS entity

Acid Number sheet_get_cell_values (COL204).value (numeric string)
(RSL col) or substance/SDS entity

KNOWN TAGS IN THIS PROJECT:

Tag ID Tag name Notes
---------- ---------------- ----------------------------------------
TAG10608 Lisa Owner/author marker (Lisa Meyfarth USR4840)
 Applied to all active formulations
TAG10617 (EAA Resin) Material chemistry tag
TAG2799 (polyamide) Material chemistry tag
TAG49202 Release coating Application type tag
TAG49482 (project-specific) Confirm via tag_get_by_id("TAG49482")
TAG49490 (project-specific) Confirm via tag_get_by_id("TAG49490")


================================================================================
15. RECOMMENDED PANDAS EXPORT PATTERN (END-TO-END CODE)
================================================================================

Below is a complete reference implementation. Adjust client instantiation
and field names to match your installed albert SDK version.

-------- export_mo13137.py --------

import pandas as pd
from albert import AlbertClient

client = AlbertClient()

PROJECT_ID = "PROMO13137"
SHEET_ID = "WKS15289"
DESIGN_IDS = {
 "product": "DES54962",
 "process": "DES68130",
 "apps": "DES54964",
 "results": "DES54963",
}

# ── STEP 1: Fetch all cell values ─────────────────────────────────────────────
print("Fetching cell values...")
cells = client.sheets.get_cell_values(sheet_id=SHEET_ID)
# cells: list of CellValue objects with.rowId,.columnId,.designId,.value

# Build a lookup dict: (designId, rowId, columnId) → value
cell_map = {
 (c.designId, c.rowId, c.columnId): c.value
 for c in cells if c.value is not None
}

# ── STEP 2: Fetch worksheet structure (row + column metadata) ─────────────────
print("Inspecting sheet structure...")
inspect = client.sheets.inspect(sheet_id=SHEET_ID)

# Column metadata: columnId, type (INV/BLK/DEF/LKP/RSL), hidden, order
columns_meta = {col.columnId: col for col in inspect.columns}
inv_columns = [c for c in inspect.columns if c.type == "INV"]
col_order = [c.columnId for c in inspect.columns] # UI display order

# Row metadata per design
rows_by_design = {}
for design in inspect.designs:
 rows_by_design[design.designId] = design.rows

# ── STEP 3: Product Design — formulation composition ─────────────────────────
print("Extracting Product Design (DES54962)...")
design_id = DESIGN_IDS["product"]
inv_rows = [r for r in rows_by_design[design_id] if r.type == "INV"]
blk_rows = [r for r in rows_by_design[design_id] if r.type == "BLK"]

product_records = []
for row in inv_rows:
 for col in inv_columns:
 val = cell_map.get((design_id, row.rowId, col.columnId))
 if val:
 product_records.append({
 "formulation_id": col.columnId,
 "inventory_sdk_id": col.albertId, # INVMO13137-XXX
 "ingredient_row": row.rowId,
 "ingredient_name": row.name,
 "ingredient_id": row.albertId, # INVA…
 "quantity": float(val) if val.replace(".", "")
.lstrip("-").isdigit() else val,
 })
df_product = pd.DataFrame(product_records)

# Pivot: rows = ingredients, columns = formulations
df_product_pivot = df_product.pivot_table(
 index=["ingredient_row", "ingredient_name", "ingredient_id"],
 columns="inventory_sdk_id",
 values="quantity",
 aggfunc="first"
)

# ── STEP 4: Calculations — BLK rows ──────────────────────────────────────────
print("Extracting BLK calculation rows (DES54962)...")
calc_records = []
for row in blk_rows:
 for col in inv_columns:
 val = cell_map.get((design_id, row.rowId, col.columnId))
 if val:
 is_formula = val.startswith("=")
 calc_records.append({
 "formulation_id": col.columnId,
 "inventory_sdk_id": col.albertId,
 "calc_row": row.rowId,
 "calc_name": row.name,
 "raw_value": val,
 "is_formula": is_formula,
 "numeric_value": None if is_formula else (
 float(val) if val.replace(".", "")
.lstrip("-").isdigit() else None),
 })
df_calcs = pd.DataFrame(calc_records)

# ── STEP 5: Process Design — parameter values ─────────────────────────────────
print("Extracting Process Design (DES68130)...")
design_id = DESIGN_IDS["process"]
prm_rows = [r for r in rows_by_design[design_id] if r.type == "PRM"]

process_records = []
for row in prm_rows:
 for col in inv_columns:
 val = cell_map.get((design_id, row.rowId, col.columnId))
 if val:
 process_records.append({
 "formulation_id": col.columnId,
 "inventory_sdk_id": col.albertId,
 "param_row": row.rowId,
 "param_name": row.name,
 "param_sdk_id": row.albertId, # INVPRM…
 "value": val,
 })
df_process = pd.DataFrame(process_records)

# ── STEP 6: Apps Design — tags, purpose, result notes ────────────────────────
print("Extracting Apps Design (DES54964)...")
design_id = DESIGN_IDS["apps"]
apps_rows = rows_by_design[design_id]

# Purpose and Result (BLK rows — plain text in grid)
apps_records = []
for row in [r for r in apps_rows if r.type == "BLK"]:
 for col in inv_columns:
 val = cell_map.get((design_id, row.rowId, col.columnId))
 if val:
 apps_records.append({
 "inventory_sdk_id": col.albertId,
 "field": row.name, # "Purpose" or "Result"
 "value": val,
 })
df_apps = pd.DataFrame(apps_records)

# Tags — read from InventoryItem entities (more reliable than grid for
# large sheets where TAG row may be truncated)
print("Fetching inventory tags...")
inventories = client.inventories.get_all(project_id=PROJECT_ID)
tag_records = []
for inv in inventories:
 for tag in (inv.tags or []):
 tag_records.append({
 "inventory_sdk_id": inv.albertId,
 "tag_id": tag.albertId,
 "tag_name": tag.name,
 })
df_tags = pd.DataFrame(tag_records)

# Predecessors — from InventoryItem metadata
pred_records = []
for inv in inventories:
 pred = getattr(inv, "predecessor", None) or (
 inv.metadata.get("predecessor") if inv.metadata else None)
 if pred:
 pred_records.append({
 "inventory_sdk_id": inv.albertId,
 "predecessor": pred,
 })
df_predecessors = pd.DataFrame(pred_records)

# ── STEP 7: Results — property task data ─────────────────────────────────────
print("Fetching property task data (21 tasks)...")
design_id = DESIGN_IDS["results"]
tas_rows = [r for r in rows_by_design[design_id] if r.type == "TAS"]
task_ids = [row.albertId for row in tas_rows if row.albertId]

all_prop_records = []
for task_id in task_ids:
 print(f" Reading task {task_id}...")
 try:
 data = client.property_data.get_all_task_properties(task_id=task_id)
 for rec in data:
 all_prop_records.append({
 "task_id": task_id,
 "block_id": rec.blockId,
 "data_template_id": rec.dataTemplateId,
 "data_column_id": rec.dataColumnId,
 "data_column_name": rec.dataColumnName,
 "inventory_sdk_id": rec.inventoryId,
 "lot_id": rec.lotId,
 "interval_combo_id": rec.intervalCombinationId,
 "trial_no": rec.trialNo,
 "value": rec.value,
 "unit_id": rec.unitId,
 "unit_symbol": rec.unitSymbol,
 })
 except Exception as e:
 print(f" WARNING: could not read {task_id}: {e}")

df_results = pd.DataFrame(all_prop_records)

# Resolve interval combos → parameter names and setpoints
# (build lookup from workflow IntervalCombinations for each unique workflow)
# workflow_id → { intervalComboId → { param1Name, param1Value,... } }
# Omitted for brevity — call client.workflows.get_by_id(workflow_id)
# and read.IntervalCombinations for each block's workflow.

# ── STEP 8: Save to Excel ─────────────────────────────────────────────────────
print("Writing to Excel...")
with pd.ExcelWriter("MO13137_Phase_Inversion_Export.xlsx") as writer:
 df_product_pivot.to_excel(writer, sheet_name="Product_Composition")
 df_calcs.to_excel(writer, sheet_name="Calculations", index=False)
 df_process.to_excel(writer, sheet_name="Process_Params", index=False)
 df_apps.to_excel(writer, sheet_name="Apps_Notes", index=False)
 df_tags.to_excel(writer, sheet_name="Tags", index=False)
 df_predecessors.to_excel(writer, sheet_name="Predecessors", index=False)
 df_results.to_excel(writer, sheet_name="Results", index=False)

print("Done.")

-------- end of export_mo13137.py --------


================================================================================
16. KNOWN LIMITATIONS AND CAVEATS
================================================================================

1. LARGE SHEET TRUNCATION
 WKS15289 has ~281 rows × 144 columns. The get_cell_values call returns
 a large payload (~40,000+ cells). The Albert SDK internally caps the
 response at approximately 20,000 tokens / items. In practice:
 - DES54962 (product) rows are returned first and usually complete.
 - DES54963 (results) TAS rows are partially returned.
 - DES54964 (apps) TAG row values are frequently truncated/missing.
 - DES68130 (process) PRM rows are usually in the truncated portion.

 WORKAROUND: For TAG rows, read tags from inventory_get_by_id() instead
 (see §14). For process parameters, post-process the partially returned
 DES68130 cells and accept that some columns may have NULL values.
 Consider filing a support request for a row-filtered cell values endpoint.

2. TAG ROW UNRELIABILITY
 The TAG row (ROW1/DES54964) is a live lookup — it is not reliably
 returned by get_cell_values on large sheets. Always use
 inventory_get_by_id().tags[] as the authoritative source for tag data.

3. FORMULA STRING vs EVALUATED VALUE
 BLK calculation rows may return formula strings rather than numbers.
 Validate every BLK cell value: if it starts with "=", evaluate
 client-side. See §8.

4. INTERVAL ROW INDICES vs WORKSHEET ROW IDs
 intervalCombination tokens like "ROW4", "ROW5" are 1-based position
 indices within a workflow's IntervalCombinations list — they are NOT
 worksheet rowId values. Never cross-reference them against the sheet
 row map. Always resolve via workflow.IntervalCombinations. See §11.

5. SDK ID vs DISPLAY ID CONVERSION
 All SDK tool calls require the full SDK albertId. Display IDs are
 user-facing only. Conversion rules:
 MO13137-064 → INVMO13137-064 (prepend INV)
 FOR884237 → TASFOR884237 (prepend TAS)
 DT235 → DAT235 (replace DT with DAT)
 PG3601 → PRG3601 (replace PG with PRG — in API)
 also INVPRG3601 (when stored in worksheet as INVPRG…)
 PG3601 display in EC chip → PG3601 (replace PRG with PG for UI)

6. PROCESS PARAMETER VALUES NOT IN TASK RECORDS
 Process Design PRM values are stored only in the worksheet grid.
 They are copied into Batch Tasks at creation time only. Querying
 a Batch Task after the fact will show the snapshot values from when
 the task was created — not live worksheet values.

7. PROPERTY DATA SEARCH URL LENGTH CAP
 property_data_search with list filters (inventory_ids, data_templates,
 etc.) is limited by HTTP URL length. Keep each list filter to ≤6–8 IDs
 per call to avoid HTTP 400 errors.

8. PREDECESSOR FIELD LOCATION
 The predecessor field may appear as inventory.predecessor (top-level
 field) or inventory.metadata.predecessor (inside the metadata dict)
 depending on SDK version. Check both.

9. NO BULK EXPORT / REPORT ENDPOINT
 There is no single API endpoint that returns the full worksheet grid
 as CSV or JSON, respecting UI column visibility filters. Bulk export
 must be assembled from multiple API calls as described in §12 and §15.

10. TASK IDs FROM WORKSHEET TAS ROWS
 The TAS row's albertId in the worksheet inspect response gives the
 task's SDK albertId directly (e.g. TASFOR884237). However, for tasks
 not yet started or in a non-linked state, albertId may be null on the
 row. Fall back to task_search(project_id="PROMO13137") to enumerate
 all tasks.

================================================================================
END OF README
================================================================================