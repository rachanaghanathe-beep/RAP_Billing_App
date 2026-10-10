# RAP_Billing_App
Billing Data - RAP Application 
SAP RAP Billing Document Application

A fully functional Managed RAP application built on SAP BTP ABAP Environment (Trial) — covering the complete lifecycle of a Billing Document with header-item composition, draft handling, field-level audit logging via additional save, and multiple action types.

What This App Demonstrates
RAP Concept	Implementation
Managed BO	Full CRUD with managed implementation type
Composition	Header → Item (parent-child with composition [0..*])
Draft Handling	with draft — Edit, Activate, Discard, Resume, Prepare
Early Numbering	Sequential ID generation for both Header (BillId) and Item (ItemNo)
Precheck	Customer ID validation against standard I_Customer before buffer
Validation	Net Amount minimum check (on save — validates NetAmount >= 1000)
Determination	setDefaults — auto-sets BillType to 'V3' on create (on modify)
Instance Action	updateBillingDate — resets BillDate to current system date
Factory Action	CopyBillingDoc — creates a new billing document by copying all header fields from an existing one
Additional Save	Field-level audit log via save_modified in saver class (lsc_zrng_i_bill_header)
Read-Only Association	Audit log exposed on Object Page via CDS association (not part of BO composition)
Metadata Extensions	Full UI annotations — list page with action buttons, object page with 3 facets
Projection Layer	Separate projection views + projection BDEF with use draft and use action
OData V2 Service	Service Definition + Service Binding
Architecture
┌──────────────────────────────────────────────────────────┐
│  Service Binding (ZRNG_SB_BILL_HDR_V2 — OData V2 UI)    │
├──────────────────────────────────────────────────────────┤
│  Service Definition (ZRNG_SD_BILL_HDR)                   │
├──────────────────────────────────────────────────────────┤
│  Projection BDEF (ZRNG_C_BILL_HEADER)                    │
│    use create/update/delete, use draft                   │
│    use action updateBillingDate, CopyBillingDoc          │
├──────────────────┬───────────────────────────────────────┤
│  ZRNG_C_BILL_    │  Zrng_C_Bill_Item                     │
│  HEADER          │  (projection view)                    │
│  (projection)    │                                       │
├──────────────────┴───────────────────────────────────────┤
│  Root BDEF (ZRNG_I_BILL_HEADER) — managed, strict(2)     │
│    draft, early numbering, additional save               │
│    precheck, validation, determination, actions          │
├──────────────────┬───────────────────────────────────────┤
│  ZRNG_I_BILL_    │  zrng_i_bill_item                     │
│  HEADER          │  (interface view)                     │
│  (interface)     │                                       │
│       └── _AuditLog → ZRNG_I_AUDIT_LOG (read-only)      │
├──────────────────┴───────────────────────────────────────┤
│  zrng_bill_header  │  zrng_bill_item  │  zrng_audit_log  │
│  Draft: zrng_d_bill_head, zrng_d_bill_item (auto)       │
└──────────────────────────────────────────────────────────┘
Key Objects
Layer	Object Name	Purpose
Table	zrng_bill_header	Billing document header
Table	zrng_bill_item	Billing document items
Table	zrng_audit_log	Field-level change log (UUID key)
CDS Interface	ZRNG_I_BILL_HEADER	Root view — composition to items + association to audit log
CDS Interface	zrng_i_bill_item	Child view — association to parent header
CDS Interface	ZRNG_I_AUDIT_LOG	Read-only audit log view (as select from, not projection)
CDS Projection	ZRNG_C_BILL_HEADER	Header projection (transactional_query)
CDS Projection	Zrng_C_Bill_Item	Item projection with redirected parent
MDE	ZRNG_C_BILL_HEADER_MDE	Header UI — 3 facets, action buttons on list page
MDE	ZRNG_C_BILL_ITEM_MDE	Item UI — identification fields
BDEF	ZRNG_I_BILL_HEADER	Root behavior — managed, draft, early numbering, additional save
BDEF	ZRNG_C_BILL_HEADER	Projection behavior — use wrapper for all actions and draft
Class	ZBP_RNG_I_BILL_HEADER	Behavior pool — handler class + saver class
Class	ZRNG_BILL_DATA	Seed data generator
Behavior Pool — Two Local Classes

Handler class (lhc_ZRNG_I_BILL_HEADER):

earlynumbering_create — Sequential BillId using MAX + 1 from DB, with %is_draft in mapped output
earlynumbering_cba_Item — Sequential ItemNo per header using EML READ ENTITIES ... LINK
precheck_create — Validates CustomerId against /DMO/I_Customer before buffer
validateAmount — Reads entity via EML, checks NetAmount >= 1000, raises error message
setDefaults — Determination on modify: sets BillType to 'V3' on create
updateBillingDate — Instance action: resets BillDate to cl_abap_context_info=>get_system_date()
CopyBillingDoc — Factory action: reads all fields of source, creates new record via MODIFY ENTITIES ... CREATE

Saver class (lsc_zrng_i_bill_header):

save_modified — Writes audit log entries using create-header and update-header:
CREATE: Logs every business field (BillType, CustomerId, NetAmount) as separate rows
UPDATE: Uses %control flags to detect which fields actually changed, logs only those
UUID generation via cl_system_uuid=>create_uuid_x16_static() (wrapped in TRY/CATCH for cx_uuid_error)
Direct INSERT zrng_audit_log FROM TABLE — not EML (saver class runs outside RAP buffer)
Audit Log Design

A generic, field-agnostic audit table — each changed field gets its own row. This pattern works regardless of how many fields the header has.

| UUID | BillId | Operation | FieldName  | OldValue | NewValue | ChangedBy |
|------|--------|-----------|------------|----------|----------|-----------|
| ...  | 1      | CREATE    | BillType   |          | V3       | CB998...  |
| ...  | 1      | CREATE    | CustomerId |          | 000123   | CB998...  |
| ...  | 1      | UPDATE    | NetAmount  |          | 7500     | CB998...  |
Object Page UI

Three facets on the Billing Document detail page:

Header Information — BillId, BillType, BillDate, CustomerId, NetAmount, SalesOrg
Billing Items — Line item table of child items (with Create button)
Audit Log — Read-only table showing field-level change history

List page exposes two action buttons: Reset Billing Date and Copy.

BTP Trial Gotchas Solved
mandatory:create conflicts with draft on BTP trial — used field(readonly) + early numbering instead
field(readonly:update) + draft makes field permanently disabled — used plain field(readonly) on key fields
cl_abap_context_info=>get_system_timestamp() doesn't exist on trial — used get_system_date() and get_system_time()
cx_uuid_error on UUID generation — wrapped in TRY/CATCH
Draft tables must be auto-generated by the framework, not created manually
Read-only CDS views (audit log) must use as select from, not as projection on — projection would require the view to be part of the BO
Precheck fires on empty draft record (useless for field checks with draft) — use validation on save instead
Built With
SAP BTP ABAP Environment (Trial)
ABAP Development Tools (Eclipse)
SAP RESTful ABAP Programming Model (RAP)
OData V2
Author

Rachana N Ghanathe — SAP S/4HANA ABAP Consultant
