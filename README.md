# Warehouse Management Platform

_Last updated: Mar 2026 (commit 2) (commit 5)_

---

## Overview
A Spring Boot 4.x web application for managing warehouse operations. It uses:

- **Spring MVC + Thymeleaf** – server‑side rendered UI.
- **Spring Security** – form login, role‑based access.
- **Spring Data JPA** – MySQL persistence (`quan_ly_kho`).
- **Lombok** – boiler‑plate reduction.
- **ZXing** – QR‑code generation / decoding.
- **Apache POI** – Excel/CSV import‑export.

The project follows a classic layered architecture:

```
+--------------------------+   +----------------------+   +------------------------+
|   Controllers (Web)      | → |   Services (Biz)     | → |   Repositories (JPA)   |
+--------------------------+   +----------------------+   +------------------------+
          ↑                         ↑                              ↑
          |                         |                              |
   Thymeleaf Templates            |                     JPA Entities
   (HTML UI)                      |                     (DB tables)
          |                         |                              |
          └───────►  Security /  ─────┘   └─────►  Utilities (QR, POI)  ┘
```

* **Controllers** – HTTP endpoints (REST & page rendering).
* **Services** – business logic, transaction management.
* **Repositories** – Spring Data JPA interfaces.
* **Entities** – JPA‑mapped domain objects (e.g., `Product`, `WarehouseZone`).
* **DTOs** – request/response objects for API and UI forms.

---

## Main Functional Modules

| Module | Purpose | Key Packages |
|--------|---------|--------------|
| **Auth** | User & role management, login, registration | `modules.auth.*` |
| **Inventory** | Track stock levels, locations, history | `modules.inventory.*` |
| **Inbound** | Receiving goods, receipt processing | `modules.inbound.*` |
| **Outbound** | Picking, shipping, sales orders | `modules.outbound.*` |
| **Transfer** | Move items between locations | `modules.transfer.*` |
| **Purchase** | Purchase order creation & approval | `modules.purchase.*` |
| **Stocktake** | Periodic stock verification, alerts | `modules.stocktake.*` |
| **Dashboard** | Charts & KPI overview (uses `ChartDataDto`) | `modules.dashboard.*` |
| **Location** | Manage warehouses, zones, storage locations | `modules.Location.*` |
| **QR Code Utils** | Generate QR codes for products | `utils.QrCodeUtil` |

---

## Configuration

* **`src/main/resources/application.properties`** – DB connection, JPA settings, Thymeleaf cache disabled for development.
* **`WebConfig`** – MVC configuration, view resolvers.
* **`SecurityConfig`** – Spring Security chain, password encoder, role‑based URL protection.

---

## Build & Run

```bash
# Build the jar
./mvnw clean package

# Run (default port 8080)
java -jar target/warehouseqr-0.0.1-SNAPSHOT.jar
```

Access the UI at `http://localhost:8080/`. Default login: *admin* (password stored in the DB).

---

## Project Structure (selected)

```
src/main/java/com/tttn/warehouseqr/
│
├─ WarehouseqrApplication.java          # Spring Boot entry point
├─ config/
│   ├─ WebConfig.java
│   └─ SecurityConfig.java
├─ common/
│   ├─ util/SecurityUtils.java
│   └─ exception/ (global handlers)
│
├─ modules/
│   ├─ auth/        (User, Role, login, registration)
│   ├─ inventory/   (stock, location balances, history)
│   ├─ inbound/     (receipts, inbound items)
│   ├─ outbound/    (sales orders, picking)
│   ├─ transfer/    (transfer orders, items)
│   ├─ purchase/    (purchase orders, items)
│   ├─ stocktake/   (stocktake sessions, alerts)
│   ├─ dashboard/   (chart DTOs, view/controller)
│   └─ Location/    (warehouse, zone, storage location)
│
└─ utils/
    └─ QrCodeUtil.java                # QR code generation
```

---

## Templates

All UI pages are Thymeleaf HTML files under `src/main/resources/templates/`, grouped by feature (e.g., `inventory/`, `outbound/`, `stocktake/`, `auth/`, `masterdata/`, `dashboard/`). Layouts (`base.html`, `admin-layout.html`, `user-layout.html`) provide a consistent header, sidebar, and footer.

---

## Database

MySQL schema `quan_ly_kho`. Entities are auto‑mapped via `spring.jpa.hibernate.ddl-auto=update`. Key tables include:

* `user`, `role` – authentication.
* `product`, `inventory_location_balance`, `inventory_history`.
* `inbound_receipt`, `outbound_receipt`.
* `transfer_order`, `purchase_orders`.
* `stocktake_session`, `stocktake_item`.

---

## QR Code Feature

`QrCodeUtil` uses ZXing to encode product information as QR codes, which are displayed/printed from product‑related pages.

---

## Extending the Project

* Add new modules under `modules/` following the same **Controller → Service → Repository** pattern.
* Register routes in `WebConfig` if needed, or expose REST endpoints alongside Thymeleaf pages.
* Use Lombok (`@Getter/@Setter/@Builder`) for new DTOs/entities.

---
