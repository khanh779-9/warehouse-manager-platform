-- ============================================================================
-- HỆ THỐNG QUẢN LÝ KHO (Warehouse Management Platform)
-- ============================================================================
-- Mô tả: Cơ sở dữ liệu cho hệ thống quản lý kho hàng, quản lý nhập/xuất/tồn,
--        đơn hàng, chuyển kho, kiểm kê và các danh mục liên quan.
-- Phiên bản: 1.0
-- Ngày tạo: 05/07/2026
-- Database: MySQL 9.x
-- ============================================================================

-- Xóa database cũ nếu tồn tại và tạo mới
DROP DATABASE IF EXISTS `quan_ly_kho`;
CREATE DATABASE IF NOT EXISTS `quan_ly_kho`
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE `quan_ly_kho`;

-- ============================================================================
-- 1. DANH MỤC PHÂN QUYỀN (Roles)
-- ============================================================================
-- Bảng lưu trữ các vai trò/ quyền trong hệ thống
CREATE TABLE `roles` (
    `role_id`   BIGINT      NOT NULL AUTO_INCREMENT COMMENT 'Mã vai trò (khóa chính)',
    `role_name` VARCHAR(100) NOT NULL                COMMENT 'Tên vai trò (ví dụ: ROLE_ADMIN, ROLE_MANAGER, ROLE_STAFF, ROLE_USER)',
    PRIMARY KEY (`role_id`),
    UNIQUE KEY `uk_role_name` (`role_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Danh mục vai trò / quyền hệ thống';

-- ============================================================================
-- 2. NGƯỜI DÙNG (Users)
-- ============================================================================
-- Bảng lưu trữ thông tin tài khoản người dùng hệ thống
CREATE TABLE `users` (
    `user_id`      BIGINT       NOT NULL AUTO_INCREMENT COMMENT 'Mã người dùng (khóa chính)',
    `username`     VARCHAR(50)  NOT NULL                COMMENT 'Tên đăng nhập (duy nhất)',
    `password`     VARCHAR(60)  DEFAULT NULL            COMMENT 'Mật khẩu đã mã hóa (BCrypt)',
    `full_name`    VARCHAR(50)  DEFAULT NULL            COMMENT 'Họ và tên đầy đủ',
    `email`        VARCHAR(150) DEFAULT NULL            COMMENT 'Địa chỉ email (duy nhất)',
    `phone`        VARCHAR(20)  DEFAULT NULL            COMMENT 'Số điện thoại liên hệ',
    `cccd`         VARCHAR(20)  DEFAULT NULL            COMMENT 'Căn cước công dân / CMND',
    `gender`       VARCHAR(10)  DEFAULT NULL            COMMENT 'Giới tính (Nam/Nữ/Khác)',
    `date_of_birth` DATE        DEFAULT NULL            COMMENT 'Ngày sinh',
    `avatar`       VARCHAR(255) DEFAULT NULL            COMMENT 'Đường dẫn ảnh đại diện',
    `status`       VARCHAR(50)  DEFAULT 'ACTIVE'        COMMENT 'Trạng thái: ACTIVE (hoạt động), INACTIVE (không hoạt động), LOCKED (bị khóa)',
    `role_id`      BIGINT       DEFAULT NULL            COMMENT 'Mã vai trò (khóa ngoại đến roles)',
    `created_at`   DATETIME     DEFAULT CURRENT_TIMESTAMP COMMENT 'Thời gian tạo tài khoản',
    `updated_at`   DATETIME     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Thời gian cập nhật gần nhất',
    PRIMARY KEY (`user_id`),
    UNIQUE KEY `uk_username` (`username`),
    UNIQUE KEY `uk_email` (`email`),
    KEY `idx_user_role` (`role_id`),
    CONSTRAINT `fk_user_role` FOREIGN KEY (`role_id`) REFERENCES `roles` (`role_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Thông tin tài khoản người dùng';

-- ============================================================================
-- 3. CÔNG TY (Companies)
-- ============================================================================
-- Bảng lưu trữ thông tin công ty sở hữu hệ thống
CREATE TABLE `companies` (
    `company_id`   BIGINT       NOT NULL AUTO_INCREMENT COMMENT 'Mã công ty (khóa chính)',
    `company_name` VARCHAR(255) NOT NULL                COMMENT 'Tên công ty',
    `tax_code`     VARCHAR(50)  DEFAULT NULL            COMMENT 'Mã số thuế',
    `address`      TEXT         DEFAULT NULL            COMMENT 'Địa chỉ công ty',
    `phone`        VARCHAR(20)  DEFAULT NULL            COMMENT 'Số điện thoại công ty',
    `email`        VARCHAR(100) DEFAULT NULL            COMMENT 'Địa chỉ email công ty',
    PRIMARY KEY (`company_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Thông tin công ty';

-- ============================================================================
-- 4. KHÁCH HÀNG (Customers)
-- ============================================================================
-- Bảng lưu trữ thông tin khách hàng
CREATE TABLE `customers` (
    `customer_id`    BIGINT       NOT NULL AUTO_INCREMENT COMMENT 'Mã khách hàng (khóa chính)',
    `customer_code`  VARCHAR(50)  NOT NULL                COMMENT 'Mã khách hàng (duy nhất, tự sinh)',
    `customer_name`  VARCHAR(255) NOT NULL                COMMENT 'Tên khách hàng',
    `contact_person` VARCHAR(100) DEFAULT NULL            COMMENT 'Người liên hệ',
    `phone`          VARCHAR(20)  DEFAULT NULL            COMMENT 'Số điện thoại',
    `email`          VARCHAR(100) DEFAULT NULL            COMMENT 'Địa chỉ email',
    `address`        TEXT         DEFAULT NULL            COMMENT 'Địa chỉ khách hàng',
    PRIMARY KEY (`customer_id`),
    UNIQUE KEY `uk_customer_code` (`customer_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Thông tin khách hàng';

-- ============================================================================
-- 5. NHÀ CUNG CẤP (Suppliers)
-- ============================================================================
-- Bảng lưu trữ thông tin nhà cung cấp
CREATE TABLE `suppliers` (
    `supplier_id`    BIGINT       NOT NULL AUTO_INCREMENT COMMENT 'Mã nhà cung cấp (khóa chính)',
    `supplier_code`  VARCHAR(50)  NOT NULL                COMMENT 'Mã nhà cung cấp (duy nhất)',
    `supplier_name`  VARCHAR(255) NOT NULL                COMMENT 'Tên nhà cung cấp',
    `contact_person` VARCHAR(100) DEFAULT NULL            COMMENT 'Người liên hệ',
    `phone`          VARCHAR(20)  DEFAULT NULL            COMMENT 'Số điện thoại',
    `email`          VARCHAR(100) DEFAULT NULL            COMMENT 'Địa chỉ email',
    `address`        TEXT         DEFAULT NULL            COMMENT 'Địa chỉ nhà cung cấp',
    `is_active`      TINYINT(1)   DEFAULT 1               COMMENT 'Trạng thái hoạt động: 1 (còn sử dụng), 0 (ngừng sử dụng)',
    PRIMARY KEY (`supplier_id`),
    UNIQUE KEY `uk_supplier_code` (`supplier_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Thông tin nhà cung cấp';

-- ============================================================================
-- 6. ĐƠN VỊ TÍNH (Units)
-- ============================================================================
-- Bảng lưu trữ các đơn vị tính của sản phẩm (ví dụ: Chiếc, Hộp, Thùng)
CREATE TABLE `units` (
    `unit_id`   BIGINT       NOT NULL AUTO_INCREMENT COMMENT 'Mã đơn vị tính (khóa chính)',
    `unit_name` VARCHAR(100) NOT NULL                COMMENT 'Tên đơn vị tính (ví dụ: Chiếc, Hộp, Thùng)',
    PRIMARY KEY (`unit_id`),
    UNIQUE KEY `uk_unit_name` (`unit_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Danh mục đơn vị tính sản phẩm';

-- ============================================================================
-- 7. DANH MỤC SẢN PHẨM (Product Categories)
-- ============================================================================
-- Bảng lưu trữ các danh mục / nhóm sản phẩm
CREATE TABLE `product_categories` (
    `category_id`   BIGINT       NOT NULL AUTO_INCREMENT COMMENT 'Mã danh mục (khóa chính)',
    `category_code` VARCHAR(50)  NOT NULL                COMMENT 'Mã danh mục (duy nhất, ví dụ: DT, PK, LT)',
    `category_name` VARCHAR(255) NOT NULL                COMMENT 'Tên danh mục (ví dụ: Điện thoại di động, Phụ kiện công nghệ)',
    PRIMARY KEY (`category_id`),
    UNIQUE KEY `uk_category_code` (`category_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Danh mục nhóm sản phẩm';

-- ============================================================================
-- 8. SẢN PHẨM (Products)
-- ============================================================================
-- Bảng lưu trữ thông tin sản phẩm / hàng hóa
CREATE TABLE `products` (
    `product_id`   BIGINT        NOT NULL AUTO_INCREMENT COMMENT 'Mã sản phẩm (khóa chính)',
    `sku`          VARCHAR(100)  NOT NULL                COMMENT 'Mã SKU sản phẩm (duy nhất, dùng cho QR code)',
    `product_name` VARCHAR(255)  NOT NULL                COMMENT 'Tên sản phẩm',
    `description`  TEXT          DEFAULT NULL            COMMENT 'Mô tả sản phẩm',
    `min_stock`    DECIMAL(10,2) DEFAULT 0.00            COMMENT 'Tồn kho tối thiểu (cảnh báo khi tồn dưới mức này)',
    `category_id`  BIGINT        DEFAULT NULL            COMMENT 'Mã danh mục (khóa ngoại đến product_categories)',
    `unit_id`      BIGINT        DEFAULT NULL            COMMENT 'Mã đơn vị tính (khóa ngoại đến units)',
    PRIMARY KEY (`product_id`),
    UNIQUE KEY `uk_sku` (`sku`),
    KEY `idx_product_category` (`category_id`),
    KEY `idx_product_unit` (`unit_id`),
    CONSTRAINT `fk_product_category` FOREIGN KEY (`category_id`) REFERENCES `product_categories` (`category_id`),
    CONSTRAINT `fk_product_unit`     FOREIGN KEY (`unit_id`)     REFERENCES `units` (`unit_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Thông tin sản phẩm / hàng hóa';

-- ============================================================================
-- 9. LÔ SẢN PHẨM (Product Batches)
-- ============================================================================
-- Bảng lưu trữ thông tin lô hàng, số serial, giá vốn và hạn sử dụng
CREATE TABLE `product_batches` (
    `batch_id`      BIGINT        NOT NULL AUTO_INCREMENT COMMENT 'Mã lô hàng (khóa chính)',
    `lot_code`      VARCHAR(255)  NOT NULL                COMMENT 'Mã lô hàng (ví dụ: LOHANG-T4-01)',
    `serial_number` VARCHAR(255)  DEFAULT NULL            COMMENT 'Số serial của lô hàng',
    `cost_price`    DECIMAL(38,2) DEFAULT NULL            COMMENT 'Giá vốn nhập kho của lô',
    `expiry_date`   DATE          DEFAULT NULL            COMMENT 'Ngày hết hạn sử dụng',
    `product_id`    BIGINT        NOT NULL                COMMENT 'Mã sản phẩm (khóa ngoại đến products)',
    `supplier_id`   BIGINT        DEFAULT NULL            COMMENT 'Mã nhà cung cấp (khóa ngoại đến suppliers)',
    PRIMARY KEY (`batch_id`),
    KEY `idx_batch_product` (`product_id`),
    KEY `idx_batch_supplier` (`supplier_id`),
    CONSTRAINT `fk_batch_product`  FOREIGN KEY (`product_id`)  REFERENCES `products` (`product_id`),
    CONSTRAINT `fk_batch_supplier` FOREIGN KEY (`supplier_id`) REFERENCES `suppliers` (`supplier_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Thông tin lô hàng nhập kho';

-- ============================================================================
-- 10. MÃ QR (QR Codes)
-- ============================================================================
-- Bảng lưu trữ mã QR được tạo cho sản phẩm, lô hàng, vị trí,...
CREATE TABLE `qr_codes` (
    `qr_code_id`    BIGINT       NOT NULL AUTO_INCREMENT COMMENT 'Mã QR (khóa chính)',
    `qr_content`    TEXT         NOT NULL                COMMENT 'Nội dung dữ liệu mã QR',
    `img_path`      TEXT         DEFAULT NULL            COMMENT 'Đường dẫn file ảnh QR code',
    `reference_type` VARCHAR(50) DEFAULT NULL            COMMENT 'Loại đối tượng tham chiếu (BATCH, PRODUCT, LOCATION, SO_PICK, ...)',
    `reference_id`   BIGINT      DEFAULT NULL            COMMENT 'Mã đối tượng tham chiếu',
    `is_printed`    BIT(1)       DEFAULT NULL            COMMENT 'Đã in mã QR hay chưa (1: đã in, 0: chưa in)',
    PRIMARY KEY (`qr_code_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Thông tin mã QR code';

-- ============================================================================
-- 11. DỮ LIỆU NHẬP TẠM (Temp Import Data)
-- ============================================================================
-- Bảng lưu dữ liệu nhập hàng tạm thời từ file Excel/CSV trước khi xử lý
CREATE TABLE `temp_import_data` (
    `id`                 BIGINT       NOT NULL AUTO_INCREMENT COMMENT 'Mã bản ghi tạm (khóa chính)',
    `sku`                VARCHAR(255) DEFAULT NULL            COMMENT 'Mã SKU sản phẩm',
    `product_name`       VARCHAR(255) DEFAULT NULL            COMMENT 'Tên sản phẩm',
    `description`        VARCHAR(255) DEFAULT NULL            COMMENT 'Mô tả sản phẩm',
    `min_stock`          VARCHAR(255) DEFAULT NULL            COMMENT 'Tồn kho tối thiểu',
    `category_id`        VARCHAR(255) DEFAULT NULL            COMMENT 'Mã danh mục',
    `unit_id`            VARCHAR(255) DEFAULT NULL            COMMENT 'Mã đơn vị tính',
    `batch_code`         VARCHAR(255) DEFAULT NULL            COMMENT 'Mã lô hàng',
    `serial_num`         VARCHAR(255) DEFAULT NULL            COMMENT 'Số serial',
    `cost_price`         VARCHAR(255) DEFAULT NULL            COMMENT 'Giá vốn',
    `expiry_date`        VARCHAR(255) DEFAULT NULL            COMMENT 'Ngày hết hạn',
    `supplier_id`        VARCHAR(255) DEFAULT NULL            COMMENT 'Mã nhà cung cấp',
    `quantity`           VARCHAR(255) DEFAULT NULL            COMMENT 'Số lượng nhập',
    `location_code`      VARCHAR(255) DEFAULT NULL            COMMENT 'Mã vị trí lưu kho',
    `warehouse_id`       VARCHAR(255) DEFAULT NULL            COMMENT 'Mã kho nhập',
    `validation_status`  VARCHAR(255) DEFAULT NULL            COMMENT 'Trạng thái kiểm tra (VALID/INVALID)',
    `validation_message` VARCHAR(255) DEFAULT NULL            COMMENT 'Thông báo lỗi nếu có',
    `import_session_id`  VARCHAR(255) DEFAULT NULL            COMMENT 'Mã phiên nhập khẩu',
    `created_at`         TIMESTAMP    DEFAULT CURRENT_TIMESTAMP COMMENT 'Thời gian tạo bản ghi tạm',
    PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Dữ liệu nhập hàng tạm thời từ file Excel/CSV';

-- ============================================================================
-- 12. KHO (Warehouses)
-- ============================================================================
-- Bảng lưu trữ thông tin các kho hàng
CREATE TABLE `warehouses` (
    `warehouse_id`      BIGINT       NOT NULL AUTO_INCREMENT COMMENT 'Mã kho (khóa chính)',
    `warehouse_code`    VARCHAR(50)  NOT NULL                COMMENT 'Mã kho (duy nhất)',
    `warehouse_name`    VARCHAR(255) NOT NULL                COMMENT 'Tên kho',
    `warehouse_address` TEXT         DEFAULT NULL            COMMENT 'Địa chỉ kho',
    `address`           TEXT         DEFAULT NULL            COMMENT 'Địa chỉ (trùng lặp do lịch sử)',
    PRIMARY KEY (`warehouse_id`),
    UNIQUE KEY `uk_warehouse_code` (`warehouse_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Thông tin kho hàng';

-- ============================================================================
-- 13. KHU VỰC KHO (Warehouse Zones)
-- ============================================================================
-- Bảng lưu trữ các khu vực / zone trong kho
CREATE TABLE `warehouse_zones` (
    `zone_id`       BIGINT       NOT NULL AUTO_INCREMENT COMMENT 'Mã khu vực (khóa chính)',
    `zone_code`     VARCHAR(50)  NOT NULL                COMMENT 'Mã khu vực (duy nhất)',
    `zone_name`     VARCHAR(255) DEFAULT NULL            COMMENT 'Tên khu vực',
    `warehouse_id`  BIGINT       NOT NULL                COMMENT 'Mã kho (khóa ngoại đến warehouses)',
    `warehouses`    BIGINT       NOT NULL                COMMENT 'Trùng lặp với warehouse_id (do lịch sử)',
    PRIMARY KEY (`zone_id`),
    UNIQUE KEY `uk_zone_code` (`zone_code`),
    KEY `idx_zone_warehouse` (`warehouse_id`),
    CONSTRAINT `fk_zone_warehouse` FOREIGN KEY (`warehouse_id`) REFERENCES `warehouses` (`warehouse_id`),
    CONSTRAINT `fk_zone_warehouses` FOREIGN KEY (`warehouses`) REFERENCES `warehouses` (`warehouse_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Khu vực / Zone trong kho';

-- ============================================================================
-- 14. VỊ TRÍ KHO (Warehouse Locations)
-- ============================================================================
-- Bảng lưu trữ các vị trí lưu trữ hàng hóa trong kho (kệ, ngăn, ô)
CREATE TABLE `warehouse_locations` (
    `location_id`   BIGINT       NOT NULL AUTO_INCREMENT COMMENT 'Mã vị trí (khóa chính)',
    `location_code` VARCHAR(100) NOT NULL                COMMENT 'Mã vị trí (duy nhất, ví dụ: LOC-DEFAULT-01, KE-A-01)',
    `warehouse_id`  BIGINT       NOT NULL                COMMENT 'Mã kho (khóa ngoại đến warehouses)',
    `zone_id`       BIGINT       DEFAULT NULL            COMMENT 'Mã khu vực (khóa ngoại đến warehouse_zones)',
    `qr_code_id`    BIGINT       DEFAULT NULL            COMMENT 'Mã QR gắn tại vị trí (khóa ngoại đến qr_codes)',
    `aisle_code`    VARCHAR(50)  DEFAULT NULL            COMMENT 'Mã dãy / lối đi',
    `rack_code`     VARCHAR(50)  DEFAULT NULL            COMMENT 'Mã kệ',
    `bin_code`      VARCHAR(50)  DEFAULT NULL            COMMENT 'Mã ngăn / ô',
    `capacity`      INT          DEFAULT NULL            COMMENT 'Sức chứa tối đa (số lượng)',
    `used_capacity` INT          DEFAULT NULL            COMMENT 'Sức chứa đã dùng',
    `status`        VARCHAR(30)  DEFAULT NULL            COMMENT 'Trạng thái vị trí (AVAILABLE, OCCUPIED, ...)',
    `description`   VARCHAR(255) DEFAULT NULL            COMMENT 'Mô tả vị trí',
    PRIMARY KEY (`location_id`),
    UNIQUE KEY `uk_location_code` (`location_code`),
    KEY `idx_loc_warehouse` (`warehouse_id`),
    KEY `idx_loc_zone` (`zone_id`),
    KEY `idx_loc_qr` (`qr_code_id`),
    CONSTRAINT `fk_location_warehouse` FOREIGN KEY (`warehouse_id`) REFERENCES `warehouses`        (`warehouse_id`),
    CONSTRAINT `fk_location_zone`      FOREIGN KEY (`zone_id`)      REFERENCES `warehouse_zones`   (`zone_id`),
    CONSTRAINT `fk_location_qr`        FOREIGN KEY (`qr_code_id`)   REFERENCES `qr_codes`          (`qr_code_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Vị trí lưu trữ hàng hóa trong kho';

-- ============================================================================
-- 15. ĐƠN MUA HÀNG (Purchase Orders)
-- ============================================================================
-- Bảng lưu trữ đơn đặt hàng / đơn mua hàng từ nhà cung cấp
CREATE TABLE `purchase_orders` (
    `id`                    BIGINT        NOT NULL AUTO_INCREMENT COMMENT 'Mã đơn mua hàng (khóa chính)',
    `po_code`               VARCHAR(255)  DEFAULT NULL            COMMENT 'Mã đơn mua hàng (duy nhất)',
    `supplier_id`           BIGINT        NOT NULL                COMMENT 'Mã nhà cung cấp (khóa ngoại đến suppliers)',
    `warehouse_id`          BIGINT        DEFAULT NULL            COMMENT 'Mã kho nhận hàng (khóa ngoại đến warehouses)',
    `created_by`            BIGINT        DEFAULT NULL            COMMENT 'Người tạo đơn (khóa ngoại đến users)',
    `order_date`            DATETIME      DEFAULT CURRENT_TIMESTAMP COMMENT 'Ngày đặt hàng',
    `expected_delivery_date` DATETIME     DEFAULT NULL            COMMENT 'Ngày giao hàng dự kiến',
    `total_amount`          DECIMAL(38,2) DEFAULT NULL            COMMENT 'Tổng giá trị đơn hàng',
    `status`                VARCHAR(50)   DEFAULT NULL            COMMENT 'Trạng thái: DRAFT, OPEN, APPROVED, RECEIVED, CANCELLED',
    `notes`                 VARCHAR(255)  DEFAULT NULL            COMMENT 'Ghi chú',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_po_code` (`po_code`),
    KEY `idx_po_supplier` (`supplier_id`),
    KEY `idx_po_user` (`created_by`),
    KEY `idx_po_warehouse` (`warehouse_id`),
    CONSTRAINT `fk_po_supplier`  FOREIGN KEY (`supplier_id`)  REFERENCES `suppliers` (`supplier_id`),
    CONSTRAINT `fk_po_user`      FOREIGN KEY (`created_by`)   REFERENCES `users`     (`user_id`),
    CONSTRAINT `fk_po_warehouse` FOREIGN KEY (`warehouse_id`) REFERENCES `warehouses` (`warehouse_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Đơn mua hàng / Purchase Order';

-- ============================================================================
-- 16. CHI TIẾT ĐƠN MUA HÀNG (Purchase Order Items)
-- ============================================================================
-- Bảng lưu trữ chi tiết sản phẩm trong đơn mua hàng
CREATE TABLE `purchase_order_items` (
    `id`           BIGINT        NOT NULL AUTO_INCREMENT COMMENT 'Mã chi tiết (khóa chính)',
    `po_id`        BIGINT        NOT NULL                COMMENT 'Mã đơn mua hàng (khóa ngoại đến purchase_orders)',
    `product_id`   BIGINT        NOT NULL                COMMENT 'Mã sản phẩm (khóa ngoại đến products)',
    `ordered_qty`  DECIMAL(15,2) NOT NULL                COMMENT 'Số lượng đặt hàng',
    `received_qty` DECIMAL(15,2) DEFAULT 0.00            COMMENT 'Số lượng thực tế đã nhập kho',
    `unit_price`   DECIMAL(19,4) DEFAULT 0.0000          COMMENT 'Đơn giá nhập',
    `batch_id`     BIGINT        DEFAULT NULL            COMMENT 'Mã lô hàng (khóa ngoại đến product_batches)',
    PRIMARY KEY (`id`),
    KEY `idx_poi_po` (`po_id`),
    KEY `idx_poi_product` (`product_id`),
    KEY `idx_poi_batch` (`batch_id`),
    CONSTRAINT `fk_poi_po`      FOREIGN KEY (`po_id`)      REFERENCES `purchase_orders` (`id`),
    CONSTRAINT `fk_poi_product`  FOREIGN KEY (`product_id`) REFERENCES `products`        (`product_id`),
    CONSTRAINT `fk_poi_batch`    FOREIGN KEY (`batch_id`)   REFERENCES `product_batches`  (`batch_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Chi tiết sản phẩm trong đơn mua hàng';

-- ============================================================================
-- 17. PHIẾU NHẬP KHO (Inbound Receipts)
-- ============================================================================
-- Bảng lưu trữ các phiếu nhập kho
CREATE TABLE `inbound_receipts` (
    `id`                  BIGINT       NOT NULL AUTO_INCREMENT COMMENT 'Mã phiếu nhập (khóa chính)',
    `inbound_receipt_code` VARCHAR(50) NOT NULL                COMMENT 'Mã phiếu nhập (duy nhất, tự sinh)',
    `purchase_order_id`    BIGINT      DEFAULT NULL            COMMENT 'Đơn mua hàng liên quan (khóa ngoại đến purchase_orders)',
    `supplier_id`          BIGINT      DEFAULT NULL            COMMENT 'Mã nhà cung cấp (khóa ngoại đến suppliers)',
    `warehouse_id`         BIGINT      NOT NULL                COMMENT 'Mã kho nhập (khóa ngoại đến warehouses)',
    `created_by`           BIGINT      DEFAULT NULL            COMMENT 'Người nhập kho (khóa ngoại đến users)',
    `delivery_note_code`   VARCHAR(100) DEFAULT NULL           COMMENT 'Mã chứng từ giao hàng từ nhà cung cấp',
    `status`               VARCHAR(50) DEFAULT NULL            COMMENT 'Trạng thái: PENDING, COMPLETED, CANCELLED',
    `created_at`           DATETIME    DEFAULT CURRENT_TIMESTAMP COMMENT 'Thời gian tạo phiếu',
    `received_at`          DATETIME    DEFAULT NULL            COMMENT 'Thời gian nhập kho thực tế',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_inbound_code` (`inbound_receipt_code`),
    KEY `idx_inbound_user` (`created_by`),
    KEY `idx_inbound_supplier` (`supplier_id`),
    KEY `idx_inbound_warehouse` (`warehouse_id`),
    KEY `idx_inbound_po` (`purchase_order_id`),
    CONSTRAINT `fk_inbound_user`      FOREIGN KEY (`created_by`)         REFERENCES `users`           (`user_id`),
    CONSTRAINT `fk_inbound_supplier`  FOREIGN KEY (`supplier_id`)         REFERENCES `suppliers`       (`supplier_id`),
    CONSTRAINT `fk_inbound_warehouse` FOREIGN KEY (`warehouse_id`)        REFERENCES `warehouses`      (`warehouse_id`),
    CONSTRAINT `fk_inbound_po`        FOREIGN KEY (`purchase_order_id`)   REFERENCES `purchase_orders` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Phiếu nhập kho';

-- ============================================================================
-- 18. CHI TIẾT PHIẾU NHẬP KHO (Inbound Receipt Items)
-- ============================================================================
-- Bảng lưu trữ chi tiết sản phẩm trong phiếu nhập kho
CREATE TABLE `inbound_receipt_items` (
    `id`                  BIGINT        NOT NULL AUTO_INCREMENT COMMENT 'Mã chi tiết (khóa chính)',
    `inbound_receipt_id`   BIGINT        NOT NULL                COMMENT 'Mã phiếu nhập (khóa ngoại đến inbound_receipts)',
    `product_id`           BIGINT        NOT NULL                COMMENT 'Mã sản phẩm (khóa ngoại đến products)',
    `expected_qty`         DECIMAL(15,2) NOT NULL                COMMENT 'Số lượng dự kiến nhập',
    `actual_qty`           DECIMAL(15,2) DEFAULT NULL            COMMENT 'Số lượng thực tế nhập kho',
    `import_price`         DECIMAL(15,2) DEFAULT NULL            COMMENT 'Đơn giá nhập kho',
    `batch_id`             BIGINT        DEFAULT NULL            COMMENT 'Mã lô hàng (khóa ngoại đến product_batches)',
    `putaway_location_id`  BIGINT        DEFAULT NULL            COMMENT 'Vị trí lưu trữ (khóa ngoại đến warehouse_locations)',
    PRIMARY KEY (`id`),
    KEY `idx_ini_receipt` (`inbound_receipt_id`),
    KEY `idx_ini_product` (`product_id`),
    KEY `idx_ini_batch` (`batch_id`),
    KEY `idx_ini_location` (`putaway_location_id`),
    CONSTRAINT `fk_ini_receipt`  FOREIGN KEY (`inbound_receipt_id`)  REFERENCES `inbound_receipts`   (`id`),
    CONSTRAINT `fk_ini_product`  FOREIGN KEY (`product_id`)          REFERENCES `products`            (`product_id`),
    CONSTRAINT `fk_ini_batch`    FOREIGN KEY (`batch_id`)            REFERENCES `product_batches`     (`batch_id`),
    CONSTRAINT `fk_ini_location` FOREIGN KEY (`putaway_location_id`) REFERENCES `warehouse_locations` (`location_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Chi tiết sản phẩm trong phiếu nhập kho';

-- ============================================================================
-- 19. ĐƠN BÁN HÀNG (Sales Orders)
-- ============================================================================
-- Bảng lưu trữ đơn bán hàng / đơn hàng từ khách
CREATE TABLE `sales_orders` (
    `id`                       BIGINT        NOT NULL AUTO_INCREMENT COMMENT 'Mã đơn bán (khóa chính)',
    `so_code`                  VARCHAR(50)   NOT NULL                COMMENT 'Mã đơn bán hàng (duy nhất, tự sinh)',
    `customer_id`              BIGINT        DEFAULT NULL            COMMENT 'Mã khách hàng (khóa ngoại đến customers)',
    `customer_name`            VARCHAR(255)  DEFAULT NULL            COMMENT 'Tên khách hàng (dự phòng)',
    `status`                   VARCHAR(50)   DEFAULT 'PENDING'       COMMENT 'Trạng thái: DRAFT, PENDING, APPROVED, PARTIAL, COMPLETED, CANCELLED',
    `total_amount`             DECIMAL(19,4) DEFAULT 0.0000          COMMENT 'Tổng giá trị đơn hàng',
    `payment_status`           VARCHAR(50)   DEFAULT 'UNPAID'        COMMENT 'Trạng thái thanh toán: UNPAID, PAID, PARTIAL_PAID, REFUNDED',
    `payment_method`           VARCHAR(50)   DEFAULT NULL            COMMENT 'Phương thức thanh toán: COD, TRANSFER, CASH, DEBT',
    `payment_transaction_code` VARCHAR(100)  DEFAULT NULL            COMMENT 'Mã giao dịch thanh toán',
    `payment_note`             VARCHAR(500)  DEFAULT NULL            COMMENT 'Ghi chú thanh toán',
    `payment_confirmed_at`     DATETIME(6)   DEFAULT NULL            COMMENT 'Thời gian xác nhận thanh toán',
    `payment_confirmed_by`     BIGINT        DEFAULT NULL            COMMENT 'Người xác nhận thanh toán',
    `created_at`               DATETIME      DEFAULT CURRENT_TIMESTAMP COMMENT 'Thời gian tạo đơn',
    `updated_at`               DATETIME      DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Thời gian cập nhật gần nhất',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_so_code` (`so_code`),
    KEY `idx_so_customer` (`customer_id`),
    CONSTRAINT `fk_so_customer` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`customer_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Đơn bán hàng / Sales Order';

-- ============================================================================
-- 20. CHI TIẾT ĐƠN BÁN HÀNG (Sales Order Items)
-- ============================================================================
-- Bảng lưu trữ chi tiết sản phẩm trong đơn bán hàng
CREATE TABLE `sales_order_items` (
    `id`          BIGINT        NOT NULL AUTO_INCREMENT COMMENT 'Mã chi tiết (khóa chính)',
    `so_id`       BIGINT        NOT NULL                COMMENT 'Mã đơn bán (khóa ngoại đến sales_orders)',
    `product_id`  BIGINT        NOT NULL                COMMENT 'Mã sản phẩm (khóa ngoại đến products)',
    `quantity`    DECIMAL(15,2) NOT NULL                COMMENT 'Số lượng đặt hàng',
    `shipped_qty` DECIMAL(15,2) DEFAULT 0.00            COMMENT 'Số lượng đã xuất kho',
    `unit_price`  DECIMAL(19,4) DEFAULT NULL            COMMENT 'Đơn giá bán',
    PRIMARY KEY (`id`),
    KEY `idx_soi_so` (`so_id`),
    KEY `idx_soi_product` (`product_id`),
    CONSTRAINT `fk_soi_so`      FOREIGN KEY (`so_id`)      REFERENCES `sales_orders` (`id`),
    CONSTRAINT `fk_soi_product`  FOREIGN KEY (`product_id`) REFERENCES `products`     (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Chi tiết sản phẩm trong đơn bán hàng';

-- ============================================================================
-- 21. PHIẾU XUẤT KHO (Outbound Receipts)
-- ============================================================================
-- Bảng lưu trữ các phiếu xuất kho
CREATE TABLE `outbound_receipts` (
    `id`                    BIGINT       NOT NULL AUTO_INCREMENT COMMENT 'Mã phiếu xuất (khóa chính)',
    `outbound_receipt_code` VARCHAR(50)  NOT NULL                COMMENT 'Mã phiếu xuất (duy nhất, tự sinh)',
    `status`                VARCHAR(50)  DEFAULT NULL            COMMENT 'Trạng thái: PENDING, SHIPPED, PARTIAL, CANCELLED',
    `warehouse_id`          BIGINT       NOT NULL                COMMENT 'Mã kho xuất (khóa ngoại đến warehouses)',
    `customer_id`           BIGINT       DEFAULT NULL            COMMENT 'Mã khách hàng (khóa ngoại đến customers)',
    `created_by`            BIGINT       DEFAULT NULL            COMMENT 'Người xuất kho (khóa ngoại đến users)',
    `created_at`            DATETIME     DEFAULT CURRENT_TIMESTAMP COMMENT 'Thời gian tạo phiếu xuất',
    `shipped_at`            DATETIME     DEFAULT NULL            COMMENT 'Thời gian xuất kho thực tế',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_outbound_code` (`outbound_receipt_code`),
    KEY `idx_outbound_user` (`created_by`),
    KEY `idx_outbound_warehouse` (`warehouse_id`),
    KEY `idx_outbound_customer` (`customer_id`),
    CONSTRAINT `fk_outbound_user`      FOREIGN KEY (`created_by`)   REFERENCES `users`      (`user_id`),
    CONSTRAINT `fk_outbound_warehouse` FOREIGN KEY (`warehouse_id`) REFERENCES `warehouses` (`warehouse_id`),
    CONSTRAINT `fk_outbound_customer`  FOREIGN KEY (`customer_id`)  REFERENCES `customers`  (`customer_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Phiếu xuất kho';

-- ============================================================================
-- 22. CHI TIẾT PHIẾU XUẤT KHO (Outbound Receipt Items)
-- ============================================================================
-- Bảng lưu trữ chi tiết sản phẩm trong phiếu xuất kho
CREATE TABLE `outbound_receipt_items` (
    `id`                  BIGINT        NOT NULL AUTO_INCREMENT COMMENT 'Mã chi tiết (khóa chính)',
    `outbound_receipt_id` BIGINT        NOT NULL                COMMENT 'Mã phiếu xuất (khóa ngoại đến outbound_receipts)',
    `product_id`          BIGINT        NOT NULL                COMMENT 'Mã sản phẩm (khóa ngoại đến products)',
    `requested_qty`       DECIMAL(38,2) DEFAULT NULL            COMMENT 'Số lượng yêu cầu xuất',
    `actual_qty`          DECIMAL(38,2) DEFAULT NULL            COMMENT 'Số lượng thực tế xuất kho',
    `selling_price`       DECIMAL(15,2) DEFAULT NULL            COMMENT 'Giá bán (cột cũ)',
    `price`               DOUBLE        DEFAULT NULL            COMMENT 'Giá bán (cột mới)',
    `batch_id`            BIGINT        DEFAULT NULL            COMMENT 'Mã lô hàng (khóa ngoại đến product_batches)',
    `picked_location_id`  BIGINT        DEFAULT NULL            COMMENT 'Vị trí lấy hàng (khóa ngoại đến warehouse_locations)',
    PRIMARY KEY (`id`),
    KEY `idx_outi_receipt` (`outbound_receipt_id`),
    KEY `idx_outi_product` (`product_id`),
    KEY `idx_outi_batch` (`batch_id`),
    KEY `idx_outi_location` (`picked_location_id`),
    CONSTRAINT `fk_outi_receipt`  FOREIGN KEY (`outbound_receipt_id`) REFERENCES `outbound_receipts`  (`id`),
    CONSTRAINT `fk_outi_product`  FOREIGN KEY (`product_id`)          REFERENCES `products`            (`product_id`),
    CONSTRAINT `fk_outi_batch`    FOREIGN KEY (`batch_id`)            REFERENCES `product_batches`     (`batch_id`),
    CONSTRAINT `fk_outi_location` FOREIGN KEY (`picked_location_id`)  REFERENCES `warehouse_locations` (`location_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Chi tiết sản phẩm trong phiếu xuất kho';

-- ============================================================================
-- 23. BẢN GHI CHỐNG TRÙNG LẶP XUẤT KHO (Outbound Idempotency Records)
-- ============================================================================
-- Bảng lưu trữ các khóa idempotency để chống xử lý trùng khi xuất kho
CREATE TABLE `outbound_idempotency_records` (
    `id`                  BIGINT        NOT NULL AUTO_INCREMENT COMMENT 'Mã bản ghi (khóa chính)',
    `idempotency_key`     VARCHAR(128)  NOT NULL                COMMENT 'Khóa idempotency (duy nhất, UUID)',
    `outbound_receipt_id` BIGINT        DEFAULT NULL            COMMENT 'Mã phiếu xuất đã xử lý',
    `status`              VARCHAR(20)   NOT NULL                COMMENT 'Trạng thái: COMPLETED, FAILED',
    `created_at`          DATETIME(6)   NOT NULL                COMMENT 'Thời gian tạo',
    `updated_at`          DATETIME(6)   NOT NULL                COMMENT 'Thời gian cập nhật',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_outbound_idempotency_key` (`idempotency_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Chống trùng lặp khi xử lý xuất kho';

-- ============================================================================
-- 24. SỐ DƯ TỒN KHO THEO VỊ TRÍ (Inventory Location Balances)
-- ============================================================================
-- Bảng lưu trữ số lượng tồn kho hiện tại theo từng vị trí, sản phẩm và lô
CREATE TABLE `inventory_location_balances` (
    `id`           BIGINT        NOT NULL AUTO_INCREMENT COMMENT 'Mã bản ghi (khóa chính)',
    `warehouse_id` BIGINT        NOT NULL                COMMENT 'Mã kho (khóa ngoại đến warehouses)',
    `location_id`  BIGINT        NOT NULL                COMMENT 'Mã vị trí (khóa ngoại đến warehouse_locations)',
    `product_id`   BIGINT        NOT NULL                COMMENT 'Mã sản phẩm (khóa ngoại đến products)',
    `batch_id`     BIGINT        DEFAULT NULL            COMMENT 'Mã lô hàng (khóa ngoại đến product_batches)',
    `qty`          DECIMAL(15,2) DEFAULT 0.00            COMMENT 'Số lượng tồn kho hiện tại',
    `status`       VARCHAR(50)   DEFAULT NULL            COMMENT 'Trạng thái: AVAILABLE, RESERVED, DAMAGED, ...',
    `update_at`    DATETIME      DEFAULT NULL            COMMENT 'Thời gian cập nhật gần nhất',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_balance_unique` (`warehouse_id`, `location_id`, `product_id`, `batch_id`),
    KEY `idx_balance_warehouse` (`warehouse_id`),
    KEY `idx_balance_location` (`location_id`),
    KEY `idx_balance_product` (`product_id`),
    KEY `idx_balance_batch` (`batch_id`),
    CONSTRAINT `fk_balance_warehouse` FOREIGN KEY (`warehouse_id`) REFERENCES `warehouses`        (`warehouse_id`),
    CONSTRAINT `fk_balance_location`  FOREIGN KEY (`location_id`)  REFERENCES `warehouse_locations` (`location_id`),
    CONSTRAINT `fk_balance_product`  FOREIGN KEY (`product_id`)   REFERENCES `products`            (`product_id`),
    CONSTRAINT `fk_balance_batch`    FOREIGN KEY (`batch_id`)     REFERENCES `product_batches`     (`batch_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Số dư tồn kho theo vị trí, sản phẩm và lô hàng';

-- ============================================================================
-- 25. LỊCH SỬ TỒN KHO (Inventory History)
-- ============================================================================
-- Bảng lưu trữ lịch sử biến động tồn kho (nhập, xuất, chuyển, điều chỉnh)
CREATE TABLE `inventory_history` (
    `id`               BIGINT        NOT NULL AUTO_INCREMENT COMMENT 'Mã bản ghi (khóa chính)',
    `transaction_type` VARCHAR(50)   DEFAULT NULL            COMMENT 'Loại giao dịch: INBOUND (nhập), OUTBOUND (xuất), TRANSFER (chuyển), ADJUSTMENT (điều chỉnh)',
    `warehouse_id`     BIGINT        NOT NULL                COMMENT 'Mã kho (khóa ngoại đến warehouses)',
    `product_id`       BIGINT        NOT NULL                COMMENT 'Mã sản phẩm (khóa ngoại đến products)',
    `batch_id`         BIGINT        DEFAULT NULL            COMMENT 'Mã lô hàng (khóa ngoại đến product_batches)',
    `from_location_id` BIGINT        DEFAULT NULL            COMMENT 'Vị trí nguồn (khóa ngoại đến warehouse_locations)',
    `to_location_id`   BIGINT        DEFAULT NULL            COMMENT 'Vị trí đích (khóa ngoại đến warehouse_locations)',
    `qty_change`       DECIMAL(38,2) DEFAULT NULL            COMMENT 'Số lượng thay đổi (dương: nhập vào, âm: xuất ra)',
    `qr_code_id`       BIGINT        DEFAULT NULL            COMMENT 'Mã QR liên quan (khóa ngoại đến qr_codes)',
    `user_id`          BIGINT        DEFAULT NULL            COMMENT 'Người thực hiện (khóa ngoại đến users)',
    `created_at`       DATETIME      DEFAULT CURRENT_TIMESTAMP COMMENT 'Thời gian giao dịch',
    PRIMARY KEY (`id`),
    KEY `idx_history_warehouse` (`warehouse_id`),
    KEY `idx_history_product` (`product_id`),
    KEY `idx_history_batch` (`batch_id`),
    KEY `idx_history_from_loc` (`from_location_id`),
    KEY `idx_history_to_loc` (`to_location_id`),
    KEY `idx_history_qr` (`qr_code_id`),
    KEY `idx_history_user` (`user_id`),
    CONSTRAINT `fk_history_warehouse` FOREIGN KEY (`warehouse_id`)     REFERENCES `warehouses`        (`warehouse_id`),
    CONSTRAINT `fk_history_product`   FOREIGN KEY (`product_id`)      REFERENCES `products`            (`product_id`),
    CONSTRAINT `fk_history_batch`     FOREIGN KEY (`batch_id`)        REFERENCES `product_batches`     (`batch_id`),
    CONSTRAINT `fk_history_from_loc`  FOREIGN KEY (`from_location_id`)REFERENCES `warehouse_locations` (`location_id`),
    CONSTRAINT `fk_history_to_loc`    FOREIGN KEY (`to_location_id`)  REFERENCES `warehouse_locations` (`location_id`),
    CONSTRAINT `fk_history_qr`        FOREIGN KEY (`qr_code_id`)      REFERENCES `qr_codes`            (`qr_code_id`),
    CONSTRAINT `fk_history_user`      FOREIGN KEY (`user_id`)         REFERENCES `users`               (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Lịch sử biến động tồn kho';

-- ============================================================================
-- 26. PHIẾU KIỂM KÊ (Stocktake Sessions)
-- ============================================================================
-- Bảng lưu trữ các phiên kiểm kê kho
CREATE TABLE `stocktake_sessions` (
    `id`           BIGINT       NOT NULL AUTO_INCREMENT COMMENT 'Mã phiên kiểm kê (khóa chính)',
    `session_code` VARCHAR(255) NOT NULL                COMMENT 'Mã phiên kiểm kê (duy nhất)',
    `warehouse_id` BIGINT       NOT NULL                COMMENT 'Mã kho kiểm kê (khóa ngoại đến warehouses)',
    `created_by`   BIGINT       DEFAULT NULL            COMMENT 'Người tạo phiên kiểm kê (khóa ngoại đến users)',
    `created_at`   DATETIME     DEFAULT CURRENT_TIMESTAMP COMMENT 'Thời gian tạo phiên',
    `status`       VARCHAR(50)  DEFAULT NULL            COMMENT 'Trạng thái: DRAFT, IN_PROGRESS, COMPLETED, CANCELLED',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_session_code` (`session_code`),
    KEY `idx_stock_user` (`created_by`),
    KEY `idx_stock_warehouse` (`warehouse_id`),
    CONSTRAINT `fk_stock_user`      FOREIGN KEY (`created_by`)   REFERENCES `users`      (`user_id`),
    CONSTRAINT `fk_stock_warehouse` FOREIGN KEY (`warehouse_id`) REFERENCES `warehouses` (`warehouse_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Phiên kiểm kê kho';

-- ============================================================================
-- 27. CHI TIẾT KIỂM KÊ (Stocktake Items)
-- ============================================================================
-- Bảng lưu trữ chi tiết kết quả kiểm kê từng sản phẩm
CREATE TABLE `stocktake_items` (
    `id`          BIGINT        NOT NULL AUTO_INCREMENT COMMENT 'Mã chi tiết kiểm kê (khóa chính)',
    `session_id`  BIGINT        NOT NULL                COMMENT 'Mã phiên kiểm kê (khóa ngoại đến stocktake_sessions)',
    `product_id`  BIGINT        NOT NULL                COMMENT 'Mã sản phẩm (khóa ngoại đến products)',
    `location_id` BIGINT        DEFAULT NULL            COMMENT 'Mã vị trí (khóa ngoại đến warehouse_locations)',
    `batch_id`    BIGINT        DEFAULT NULL            COMMENT 'Mã lô hàng (khóa ngoại đến product_batches)',
    `system_qty`  DECIMAL(38,2) DEFAULT NULL            COMMENT 'Số lượng trên hệ thống',
    `actual_qty`  DECIMAL(38,2) DEFAULT NULL            COMMENT 'Số lượng thực tế đếm được',
    `variance_qty` DECIMAL(38,2) DEFAULT NULL           COMMENT 'Chênh lệch = actual_qty - system_qty',
    PRIMARY KEY (`id`),
    KEY `idx_sti_session` (`session_id`),
    KEY `idx_sti_product` (`product_id`),
    KEY `idx_sti_location` (`location_id`),
    KEY `idx_sti_batch` (`batch_id`),
    CONSTRAINT `fk_sti_session`  FOREIGN KEY (`session_id`)  REFERENCES `stocktake_sessions` (`id`),
    CONSTRAINT `fk_sti_product`  FOREIGN KEY (`product_id`)  REFERENCES `products`            (`product_id`),
    CONSTRAINT `fk_sti_location` FOREIGN KEY (`location_id`) REFERENCES `warehouse_locations` (`location_id`),
    CONSTRAINT `fk_sti_batch`    FOREIGN KEY (`batch_id`)    REFERENCES `product_batches`     (`batch_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Chi tiết kết quả kiểm kê sản phẩm';

-- ============================================================================
-- 28. LỆNH CHUYỂN KHO (Transfer Orders)
-- ============================================================================
-- Bảng lưu trữ các lệnh chuyển hàng giữa các kho
CREATE TABLE `transfer_orders` (
    `id`                 BIGINT       NOT NULL AUTO_INCREMENT COMMENT 'Mã lệnh chuyển (khóa chính)',
    `transfer_code`      VARCHAR(255) DEFAULT NULL            COMMENT 'Mã lệnh chuyển kho (duy nhất)',
    `from_warehouse_id`  BIGINT       NOT NULL                COMMENT 'Kho nguồn (khóa ngoại đến warehouses)',
    `to_warehouse_id`    BIGINT       NOT NULL                COMMENT 'Kho đích (khóa ngoại đến warehouses)',
    `outbound_receipt_id` BIGINT      DEFAULT NULL            COMMENT 'Phiếu xuất kho liên quan (khóa ngoại đến outbound_receipts)',
    `created_by`         BIGINT       DEFAULT NULL            COMMENT 'Người tạo lệnh (khóa ngoại đến users)',
    `transfer_date`      DATETIME     DEFAULT NULL            COMMENT 'Ngày chuyển',
    `status`             VARCHAR(50)  DEFAULT NULL            COMMENT 'Trạng thái: DRAFT, PENDING, IN_TRANSIT, COMPLETED, CANCELLED',
    `created_at`         DATETIME     DEFAULT CURRENT_TIMESTAMP COMMENT 'Thời gian tạo lệnh',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_transfer_code` (`transfer_code`),
    KEY `idx_transfer_from_wh` (`from_warehouse_id`),
    KEY `idx_transfer_to_wh` (`to_warehouse_id`),
    KEY `idx_transfer_outbound` (`outbound_receipt_id`),
    KEY `idx_transfer_user` (`created_by`),
    CONSTRAINT `fk_transfer_from_wh` FOREIGN KEY (`from_warehouse_id`)   REFERENCES `warehouses`        (`warehouse_id`),
    CONSTRAINT `fk_transfer_to_wh`   FOREIGN KEY (`to_warehouse_id`)     REFERENCES `warehouses`        (`warehouse_id`),
    CONSTRAINT `fk_transfer_outbound`FOREIGN KEY (`outbound_receipt_id`)REFERENCES `outbound_receipts` (`id`),
    CONSTRAINT `fk_transfer_user`    FOREIGN KEY (`created_by`)          REFERENCES `users`             (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Lệnh chuyển hàng giữa các kho';

-- ============================================================================
-- 29. CHI TIẾT LỆNH CHUYỂN KHO (Transfer Order Items)
-- ============================================================================
-- Bảng lưu trữ chi tiết sản phẩm trong lệnh chuyển kho
CREATE TABLE `transfer_order_items` (
    `id`               BIGINT        NOT NULL AUTO_INCREMENT COMMENT 'Mã chi tiết (khóa chính)',
    `transfer_order_id` BIGINT       NOT NULL                COMMENT 'Mã lệnh chuyển (khóa ngoại đến transfer_orders)',
    `product_id`       BIGINT        NOT NULL                COMMENT 'Mã sản phẩm (khóa ngoại đến products)',
    `batch_id`         BIGINT        DEFAULT NULL            COMMENT 'Mã lô hàng (khóa ngoại đến product_batches)',
    `qty`              DECIMAL(38,2) DEFAULT NULL            COMMENT 'Số lượng chuyển',
    `from_location_id` BIGINT        NOT NULL                COMMENT 'Vị trí lấy hàng (khóa ngoại đến warehouse_locations)',
    `to_location_id`   BIGINT        DEFAULT NULL            COMMENT 'Vị trí đích (khóa ngoại đến warehouse_locations)',
    `to_warehouse_id`  BIGINT        DEFAULT NULL            COMMENT 'Kho đích (khóa ngoại đến warehouses)',
    PRIMARY KEY (`id`),
    KEY `idx_tfi_order` (`transfer_order_id`),
    KEY `idx_tfi_product` (`product_id`),
    KEY `idx_tfi_batch` (`batch_id`),
    KEY `idx_tfi_from_loc` (`from_location_id`),
    KEY `idx_tfi_to_loc` (`to_location_id`),
    KEY `idx_tfi_to_wh` (`to_warehouse_id`),
    CONSTRAINT `fk_tfi_order`    FOREIGN KEY (`transfer_order_id`) REFERENCES `transfer_orders`    (`id`),
    CONSTRAINT `fk_tfi_product`  FOREIGN KEY (`product_id`)       REFERENCES `products`            (`product_id`),
    CONSTRAINT `fk_tfi_batch`    FOREIGN KEY (`batch_id`)         REFERENCES `product_batches`     (`batch_id`),
    CONSTRAINT `fk_tfi_from_loc` FOREIGN KEY (`from_location_id`) REFERENCES `warehouse_locations` (`location_id`),
    CONSTRAINT `fk_tfi_to_loc`   FOREIGN KEY (`to_location_id`)   REFERENCES `warehouse_locations` (`location_id`),
    CONSTRAINT `fk_tfi_to_wh`    FOREIGN KEY (`to_warehouse_id`)  REFERENCES `warehouses`          (`warehouse_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Chi tiết sản phẩm trong lệnh chuyển kho';

-- ============================================================================
-- DỮ LIỆU MẪU (Seed Data)
-- ============================================================================

-- ============================================================================
-- 1. DANH MỤC PHÂN QUYỀN
-- ============================================================================
INSERT INTO `roles` (`role_id`, `role_name`) VALUES
(1, 'ROLE_ADMIN'),
(2, 'ROLE_MANAGER'),
(3, 'ROLE_STAFF'),
(4, 'ROLE_USER');

-- ============================================================================
-- 2. NGƯỜI DÙNG
-- ============================================================================
-- Mật khẩu đã mã hóa BCrypt (mặc định: 123456)
INSERT INTO `users` (`user_id`, `username`, `password`, `full_name`, `email`, `phone`, `cccd`, `gender`, `date_of_birth`, `avatar`, `status`, `role_id`, `created_at`, `updated_at`) VALUES
(1, 'admin',     '$2a$10$oC37m/7Qk1CxfGpdYrES8e570OQX3L9GGmD3qR4.AgNiVxB/CzCQa', 'Administrator',     'admin@example.com',    '0123456789', NULL, NULL, NULL, NULL, 'ACTIVE', 1, '2026-01-01 00:00:00', '2026-01-01 00:00:00'),
(2, 'manager',   '$2a$10$HsE3UuGkO7iZTNmhYPjE3.s3X2uvitDRl8fcrknP7k0AU3t3quDVS', 'Nguyễn Văn Quản Lý', 'manager@warehouse.com', '0987654321', NULL, NULL, NULL, NULL, 'ACTIVE', 2, '2026-01-01 00:00:00', '2026-01-01 00:00:00'),
(3, 'staff',     '$2a$10$HC7kAEHRXY2NFEIFHBhaSufIRo7SjQbYpZZYMa53JgO8rvoFfhVy2', 'Trần Thị Nhân Viên', 'staff@warehouse.com',   '0111222333', NULL, NULL, NULL, NULL, 'ACTIVE', 3, '2026-01-01 00:00:00', '2026-01-01 00:00:00'),
(4, 'user',      '$2a$10$GEy42Lpg3PkQD9M6OLOew.40cTk5hmgCqziv2FkZJs6HuZIQPZ2ym', 'Lê Văn Người Dùng',  'user@example.com',     '0444555666', NULL, NULL, NULL, NULL, 'ACTIVE', 4, '2026-01-01 00:00:00', '2026-01-01 00:00:00');

-- ============================================================================
-- 3. CÔNG TY
-- ============================================================================
INSERT INTO `companies` (`company_id`, `company_name`, `tax_code`, `address`, `phone`, `email`) VALUES
(1, 'Công ty TNHH Quản Lý Kho Thông Minh', '0123456789', 'Số 123 Đường Lê Lợi, Quận 1, TP. Hồ Chí Minh', '02838223344', 'info@warehouse.vn');

-- ============================================================================
-- 4. KHÁCH HÀNG
-- ============================================================================
INSERT INTO `customers` (`customer_id`, `customer_code`, `customer_name`, `contact_person`, `phone`, `email`, `address`) VALUES
(1, 'KH001', 'Công ty Công nghệ Việt Nam',        NULL,                '0901234567', NULL,                         'Số 1 Đống Đa, Hà Nội'),
(2, 'KH003', 'Công ty Công nghệ Việt Nam',        NULL,                '0901234567', NULL,                         'Số 3 Bình Thới, Cao Bằng'),
(3, 'CUS001', 'Công ty TNHH Bán Lẻ Sao Mai',      'Nguyễn Minh Tuấn',  '0908111222', 'tuan.nguyen@saomai.vn',    '15 Nguyễn Văn Linh, Quận 7, TP.HCM'),
(4, 'CUS002', 'Công ty CP Thương Mại Hoàng Gia',  'Trần Thị Hoa',      '0919222333', 'hoa.tran@hoanggia.vn',     '120 Lê Duẩn, Hải Châu, Đà Nẵng'),
(5, 'CUS003', 'Cửa hàng Thiết bị An Phát',        'Lê Quốc Bảo',       '0927333444', 'bao.le@anphat.vn',         '34 Hùng Vương, Ninh Kiều, Cần Thơ'),
(6, 'CUS004', 'Siêu thị Mini Minh Châu',           'Phạm Ngọc Anh',     '0936444555', 'anh.pham@minhchau.vn',     '8 Võ Thị Sáu, Biên Hòa, Đồng Nai'),
(7, 'CUS005', 'Công ty TNHH Kỹ Thuật Việt Tin',   'Đỗ Thành Sơn',      '0945555666', 'son.do@viettin.vn',        '56 Trần Phú, Hà Đông, Hà Nội'),
(8, 'CUS006', 'Nhà phân phối Phương Nam',          'Bùi Thị Lan',       '0954666777', 'lan.bui@phuongnam.vn',     '91 Cách Mạng Tháng 8, Nha Trang'),
(9, 'CUS007', 'Công ty CP Vận Tải Quốc Tế Á Châu', 'Ngô Văn Hiếu',      '0963777888', 'hieu.ngo@achau.vn',        '22 Bạch Đằng, Hải Phòng'),
(10, 'CUS008', 'Cửa hàng Gia dụng Thành Công',     'Võ Thị Mỹ',         '0972888999', 'my.vo@thanhcong.vn',       '10 Quang Trung, Vũng Tàu');

-- ============================================================================
-- 5. NHÀ CUNG CẤP
-- ============================================================================
INSERT INTO `suppliers` (`supplier_id`, `supplier_code`, `supplier_name`, `contact_person`, `phone`, `email`, `address`, `is_active`) VALUES
(1, 'NCC-001', 'Nhà Cung Cấp Mặc Định',             NULL,                NULL,         NULL,                          NULL,                                                    1),
(2, 'SUP001',  'Công ty TNHH Thiết Bị Sao Việt',    'Nguyễn Văn An',     '0901234567', 'an.nguyen@saoviet.vn',       '12 Nguyễn Trãi, Q1, TP.HCM',                           1),
(3, 'SUP002',  'Công ty CP Phân Phối Minh Long',    'Trần Thị Bình',     '0912345678', 'binh.tran@minhlong.vn',      '88 Điện Biên Phủ, Bình Thạnh, TP.HCM',                 1),
(4, 'SUP003',  'Công ty TNHH Vật Tư Đông Á',        'Lê Quốc Cường',     '0923456789', 'cuong.le@donga.vn',          '45 Lê Lợi, Hải Châu, Đà Nẵng',                        1),
(5, 'SUP004',  'Công ty CP Logistics Hưng Phát',    'Phạm Thu Dung',     '0934567890', 'dung.pham@hungphat.vn',      '102 Trần Hưng Đạo, Hoàn Kiếm, Hà Nội',                1),
(6, 'SUP005',  'Công ty TNHH TM Nam Khánh',         'Võ Minh Đức',       '0945678901', 'duc.vo@namkhanh.vn',         '27 Phan Chu Trinh, Ninh Kiều, Cần Thơ',                1),
(7, 'SUP006',  'Công ty CP Công Nghiệp Đại Việt',   'Đỗ Gia Huy',        '0956789012', 'huy.do@daiviet.vn',          '156 Hùng Vương, TP. Thủ Đức, TP.HCM',                 1),
(8, 'SUP007',  'Công ty TNHH Kỹ Thuật Tân Tiến',    'Ngô Thị Lan',        '0967890123', 'lan.ngo@tantien.vn',         '9 Lý Thường Kiệt, TP. Vũng Tàu',                      1),
(9, 'SUP008',  'Công ty CP Thương Mại Á Châu',      'Bùi Văn Nam',        '0978901234', 'nam.bui@achau.vn',           '63 Nguyễn Huệ, Huế',                                   0);

-- ============================================================================
-- 6. ĐƠN VỊ TÍNH
-- ============================================================================
INSERT INTO `units` (`unit_id`, `unit_name`) VALUES
(1, 'Chiếc'),
(2, 'Hộp'),
(3, 'Thùng');

-- ============================================================================
-- 7. DANH MỤC SẢN PHẨM
-- ============================================================================
INSERT INTO `product_categories` (`category_id`, `category_code`, `category_name`) VALUES
(1, 'DT', 'Điện thoại di động'),
(2, 'PK', 'Phụ kiện công nghệ'),
(3, 'LT', 'Laptop & Máy tính bảng');

-- ============================================================================
-- 8. SẢN PHẨM
-- ============================================================================
INSERT INTO `products` (`product_id`, `sku`, `product_name`, `description`, `min_stock`, `category_id`, `unit_id`) VALUES
(1,  'TEST-PRO-001', 'Sản phẩm Test',               'Sản phẩm dùng để test',                              0.00,  1, 1),
(10, 'TEST-PRO-010', 'Sản phẩm Test Outbound',      'Sản phẩm test xuất kho',                             0.00,  1, 1),
(65, 'LAP-001',      'Laptop Dell XPS 15',           'Core i7 16GB RAM 512GB SSD',                        5.00,  3, 1),
(66, 'LAP-002',      'MacBook Air M3',               'Apple M3 8GB RAM 256GB SSD',                        10.00, 3, 1),
(67, 'LAP-003',      'Lenovo ThinkPad X1 Carbon',    'Carbon Gen 11 Core i7',                             5.00,  3, 1),
(68, 'PHN-001',      'iPhone 15 Pro Max',            'Titanium 256GB',                                     10.00, 1, 1),
(69, 'PHN-002',      'Samsung Galaxy S24 Ultra',     'AI Phone 512GB',                                     10.00, 1, 1),
(70, 'PHN-003',      'Xiaomi 14 Pro',                'Leica Camera 256GB',                                 15.00, 1, 1),
(71, 'AUD-001',      'Tai nghe Sony WH-1000XM5',     'Chống ồn chủ động cao cấp',                         20.00, 2, 1),
(72, 'AUD-002',      'AirPods Pro 2',                'Tai nghe không dây Apple',                           30.00, 2, 1),
(73, 'AUD-003',      'Loa Bluetooth Marshall Stanmore III', 'Loa decor công suất lớn',                     10.00, 2, 1),
(74, 'ACC-001',      'Cáp sạc Anker PowerLine III',  'Cáp USB-C to USB-C 100W',                           50.00, 2, 1),
(75, 'ACC-002',      'Củ sạc Baseus GaN5 Pro',       'Sạc nhanh 65W 3 cổng',                              40.00, 2, 1),
(76, 'ACC-003',      'Sạc dự phòng Ugreen 20000mAh', 'Sạc nhanh PD 20W',                                   30.00, 2, 1),
(77, 'MON-001',      'Màn hình LG UltraGear 27inch', '27GL850 144Hz 1ms',                                  5.00,  2, 1),
(78, 'MON-002',      'Màn hình Dell UltraSharp 27inch', 'U2723QE 4K USB-C',                               5.00,  2, 1),
(79, 'MON-003',      'Giá đỡ màn hình NB F80',       'Arm màn hình 17-30 inch',                           20.00, 2, 1),
(80, 'LAP-023',      'Asus ROG Zephyrus G14',        'Ryzen 9 16GB RAM 1TB SSD',                          8.00,  3, 1),
(81, 'TAB-001',      'iPad Pro 11 inch M4',           'Apple M4 256GB Wifi',                               15.00, 1, 1),
(82, 'ACC-020',      'Chuột Logitech MX Master 3S',  'Chuột không dây công thái học',                     20.00, 2, 1),
(83, 'MS-G304',      'Chuột không dây Logitech G304', NULL,                                                 0.00,  2, 1),
(84, 'KB-AK3068',    'Bàn phím cơ Akko 3068',         NULL,                                                 0.00,  2, 1),
(85, 'LAP-085',      'Laptop Dell XPS 15 (2024)',     'Core i7 16GB RAM 512GB SSD',                        5.00,  3, 1),
(86, 'TEST-IMP-001', 'Sản phẩm Import Test',          'Mô tả sản phẩm import',                             57.00, 1, 1);

-- ============================================================================
-- 9. LÔ SẢN PHẨM
-- ============================================================================
INSERT INTO `product_batches` (`batch_id`, `lot_code`, `serial_number`, `cost_price`, `expiry_date`, `product_id`, `supplier_id`) VALUES
(1,   'BATCH-2026-001',  NULL,              NULL,       NULL,          1,  1),
(37,  'LOHANG-T4-01',    'SN-DELL-1001',    35000000.00, '2028-12-31', 65, 1),
(38,  'LOHANG-T4-01',    'SN-MAC-2002',     25000000.00, '2029-01-01', 66, 2),
(39,  'LOHANG-T4-02',    'SN-LEN-3003',     40000000.00, '2028-10-15', 67, 3),
(40,  'LOHANG-T4-02',    'SN-IP-1001',      30000000.00, '2027-09-30', 68, 2),
(41,  'LOHANG-T4-03',    'SN-SAM-2002',     28000000.00, '2027-01-31', 69, 4),
(42,  'LOHANG-T4-03',    'SN-XIA-3003',     20000000.00, '2026-12-31', 70, 5),
(43,  'LOHANG-T4-04',    'SN-SONY-101',     7500000.00,  '2026-06-30', 71, 6),
(44,  'LOHANG-T4-04',    'SN-AIR-202',      6000000.00,  '2026-12-31', 72, 2),
(45,  'LOHANG-T4-04',    'SN-MAR-303',      9000000.00,  '2027-05-15', 73, 7),
(46,  'LOHANG-T4-05',    'SN-ANK-001',      300000.00,   NULL,          74, 8),
(47,  'LOHANG-T4-05',    'SN-BAS-002',      600000.00,   NULL,          75, 9),
(48,  'LOHANG-T4-05',    'SN-UGR-003',      800000.00,   '2028-01-01', 76, 10),
(49,  'LOHANG-T4-06',    'SN-LG-001',       8500000.00,  '2029-05-20', 77, 11),
(50,  'LOHANG-T4-06',    'SN-DELL-002',     12000000.00, '2029-08-15', 78, 1),
(51,  'LOHANG-T4-06',    NULL,              500000.00,   NULL,          79, 12),
(52,  'LOHANG-T4-03',    'SN-ASUS-4004',    32000000.00, '2029-05-20', 80, 4),
(53,  'LOHANG-T4-03',    'SN-IPAD-5005',    24000000.00, '2029-05-20', 81, 2),
(54,  'LOHANG-T4-04',    'SN-LOGI-001',     2500000.00,  '2029-05-20', 82, 5),
(100, 'LOT-SUMMER-01',   NULL,              NULL,       NULL,          10, 2),
(102, 'LOTTEST-01',      NULL,              560000.00,   NULL,          86, NULL);

-- ============================================================================
-- 10. MÃ QR
-- ============================================================================
INSERT INTO `qr_codes` (`qr_code_id`, `qr_content`, `img_path`, `reference_type`, `reference_id`, `is_printed`) VALUES
(1,  'LAP-001|LOHANG-T4-01',     NULL, 'BATCH',    37,  b'0'),
(2,  'LAP-002|LOHANG-T4-01',     NULL, 'BATCH',    38,  b'0'),
(3,  'LAP-003|LOHANG-T4-02',     NULL, 'BATCH',    39,  b'0'),
(4,  'PHN-001|LOHANG-T4-02',     NULL, 'BATCH',    40,  b'0'),
(5,  'PHN-002|LOHANG-T4-03',     NULL, 'BATCH',    41,  b'0'),
(6,  'PHN-003|LOHANG-T4-03',     NULL, 'BATCH',    42,  b'0'),
(7,  'AUD-001|LOHANG-T4-04',     NULL, 'BATCH',    43,  b'0'),
(8,  'AUD-002|LOHANG-T4-04',     NULL, 'BATCH',    44,  b'0'),
(9,  'AUD-003|LOHANG-T4-04',     NULL, 'BATCH',    45,  b'0'),
(10, 'ACC-001|LOHANG-T4-05',     NULL, 'BATCH',    46,  b'0'),
(11, 'ACC-002|LOHANG-T4-05',     NULL, 'BATCH',    47,  b'0'),
(12, 'ACC-003|LOHANG-T4-05',     NULL, 'BATCH',    48,  b'0'),
(13, 'MON-001|LOHANG-T4-06',     NULL, 'BATCH',    49,  b'0'),
(14, 'MON-002|LOHANG-T4-06',     NULL, 'BATCH',    50,  b'0'),
(15, 'MON-003|LOHANG-T4-06',     NULL, 'BATCH',    51,  b'0'),
(16, 'LAP-023|LOHANG-T4-03',     NULL, 'BATCH',    52,  b'0'),
(17, 'TAB-001|LOHANG-T4-03',     NULL, 'BATCH',    53,  b'0'),
(18, 'ACC-020|LOHANG-T4-04',     NULL, 'BATCH',    54,  b'0'),
(19, 'TEST-PRO-001|LOT-SUMMER-01', NULL, 'BATCH',  100, b'0'),
(20, 'TEST-IMP-001|LOTTEST-01',  NULL, 'BATCH',    102, b'0');

-- ============================================================================
-- 12. KHO
-- ============================================================================
INSERT INTO `warehouses` (`warehouse_id`, `warehouse_code`, `warehouse_name`, `warehouse_address`, `address`) VALUES
(1, 'WH-MAIN', 'Kho Tổng', 'Số 1 đường Giải Phóng, Hoàng Mai, Hà Nội', NULL),
(2, 'WH-HCM',  'Kho Hồ Chí Minh', 'Số 123 đường Nguyễn Văn Linh, Quận 7, TP.HCM', NULL);

-- ============================================================================
-- 14. VỊ TRÍ KHO
-- ============================================================================
INSERT INTO `warehouse_locations` (`location_id`, `location_code`, `warehouse_id`, `zone_id`, `qr_code_id`, `aisle_code`, `rack_code`, `bin_code`, `capacity`, `used_capacity`, `status`, `description`) VALUES
(1,  'LOC-DEFAULT-01', 1, NULL, NULL, NULL, NULL, NULL,  NULL, NULL, NULL,       'Vị trí mặc định'),
(10, 'KE-A-01',        1, NULL, NULL, NULL, NULL, NULL,  NULL, NULL, NULL,       'Kệ A - Tầng 1'),
(11, 'KE-B-02',        1, NULL, NULL, NULL, NULL, NULL,  NULL, NULL, NULL,       'Kệ B - Tầng 2');

-- ============================================================================
-- 15. ĐƠN MUA HÀNG
-- ============================================================================
INSERT INTO `purchase_orders` (`id`, `po_code`, `supplier_id`, `warehouse_id`, `created_by`, `order_date`, `expected_delivery_date`, `total_amount`, `status`, `notes`) VALUES
(1,  'PO-2026-001',  1, NULL, NULL, '2026-04-08 00:32:27', NULL, 0.00,   'OPEN', NULL),
(10, 'PO-TEST-001',  2, 1,    NULL, '2026-04-08 01:08:50', NULL, 0.00,   'OPEN', NULL),
(11, 'PO-2026-002',  2, 1,    1,    '2026-04-18 20:35:07', NULL, 519000000.00, 'DRAFT', NULL);

-- ============================================================================
-- 16. CHI TIẾT ĐƠN MUA HÀNG
-- ============================================================================
INSERT INTO `purchase_order_items` (`id`, `po_id`, `product_id`, `ordered_qty`, `received_qty`, `unit_price`, `batch_id`) VALUES
(1, 1,  1,  100.00, 0.00,   0.0000,     1),
(2, 10, 65, 50.00,  400.00, 500000.0000, 1),
(3, 10, 66, 20.00,  160.00, 1200000.0000, 1),
(4, 11, 78, 50.00,  0.00,   2500000.0000, 50),
(5, 11, 86, 70.00,  0.00,   3000000.0000, 102),
(6, 11, 81, 80.00,  0.00,   2300000.0000, 53);

-- ============================================================================
-- 17. PHIẾU NHẬP KHO
-- ============================================================================
INSERT INTO `inbound_receipts` (`id`, `inbound_receipt_code`, `purchase_order_id`, `supplier_id`, `warehouse_id`, `created_by`, `delivery_note_code`, `status`, `created_at`, `received_at`) VALUES
(1,  'PN-2026-001', NULL, NULL, 1, NULL, NULL, 'COMPLETED', '2026-04-08 00:20:42', '2026-04-08 00:20:42'),
(2,  'PN-2026-002', 1,    1,     1, NULL, NULL, 'COMPLETED', '2026-04-08 00:24:24', '2026-04-08 00:24:24'),
(15, 'PN-2026-015', 10,   NULL, 1, NULL, NULL, 'COMPLETED', '2026-04-08 01:51:58', '2026-04-08 01:51:58'),
(44, 'PN-2026-044', NULL, 4,     1, NULL, NULL, 'COMPLETED', '2026-04-12 15:55:16', '2026-04-12 15:55:16'),
(51, 'PN-2026-051', NULL, 3,     1, NULL, NULL, 'COMPLETED', '2026-04-15 19:31:59', '2026-04-15 19:31:59'),
(52, 'PN-2026-052', NULL, 2,     1, 1,    NULL, 'COMPLETED', '2026-04-17 14:13:37', '2026-04-17 14:13:37'),
(54, 'PN-2026-054', NULL, 5,     1, 1,    NULL, 'COMPLETED', '2026-04-17 15:16:55', '2026-04-17 15:16:55');

-- ============================================================================
-- 18. CHI TIẾT PHIẾU NHẬP KHO
-- ============================================================================
INSERT INTO `inbound_receipt_items` (`id`, `inbound_receipt_id`, `product_id`, `expected_qty`, `actual_qty`, `import_price`, `batch_id`, `putaway_location_id`) VALUES
(1,  1,  65, 50.00, 50.00, NULL,      1,  1),
(2,  1,  66, 20.00, 20.00, NULL,      1,  1),
(3,  15, 65, 50.00, 50.00, NULL,      1,  1),
(4,  15, 66, 20.00, 20.00, NULL,      1,  1),
(60, 44, 82, 6.00,  6.00,  110000.00, 54, 1),
(61, 44, 80, 5.00,  5.00,  130000.00, 52, 10),
(62, 44, 67, 4.00,  4.00,  240000.00, 39, 1),
(63, 44, 69, 3.00,  3.00,  720000.00, 41, 11),
(64, 44, 73, 2.00,  2.00,  560000.00, 45, 10),
(95, 51, 10, 57.00, 57.00, 49999.00,  100, 1),
(96, 51, 74, 20.00, 20.00, 300000.00, 46, 1),
(97, 51, 72, 4.00,  4.00,  6000000.00, 44, 1),
(98, 52, 86, 50.00, 50.00, 560000.00, 102, 10),
(100, 54, 73, 30.00, 30.00, 9000000.00, 45, 10);

-- ============================================================================
-- 19. ĐƠN BÁN HÀNG
-- ============================================================================
INSERT INTO `sales_orders` (`id`, `so_code`, `customer_id`, `customer_name`, `status`, `total_amount`, `payment_status`, `payment_method`, `payment_transaction_code`, `payment_note`, `payment_confirmed_at`, `payment_confirmed_by`, `created_at`, `updated_at`) VALUES
(1,   'SO-2026-TEST',       NULL, 'Khách hàng Test',           'DRAFT',    0.00,       'PAID',   'DEBT',    NULL, NULL, NULL, NULL, '2026-04-08 14:18:51', '2026-04-17 15:37:57'),
(101, 'SO-TEST-999',        1,    'Khách hàng Test SOP',       'PENDING',  50000000.00, 'PAID',   'TRANSFER', '12', 'xuất kho gấp', '2026-04-17 03:07:11.518579', 1, '2026-04-16 21:25:41', '2026-04-16 21:28:53'),
(105, 'SO-TEST-001',        NULL, 'Khách Test SQL',            'PENDING',  2000000.00,  'PAID',   'CASH',    '2', '2', '2026-04-17 03:44:38.673479', 1, '2026-04-17 03:14:17', '2026-04-17 03:46:28'),
(107, 'SO-TRAMTEST-001',    1,    'Khách Test Trạm Trưởng',    'PENDING',  100000000.00,'PAID',   'CASH',    '1', '1', '2026-04-17 13:43:53.685229', 1, '2026-04-17 13:35:32', '2026-04-17 13:45:13'),
(108, 'SO-2026-MOCK01',     3,    'Công ty TNHH Bán Lẻ Sao Mai', 'PENDING', 140000000.00,'PAID',   'CASH',    '1', 'thanh toán r', '2026-04-17 14:40:35.440454', 1, '2026-04-17 14:39:12', '2026-04-17 15:01:34'),
(111, 'SO-2026-MOCK02',     4,    'Công ty CP Thương Mại Hoàng Gia', 'PENDING', 210000000.00, 'PAID', 'CASH', '12', 'tiền mặt', '2026-04-17 15:49:35.591569', 1, '2026-04-17 15:14:58', '2026-04-17 15:50:46'),
(113, 'SO-2026-RAW01',      1,    'Công ty Công nghệ Việt Nam', 'PENDING', 61000000.00, 'PAID', 'TRANSFER', '12', '000', '2026-04-17 15:41:03.726693', 1, '2026-04-17 15:18:09', '2026-04-17 15:43:49'),
(115, 'SO-2026-RAW03',      6,    'Siêu thị Mini Minh Châu',    'PENDING', 94000000.00, 'PAID', 'CASH',    'gh', 'tm', '2026-04-17 16:29:58.836676', 1, '2026-04-17 15:18:10', '2026-04-17 16:31:03');

-- ============================================================================
-- 20. CHI TIẾT ĐƠN BÁN HÀNG
-- ============================================================================
INSERT INTO `sales_order_items` (`id`, `so_id`, `product_id`, `quantity`, `shipped_qty`, `unit_price`) VALUES
(1,  1,   10, 5.00,  0.00, NULL),
(3,  101, 65, 2.00,  2.00, 25000000.0000),
(7,  105, 65, 2.00,  1.00, 1000000.0000),
(8,  107, 65, 2.00,  1.00, 35000000.0000),
(9,  107, 68, 1.00,  1.00, 30000000.0000),
(10, 108, 65, 2.00,  1.00, 25000000.0000),
(11, 108, 68, 3.00,  1.00, 30000000.0000),
(14, 111, 66, 5.00,  5.00, 30000000.0000),
(15, 111, 72, 10.00, 0.00, 6000000.0000),
(18, 113, 65, 1.00,  1.00, 25000000.0000),
(19, 113, 71, 2.00,  0.00, 7500000.0000),
(20, 113, 74, 7.00,  7.00, 3000000.0000),
(22, 115, 68, 2.00,  2.00, 30000000.0000),
(23, 115, 70, 1.00,  0.00, 20000000.0000),
(24, 115, 75, 2.00,  0.00, 7000000.0000);

-- ============================================================================
-- 21. PHIẾU XUẤT KHO
-- ============================================================================
INSERT INTO `outbound_receipts` (`id`, `outbound_receipt_code`, `status`, `warehouse_id`, `customer_id`, `created_by`, `created_at`, `shipped_at`) VALUES
(1,  'PX-2026-001', 'SHIPPED', 1, 1,   1, '2026-04-08 14:34:13', '2026-04-08 14:34:13'),
(2,  'PX-2026-002', 'SHIPPED', 1, 1,   1, '2026-04-08 14:35:00', '2026-04-08 14:35:00'),
(16, 'PX-2026-016', 'SHIPPED', 1, 7,   1, '2026-04-12 13:26:45', '2026-04-12 13:26:45'),
(17, 'PX-2026-017', 'SHIPPED', 1, 1,   1, '2026-04-12 15:39:08', '2026-04-12 15:39:08'),
(34, 'PX-2026-034', 'SHIPPED', 1, 8,   1, '2026-04-15 18:49:29', '2026-04-15 18:49:29'),
(41, 'PX-2026-041', 'SHIPPED', 1, NULL, 1, '2026-04-17 13:45:13', '2026-04-17 13:45:13'),
(44, 'PX-2026-044', 'SHIPPED', 1, NULL, 1, '2026-04-17 15:43:49', '2026-04-17 15:43:49'),
(45, 'PX-2026-045', 'SHIPPED', 1, 999, 1, '2026-04-17 15:50:46', '2026-04-17 15:50:46'),
(46, 'PX-2026-046', 'PARTIAL', 1, 10,  1, '2026-04-17 16:31:03', '2026-04-17 16:31:03');

-- ============================================================================
-- 22. CHI TIẾT PHIẾU XUẤT KHO
-- ============================================================================
INSERT INTO `outbound_receipt_items` (`id`, `outbound_receipt_id`, `product_id`, `requested_qty`, `actual_qty`, `selling_price`, `price`, `batch_id`, `picked_location_id`) VALUES
(1,  1,  65, 5.00,  5.00,  NULL, NULL, 1,  1),
(2,  2,  65, 5.00,  10.00, NULL, NULL, 37, 10),
(36, 16, 82, 1.00,  1.00,  NULL, NULL, 54, 1),
(37, 16, 80, 1.00,  1.00,  NULL, NULL, 52, 10),
(38, 16, 67, 1.00,  1.00,  NULL, NULL, 39, 1),
(39, 16, 69, 2.00,  2.00,  NULL, NULL, 41, 11),
(40, 16, 73, 1.00,  1.00,  NULL, NULL, 45, 10),
(41, 17, 82, 6.00,  6.00,  NULL, NULL, 54, 1),
(42, 17, 80, 5.00,  5.00,  NULL, NULL, 52, 10),
(43, 17, 67, 4.00,  4.00,  NULL, NULL, 39, 1),
(44, 17, 69, 3.00,  3.00,  NULL, NULL, 41, 11),
(45, 17, 73, 2.00,  2.00,  NULL, NULL, 45, 10),
(119, 34, 67, 4.00,  4.00,  NULL, 240000.00, 39, 1),
(120, 34, 69, 3.00,  3.00,  NULL, 720000.00, 41, 11),
(121, 34, 73, 2.00,  2.00,  NULL, 560000.00, 45, 10),
(129, 41, 68, 1.00,  1.00,  NULL, 0.00, 40, 1),
(130, 41, 65, 2.00,  1.00,  NULL, 0.00, 37, 1),
(135, 44, 74, 7.00,  7.00,  NULL, 3000000.00, 46, 1),
(136, 44, 71, 2.00,  0.00,  NULL, 7500000.00, 1,  1),
(137, 44, 65, 1.00,  1.00,  NULL, 25000000.00, 37, 1),
(138, 45, 72, 10.00, 0.00,  NULL, 6000000.00, 1,  1),
(139, 45, 66, 5.00,  5.00,  NULL, 30000000.00, 1,  1),
(140, 46, 75, 2.00,  0.00,  NULL, 7000000.00, 1,  1),
(141, 46, 70, 1.00,  0.00,  NULL, 20000000.00, 1, 1),
(142, 46, 68, 2.00,  2.00,  NULL, 30000000.00, 40, 1);

-- ============================================================================
-- 24. SỐ DƯ TỒN KHO THEO VỊ TRÍ
-- ============================================================================
INSERT INTO `inventory_location_balances` (`id`, `warehouse_id`, `location_id`, `product_id`, `batch_id`, `qty`, `status`, `update_at`) VALUES
(1,  1, 1,  65, 1,   148.00, 'AVAILABLE', '2026-04-08 17:58:22'),
(2,  1, 1,  66, 1,   55.00,  'AVAILABLE', '2026-04-08 17:58:22'),
(3,  1, 1,  79, 51,  37.00,  'AVAILABLE', '2026-04-12 12:37:22'),
(4,  1, 1,  65, 37,  6.00,   'AVAILABLE', '2026-04-12 12:37:22'),
(5,  1, 1,  68, 40,  15.00,  'AVAILABLE', '2026-04-12 12:37:22'),
(6,  1, 1,  82, 54,  7.00,   'AVAILABLE', '2026-04-15 19:25:10'),
(7,  1, 10, 80, 52,  5.00,   'AVAILABLE', '2026-04-15 19:25:10'),
(8,  1, 1,  67, 39,  7.00,   'AVAILABLE', '2026-04-15 19:25:10'),
(9,  1, 11, 69, 41,  6.00,   'AVAILABLE', '2026-04-15 19:25:10'),
(10, 1, 10, 73, 45,  38.00,  'AVAILABLE', '2026-04-17 15:16:55'),
(11, 1, 1,  10, 100, 57.00,  'AVAILABLE', '2026-04-15 19:31:59'),
(12, 1, 1,  74, 46,  8.00,   'AVAILABLE', '2026-04-15 19:31:59'),
(13, 1, 1,  72, 44,  0.00,   'AVAILABLE', '2026-04-15 19:31:59'),
(14, 1, 10, 86, 102, 100.00, 'AVAILABLE', '2026-04-17 14:16:09');

-- ============================================================================
-- 25. LỊCH SỬ TỒN KHO
-- ============================================================================
INSERT INTO `inventory_history` (`id`, `transaction_type`, `warehouse_id`, `product_id`, `batch_id`, `from_location_id`, `to_location_id`, `qty_change`, `qr_code_id`, `user_id`, `created_at`) VALUES
(1,   'INBOUND',  1, 65, NULL, NULL, 1,  50.00,  NULL, NULL, '2026-04-08 01:51:58'),
(2,   'INBOUND',  1, 66, NULL, NULL, 1,  20.00,  NULL, NULL, '2026-04-08 01:51:58'),
(3,   'INBOUND',  1, 65, NULL, NULL, 1,  50.00,  NULL, NULL, '2026-04-08 02:11:03'),
(4,   'INBOUND',  1, 66, NULL, NULL, 1,  20.00,  NULL, NULL, '2026-04-08 02:11:03'),
(11,  'OUTBOUND', 1, 65, 1,    1,  NULL, -5.00,  NULL, NULL, '2026-04-08 14:34:13'),
(12,  'OUTBOUND', 1, 65, 37,   10, NULL, -10.00, NULL, NULL, '2026-04-08 14:34:59'),
(85,  'INBOUND',  1, 82, 54,   NULL, 1,  6.00,   NULL, NULL, '2026-04-12 13:26:22'),
(86,  'INBOUND',  1, 80, 52,   NULL, 10, 5.00,   NULL, NULL, '2026-04-12 13:26:22'),
(87,  'INBOUND',  1, 67, 39,   NULL, 1,  4.00,   NULL, NULL, '2026-04-12 13:26:22'),
(88,  'INBOUND',  1, 69, 41,   NULL, 11, 3.00,   NULL, NULL, '2026-04-12 13:26:22'),
(89,  'INBOUND',  1, 73, 45,   NULL, 10, 2.00,   NULL, NULL, '2026-04-12 13:26:22'),
(90,  'OUTBOUND', 1, 82, 54,   1,   NULL, -1.00,  NULL, NULL, '2026-04-12 13:26:45'),
(91,  'OUTBOUND', 1, 80, 52,   10,  NULL, -1.00,  NULL, NULL, '2026-04-12 13:26:45'),
(92,  'OUTBOUND', 1, 67, 39,   1,   NULL, -1.00,  NULL, NULL, '2026-04-12 13:26:45'),
(93,  'OUTBOUND', 1, 69, 41,   11,  NULL, -2.00,  NULL, NULL, '2026-04-12 13:26:45'),
(94,  'OUTBOUND', 1, 73, 45,   10,  NULL, -1.00,  NULL, NULL, '2026-04-12 13:26:45'),
(105, 'INBOUND',  1, 82, 54,   NULL, 1,  6.00,   NULL, NULL, '2026-04-12 15:55:16'),
(106, 'INBOUND',  1, 80, 52,   NULL, 10, 5.00,   NULL, NULL, '2026-04-12 15:55:16'),
(107, 'INBOUND',  1, 67, 39,   NULL, 1,  4.00,   NULL, NULL, '2026-04-12 15:55:16'),
(108, 'INBOUND',  1, 69, 41,   NULL, 11, 3.00,   NULL, NULL, '2026-04-12 15:55:16'),
(109, 'INBOUND',  1, 73, 45,   NULL, 10, 2.00,   NULL, NULL, '2026-04-12 15:55:16'),
(218, 'INBOUND',  1, 10, 100,  NULL, 1,  57.00,  NULL, NULL, '2026-04-15 19:31:58'),
(219, 'INBOUND',  1, 74, 46,   NULL, 1,  20.00,  NULL, NULL, '2026-04-15 19:31:58'),
(220, 'INBOUND',  1, 72, 44,   NULL, 1,  4.00,   NULL, NULL, '2026-04-15 19:31:58'),
(228, 'INBOUND',  1, 86, 102,  NULL, 10, 50.00,  NULL, NULL, '2026-04-17 14:13:37'),
(229, 'INBOUND',  1, 86, 102,  NULL, 10, 50.00,  NULL, NULL, '2026-04-17 14:16:08'),
(234, 'INBOUND',  1, 73, 45,   NULL, 10, 30.00,  NULL, NULL, '2026-04-17 15:16:55');

-- ============================================================================
-- 23. BẢN GHI CHỐNG TRÙNG LẶP XUẤT KHO
-- ============================================================================
INSERT INTO `outbound_idempotency_records` (`id`, `idempotency_key`, `outbound_receipt_id`, `status`, `created_at`, `updated_at`) VALUES
(1, '7950cddf-e5d3-407d-8b43-30d6eccf9eaa', 39, 'COMPLETED', '2026-04-17 02:50:23.000000', '2026-04-17 02:50:23.000000'),
(2, '7df828f0-ac38-4460-99c6-8ca7c0ec54e8', 40, 'COMPLETED', '2026-04-17 03:46:28.000000', '2026-04-17 03:46:28.000000'),
(3, '6da821fd-5e26-4686-859c-671c297bf440', 41, 'COMPLETED', '2026-04-17 13:45:13.000000', '2026-04-17 13:45:13.000000'),
(4, '8c96a0a5-1a8e-4d73-b551-3a61cbf0526d', 42, 'COMPLETED', '2026-04-17 15:01:34.000000', '2026-04-17 15:01:34.000000'),
(5, 'c05744e8-be81-45df-81d0-86f58f86c720', 43, 'COMPLETED', '2026-04-17 15:05:16.000000', '2026-04-17 15:05:16.000000'),
(6, '0a78760e-c6c1-4ba2-8ecc-7793091b9897', 44, 'COMPLETED', '2026-04-17 15:43:48.000000', '2026-04-17 15:43:48.000000'),
(7, 'b301cdcd-ee5e-4313-8749-3665adae2a84', 45, 'COMPLETED', '2026-04-17 15:50:46.000000', '2026-04-17 15:50:46.000000'),
(8, '6f1786fe-1fb1-4deb-bf70-774b3d156412', 46, 'COMPLETED', '2026-04-17 16:31:02.000000', '2026-04-17 16:31:02.000000');
