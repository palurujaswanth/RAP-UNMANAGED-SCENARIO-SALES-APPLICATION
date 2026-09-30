# SAP RAP: Unmanaged Sales Order Management Application with Draft Support

![SAP BTP](https://img.shields.io/badge/SAP-ABAP%20Cloud-blue?style=for-the-badge&logo=sap)
![ABAP RESTful Application Programming Model](https://img.shields.io/badge/RAP-Unmanaged%20Scenario-orange?style=for-the-badge)
![OData V4](https://img.shields.io/badge/Protocol-OData%20V4%20--%20UI-green?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-lightgrey?style=for-the-badge)

An enterprise-ready, end-to-end transactional application implemented using the **SAP ABAP RESTful Application Programming Model (RAP)**. The solution features an **Unmanaged Business Object with Draft Persistency**, adhering to SAP's modern cloud-ready ABAP guidelines, strict contract conventions (`strict (2)`), and complete LUW (Logical Unit of Work) lifecycle orchestration.

---

## 📌 Executive Summary

Enterprise backend systems often require non-standard persistency routines, legacy BAPI orchestrations, or complex runtime buffering that cannot rely purely on standard Managed RAP operations. 

This repository delivers an **Unmanaged Header-Item composition architecture** supporting the complete **Fiori Elements Draft Lifecycle**. Incoming transactional operations (CRUD, Draft actions) are buffered in memory via a custom singleton utility class and committed to persistent database tables through the Saver sequence.

---

---

## 🛠 Key Technical Highlights

* **Unmanaged Composition Tree**: Establishes parent-child relationships (`ZSALES_ORD_H_I` composition of `ZSALES_ORD_I_I`) with `TO PARENT` associations and transactional cascading.
* **Draft Capability in Unmanaged Scenario**: Full lifecycle support including `Edit`, `Activate`, `Prepare`, `Resume`, and `Discard` backed by dedicated Dictionary draft tables.
* **Transactional Buffer Decoupling**: Business logic utilizes an in-memory singleton buffer (`ZSALES_ORD_UTIL`) to hold transitional state across transactional steps (`create`, `update`, `delete`), executing final `MODIFY` and `DELETE` operations only during the Saver's `save` method.
* **Strict Mode Conformance**: Built under `strict (2)` rules featuring proper `%tky` transactional key handling, total ETag locking, and global authorization validation.
* **Separation of Concerns**: UI configurations are decoupled from data modeling using separate CDS Metadata Extensions.

---

## Architecture
<p align="left">
  <img src="https://gitdiagram.com/diagram-badge.svg" width="750">
</p>


## 📂 Repository Artifacts

| Layer | Object Name | Object Type | Description |
| :--- | :--- | :--- | :--- |
| **Dictionary** | `ZSALES_ORD_H` | Transparent Table | Sales Order Header Persistency Table |
| **Dictionary** | `ZSALES_ORD_I` | Transparent Table | Sales Order Item Persistency Table |
| **Dictionary** | `ZSALES_ORD_H_D` | Draft Table | Header Draft Persistency Table |
| **Dictionary** | `ZSALES_ORD_I_D` | Draft Table | Item Draft Persistency Table[cite: 1] |
| **CDS Data Model** | `ZSALES_ORD_H_I` | Root View Entity | Sales Order Header Interface View[cite: 1] |
| **CDS Data Model** | `ZSALES_ORD_I_I` | View Entity | Sales Order Item Interface View[cite: 1] |
| **CDS Projection** | `ZSALES_ORD_H_C` | Root View Entity | Header Consumption Projection[cite: 1] |
| **CDS Projection** | `ZSALES_ORD_I_C` | View Entity | Item Consumption Projection[cite: 1] |
| **CDS Annotation** | `ZSALES_ORD_H_MDE` | Metadata Extension | Header UI Layout Annotations[cite: 1] |
| **CDS Annotation** | `ZSALES_ORD_I_MDE` | Metadata Extension | Item UI Layout Annotations[cite: 1] |
| **Behavior Definition** | `ZSALES_ORD_H_I` | BDEF (Core) | Unmanaged Behavior Definition with Draft[cite: 1] |
| **Behavior Definition** | `ZSALES_ORD_H_C` | BDEF (Projection) | Projection Behavior Definition[cite: 1] |
| **ABAP Class** | `ZSALES_ORD_UTIL` | Global Class | Singleton Transactional Buffer Utility[cite: 1] |
| **ABAP Class** | `ZBP_SALES_ORD_ROOT` | Behavior Pool | Saver Class (`LSC_ZSALES_ORD_H_I`) Persistency Handler[cite: 1] |
| **ABAP Class** | `ZBP_SALES_ORD_H` | Behavior Pool | Header Behavior Handler (`create`, `update`, `delete`, `cba`)[cite: 1] |
| **ABAP Class** | `ZBP_SALES_ORD_I` | Behavior Pool | Item Behavior Handler (`update`, `delete`, `rba`)[cite: 1] |
| **Business Service** | `ZSALES_ORD_UI` | Service Definition | Service exposure of consumption entities[cite: 1] |
| **Business Service** | `ZSALES_ORD_O4` | Service Binding | OData V4 UI Service Binding[cite: 1] |

---



## 💻 Directory Structure

```text
├── src/
│   ├── behavior_definitions/
│   │   ├── zsales_ord_h_c.bdef.asbdef
│   │   └── zsales_ord_h_i.bdef.asbdef
│   ├── cds_views/
│   │   ├── zsales_ord_h_c.ddls.asddls
│   │   ├── zsales_ord_h_i.ddls.asddls
│   │   ├── zsales_ord_i_c.ddls.asddls
│   │   └── zsales_ord_i_i.ddls.asddls
│   ├── classes/
│   │   ├── zbp_sales_ord_h.clas.abap
│   │   ├── zbp_sales_ord_i.clas.abap
│   │   ├── zbp_sales_ord_root.clas.abap
│   │   └── zsales_ord_util.clas.abap
│   ├── metadata_extensions/
│   │   ├── zsales_ord_h_mde.ddlx.asddlxs
│   │   └── zsales_ord_i_mde.ddlx.asddlxs
│   ├── services/
│   │   └── zsales_ord_ui.srvd.assrvds
│   └── tables/
│       ├── zsales_ord_h.tabl.acds
│       ├── zsales_ord_h_d.tabl.acds
│       ├── zsales_ord_i.tabl.acds
│       └── zsales_ord_i_d.tabl.acds
└── README.md
