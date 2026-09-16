/* =========================================================
   AZMA MARKETPLACE
   REFUND + ADMIN CHAT MIGRATION
========================================================= */

USE railway;


/* =========================================================
   1. EXTEND ORDERS
========================================================= */


/* =========================================================
   TEMPORARY PROCEDURE FOR MYSQL-COMPATIBLE COLUMN MIGRATION
========================================================= */

DROP PROCEDURE IF EXISTS azma_refund_order_columns;

DELIMITER $$

CREATE PROCEDURE azma_refund_order_columns()
BEGIN

    DECLARE v_exists INT DEFAULT 0;


    /* ---------------------------------------------------------
       REFUND STATUS
    --------------------------------------------------------- */

    SELECT COUNT(*)
    INTO v_exists
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'orders'
      AND COLUMN_NAME = 'refund_status';

    IF v_exists = 0 THEN

        ALTER TABLE orders
        ADD COLUMN refund_status
        ENUM(
            'none',
            'pending',
            'processing',
            'completed',
            'failed',
            'cancelled'
        )
        NOT NULL DEFAULT 'none'
        AFTER refund_reason;

    END IF;


    /* ---------------------------------------------------------
       WHO REQUESTED / INITIATED THE REFUND
    --------------------------------------------------------- */

    SELECT COUNT(*)
    INTO v_exists
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'orders'
      AND COLUMN_NAME = 'refund_requested_by';

    IF v_exists = 0 THEN

        ALTER TABLE orders
        ADD COLUMN refund_requested_by
        BIGINT UNSIGNED NULL
        AFTER refund_status;

    END IF;


    /* ---------------------------------------------------------
       WHEN REFUND WAS REQUESTED
    --------------------------------------------------------- */

    SELECT COUNT(*)
    INTO v_exists
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'orders'
      AND COLUMN_NAME = 'refund_requested_at';

    IF v_exists = 0 THEN

        ALTER TABLE orders
        ADD COLUMN refund_requested_at
        DATETIME NULL
        AFTER refund_requested_by;

    END IF;


    /* ---------------------------------------------------------
       ADMIN WHO PROCESSED THE REFUND
    --------------------------------------------------------- */

    SELECT COUNT(*)
    INTO v_exists
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'orders'
      AND COLUMN_NAME = 'refund_processed_by';

    IF v_exists = 0 THEN

        ALTER TABLE orders
        ADD COLUMN refund_processed_by
        BIGINT UNSIGNED NULL
        AFTER refund_requested_at;

    END IF;


    /* ---------------------------------------------------------
       WHEN REFUND WAS PROCESSED
    --------------------------------------------------------- */

    SELECT COUNT(*)
    INTO v_exists
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'orders'
      AND COLUMN_NAME = 'refund_processed_at';

    IF v_exists = 0 THEN

        ALTER TABLE orders
        ADD COLUMN refund_processed_at
        DATETIME NULL
        AFTER refund_processed_by;

    END IF;


    /* ---------------------------------------------------------
       PI A2U REFUND PAYMENT ID
    --------------------------------------------------------- */

    SELECT COUNT(*)
    INTO v_exists
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'orders'
      AND COLUMN_NAME = 'refund_payment_id';

    IF v_exists = 0 THEN

        ALTER TABLE orders
        ADD COLUMN refund_payment_id
        VARCHAR(255) NULL
        AFTER refund_processed_at;

    END IF;


    /* ---------------------------------------------------------
       PI BLOCKCHAIN TRANSACTION ID FOR REFUND
    --------------------------------------------------------- */

    SELECT COUNT(*)
    INTO v_exists
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'orders'
      AND COLUMN_NAME = 'refund_txid';

    IF v_exists = 0 THEN

        ALTER TABLE orders
        ADD COLUMN refund_txid
        VARCHAR(255) NULL
        AFTER refund_payment_id;

    END IF;


    /* ---------------------------------------------------------
       REFUND FAILURE MESSAGE
    --------------------------------------------------------- */

    SELECT COUNT(*)
    INTO v_exists
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'orders'
      AND COLUMN_NAME = 'refund_error';

    IF v_exists = 0 THEN

        ALTER TABLE orders
        ADD COLUMN refund_error
        TEXT NULL
        AFTER refund_txid;

    END IF;


    /* ---------------------------------------------------------
       CANCELLATION INITIATED BY
    --------------------------------------------------------- */

    SELECT COUNT(*)
    INTO v_exists
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'orders'
      AND COLUMN_NAME = 'cancelled_by';

    IF v_exists = 0 THEN

        ALTER TABLE orders
        ADD COLUMN cancelled_by
        ENUM(
            'buyer',
            'vendor',
            'admin',
            'system'
        )
        NULL
        AFTER cancellation_reason;

    END IF;


    /* ---------------------------------------------------------
       CANCELLATION REVIEW TIME
    --------------------------------------------------------- */

    SELECT COUNT(*)
    INTO v_exists
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'orders'
      AND COLUMN_NAME = 'cancellation_requested_at';

    IF v_exists = 0 THEN

        ALTER TABLE orders
        ADD COLUMN cancellation_requested_at
        DATETIME NULL
        AFTER cancelled_by;

    END IF;


    /* =========================================================
       2. INDEXES FOR REFUND MANAGEMENT
    ========================================================= */


    /* ---------------------------------------------------------
       REFUND STATUS INDEX
    --------------------------------------------------------- */

    SELECT COUNT(*)
    INTO v_exists
    FROM INFORMATION_SCHEMA.STATISTICS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'orders'
      AND INDEX_NAME = 'idx_orders_refund_status';

    IF v_exists = 0 THEN

        ALTER TABLE orders
        ADD INDEX idx_orders_refund_status
        (refund_status);

    END IF;


    /* ---------------------------------------------------------
       REFUND PAYMENT INDEX
    --------------------------------------------------------- */

    SELECT COUNT(*)
    INTO v_exists
    FROM INFORMATION_SCHEMA.STATISTICS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'orders'
      AND INDEX_NAME = 'idx_orders_refund_payment';

    IF v_exists = 0 THEN

        ALTER TABLE orders
        ADD INDEX idx_orders_refund_payment
        (refund_payment_id);

    END IF;


    /* ---------------------------------------------------------
       REFUND REQUESTED BY INDEX
    --------------------------------------------------------- */

    SELECT COUNT(*)
    INTO v_exists
    FROM INFORMATION_SCHEMA.STATISTICS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'orders'
      AND INDEX_NAME = 'idx_orders_refund_requested_by';

    IF v_exists = 0 THEN

        ALTER TABLE orders
        ADD INDEX idx_orders_refund_requested_by
        (refund_requested_by);

    END IF;


    /* ---------------------------------------------------------
       REFUND PROCESSED BY INDEX
    --------------------------------------------------------- */

    SELECT COUNT(*)
    INTO v_exists
    FROM INFORMATION_SCHEMA.STATISTICS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'orders'
      AND INDEX_NAME = 'idx_orders_refund_processed_by';

    IF v_exists = 0 THEN

        ALTER TABLE orders
        ADD INDEX idx_orders_refund_processed_by
        (refund_processed_by);

    END IF;


    /* =========================================================
       3. REFUND FOREIGN KEYS
    ========================================================= */


    /* ---------------------------------------------------------
       REFUND REQUESTED BY
    --------------------------------------------------------- */

    SELECT COUNT(*)
    INTO v_exists
    FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
    WHERE CONSTRAINT_SCHEMA = DATABASE()
      AND TABLE_NAME = 'orders'
      AND CONSTRAINT_NAME = 'fk_orders_refund_requested_by'
      AND CONSTRAINT_TYPE = 'FOREIGN KEY';

    IF v_exists = 0 THEN

        ALTER TABLE orders

        ADD CONSTRAINT fk_orders_refund_requested_by

        FOREIGN KEY (refund_requested_by)

        REFERENCES users(id)

        ON DELETE SET NULL

        ON UPDATE CASCADE;

    END IF;


    /* ---------------------------------------------------------
       REFUND PROCESSED BY
    --------------------------------------------------------- */

    SELECT COUNT(*)
    INTO v_exists
    FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
    WHERE CONSTRAINT_SCHEMA = DATABASE()
      AND TABLE_NAME = 'orders'
      AND CONSTRAINT_NAME = 'fk_orders_refund_processed_by'
      AND CONSTRAINT_TYPE = 'FOREIGN KEY';

    IF v_exists = 0 THEN

        ALTER TABLE orders

        ADD CONSTRAINT fk_orders_refund_processed_by

        FOREIGN KEY (refund_processed_by)

        REFERENCES users(id)

        ON DELETE SET NULL

        ON UPDATE CASCADE;

    END IF;

END$$

DELIMITER ;

CALL azma_refund_order_columns();

DROP PROCEDURE IF EXISTS azma_refund_order_columns;


/* =========================================================
   4. SUPPORT CONVERSATIONS
========================================================= */

CREATE TABLE IF NOT EXISTS support_conversations (

    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,


    /* =====================================================
       PRIMARY PARTICIPANT
    ===================================================== */

    user_id BIGINT UNSIGNED NOT NULL,


    /* =====================================================
       OPTIONAL ORDER
    ===================================================== */

    order_id BIGINT UNSIGNED NULL,


    /* =====================================================
       USER TYPE
    ===================================================== */

    user_type ENUM(
        'buyer',
        'vendor'
    ) NOT NULL,


    /* =====================================================
       SUBJECT
    ===================================================== */

    subject VARCHAR(255) NOT NULL,


    /* =====================================================
       CONVERSATION STATUS
    ===================================================== */

    status ENUM(
        'open',
        'pending',
        'resolved',
        'closed'
    ) NOT NULL DEFAULT 'open',


    /* =====================================================
       PRIORITY
    ===================================================== */

    priority ENUM(
        'low',
        'normal',
        'high',
        'urgent'
    ) NOT NULL DEFAULT 'normal',


    /* =====================================================
       LAST MESSAGE INFORMATION
    ===================================================== */

    last_message_at DATETIME NULL,

    last_message_by BIGINT UNSIGNED NULL,


    /* =====================================================
       ADMIN ASSIGNMENT
    ===================================================== */

    assigned_admin_id BIGINT UNSIGNED NULL,


    /* =====================================================
       TIMESTAMPS
    ===================================================== */

    created_at TIMESTAMP NOT NULL
        DEFAULT CURRENT_TIMESTAMP,

    updated_at TIMESTAMP NOT NULL
        DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,


    PRIMARY KEY (id),


    /* =====================================================
       INDEXES
    ===================================================== */

    INDEX idx_support_conversations_user
    (user_id),

    INDEX idx_support_conversations_order
    (order_id),

    INDEX idx_support_conversations_status
    (status),

    INDEX idx_support_conversations_priority
    (priority),

    INDEX idx_support_conversations_last_message
    (last_message_at),

    INDEX idx_support_conversations_admin
    (assigned_admin_id),


    /* =====================================================
       USER
    ===================================================== */

    CONSTRAINT fk_support_conversations_user

    FOREIGN KEY (user_id)

    REFERENCES users(id)

    ON DELETE CASCADE

    ON UPDATE CASCADE,


    /* =====================================================
       ORDER
    ===================================================== */

    CONSTRAINT fk_support_conversations_order

    FOREIGN KEY (order_id)

    REFERENCES orders(id)

    ON DELETE SET NULL

    ON UPDATE CASCADE,


    /* =====================================================
       LAST MESSAGE USER
    ===================================================== */

    CONSTRAINT fk_support_conversations_last_message

    FOREIGN KEY (last_message_by)

    REFERENCES users(id)

    ON DELETE SET NULL

    ON UPDATE CASCADE,


    /* =====================================================
       ASSIGNED ADMIN
    ===================================================== */

    CONSTRAINT fk_support_conversations_admin

    FOREIGN KEY (assigned_admin_id)

    REFERENCES users(id)

    ON DELETE SET NULL

    ON UPDATE CASCADE

) ENGINE=InnoDB

DEFAULT CHARSET=utf8mb4

COLLATE=utf8mb4_unicode_ci;


/* =========================================================
   5. SUPPORT MESSAGES
========================================================= */

CREATE TABLE IF NOT EXISTS support_messages (

    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,


    /* =====================================================
       CONVERSATION
    ===================================================== */

    conversation_id BIGINT UNSIGNED NOT NULL,


    /* =====================================================
       SENDER
    ===================================================== */

    sender_id BIGINT UNSIGNED NOT NULL,


    /* =====================================================
       SENDER TYPE
    ===================================================== */

    sender_type ENUM(
        'buyer',
        'vendor',
        'admin'
    ) NOT NULL,


    /* =====================================================
       MESSAGE
    ===================================================== */

    message TEXT NOT NULL,


    /* =====================================================
       OPTIONAL ATTACHMENT
    ===================================================== */

    attachment_url VARCHAR(1000) NULL,


    /* =====================================================
       READ STATUS
    ===================================================== */

    is_read BOOLEAN NOT NULL DEFAULT FALSE,


    /* =====================================================
       READ TIME
    ===================================================== */

    read_at DATETIME NULL,


    /* =====================================================
       TIMESTAMP
    ===================================================== */

    created_at TIMESTAMP NOT NULL
        DEFAULT CURRENT_TIMESTAMP,


    PRIMARY KEY (id),


    /* =====================================================
       INDEXES
    ===================================================== */

    INDEX idx_support_messages_conversation
    (conversation_id),

    INDEX idx_support_messages_sender
    (sender_id),

    INDEX idx_support_messages_created
    (created_at),

    INDEX idx_support_messages_read
    (is_read),


    /* =====================================================
       CONVERSATION
    ===================================================== */

    CONSTRAINT fk_support_messages_conversation

    FOREIGN KEY (conversation_id)

    REFERENCES support_conversations(id)

    ON DELETE CASCADE

    ON UPDATE CASCADE,


    /* =====================================================
       SENDER
    ===================================================== */

    CONSTRAINT fk_support_messages_sender

    FOREIGN KEY (sender_id)

    REFERENCES users(id)

    ON DELETE CASCADE

    ON UPDATE CASCADE

) ENGINE=InnoDB

DEFAULT CHARSET=utf8mb4

COLLATE=utf8mb4_unicode_ci;


/* =========================================================
   6. OPTIONAL: REFUND AUDIT LOG
========================================================= */

CREATE TABLE IF NOT EXISTS refund_logs (

    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,


    /* =====================================================
       ORDER
    ===================================================== */

    order_id BIGINT UNSIGNED NOT NULL,


    /* =====================================================
       ACTOR
    ===================================================== */

    user_id BIGINT UNSIGNED NULL,


    /* =====================================================
       EVENT
    ===================================================== */

    event_type ENUM(
        'refund_requested',
        'vendor_cancelled',
        'refund_processing',
        'refund_completed',
        'refund_failed',
        'refund_cancelled'
    ) NOT NULL,


    /* =====================================================
       AMOUNT
    ===================================================== */

    amount_pi DECIMAL(20,8) NULL,


    /* =====================================================
       PI PAYMENT INFORMATION
    ===================================================== */

    pi_payment_id VARCHAR(255) NULL,

    txid VARCHAR(255) NULL,


    /* =====================================================
       DETAILS
    ===================================================== */

    reason VARCHAR(500) NULL,

    error_message TEXT NULL,


    /* =====================================================
       EXTRA DATA
    ===================================================== */

    metadata JSON NULL,


    /* =====================================================
       TIMESTAMP
    ===================================================== */

    created_at TIMESTAMP NOT NULL
        DEFAULT CURRENT_TIMESTAMP,


    PRIMARY KEY (id),


    /* =====================================================
       INDEXES
    ===================================================== */

    INDEX idx_refund_logs_order
    (order_id),

    INDEX idx_refund_logs_user
    (user_id),

    INDEX idx_refund_logs_event
    (event_type),

    INDEX idx_refund_logs_created
    (created_at),


    /* =====================================================
       ORDER
    ===================================================== */

    CONSTRAINT fk_refund_logs_order

    FOREIGN KEY (order_id)

    REFERENCES orders(id)

    ON DELETE CASCADE

    ON UPDATE CASCADE,


    /* =====================================================
       USER
    ===================================================== */

    CONSTRAINT fk_refund_logs_user

    FOREIGN KEY (user_id)

    REFERENCES users(id)

    ON DELETE SET NULL

    ON UPDATE CASCADE

) ENGINE=InnoDB

DEFAULT CHARSET=utf8mb4

COLLATE=utf8mb4_unicode_ci;


/* =========================================================
   7. COMPLETION MESSAGE
========================================================= */

SELECT
    'Refund + Chat database migration completed successfully'
    AS migration_status;


/* =========================================================
   AZMA MARKETPLACE
   REFUND + SUPPORT CHAT UPDATE 002
========================================================= */

USE railway;


/* =========================================================
   UPDATE 002 INDEXES
========================================================= */

DROP PROCEDURE IF EXISTS azma_refund_chat_update_002;

DELIMITER $$

CREATE PROCEDURE azma_refund_chat_update_002()
BEGIN

    DECLARE v_exists INT DEFAULT 0;


    /* ---------------------------------------------------------
       ORDERS REFUND CASE INDEX
    --------------------------------------------------------- */

    SELECT COUNT(*)
    INTO v_exists
    FROM INFORMATION_SCHEMA.STATISTICS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'orders'
      AND INDEX_NAME = 'idx_orders_refund_case';

    IF v_exists = 0 THEN

        ALTER TABLE orders

        ADD INDEX idx_orders_refund_case

        (refund_status, cancelled_at, refund_requested_at);

    END IF;


    /* ---------------------------------------------------------
       SUPPORT CONVERSATIONS STATUS/LAST MESSAGE INDEX
    --------------------------------------------------------- */

    SELECT COUNT(*)
    INTO v_exists
    FROM INFORMATION_SCHEMA.STATISTICS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'support_conversations'
      AND INDEX_NAME = 'idx_support_conversations_status_last';

    IF v_exists = 0 THEN

        ALTER TABLE support_conversations

        ADD INDEX idx_support_conversations_status_last

        (status, last_message_at);

    END IF;


    /* ---------------------------------------------------------
       SUPPORT MESSAGES CONVERSATION/CREATED INDEX
    --------------------------------------------------------- */

    SELECT COUNT(*)
    INTO v_exists
    FROM INFORMATION_SCHEMA.STATISTICS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'support_messages'
      AND INDEX_NAME = 'idx_support_messages_conversation_created';

    IF v_exists = 0 THEN

        ALTER TABLE support_messages

        ADD INDEX idx_support_messages_conversation_created

        (conversation_id, created_at);

    END IF;

END$$

DELIMITER ;

CALL azma_refund_chat_update_002();

DROP PROCEDURE IF EXISTS azma_refund_chat_update_002;


/* =========================================================
   FINAL COMPLETION MESSAGE
========================================================= */

SELECT
    'Refund + Support Chat update 002 completed successfully'
    AS migration_status;