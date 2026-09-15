/* =========================================================
   CHARCOAL MARKETPLACE
   REFUND + SUPPORT CHAT UPDATE 002
   =========================================================

   Run this AFTER:
     migrations/001_refund_and_chat.sql

   This migration only adds the small indexes needed by the
   new refund/support APIs and does not drop marketplace data.
========================================================= */

USE railway;

ALTER TABLE orders
  ADD INDEX idx_orders_refund_case
  (refund_status, cancelled_at, refund_requested_at);

ALTER TABLE support_conversations
  ADD INDEX idx_support_conversations_status_last
  (status, last_message_at);

ALTER TABLE support_messages
  ADD INDEX idx_support_messages_conversation_created
  (conversation_id, created_at);

SELECT
  'Refund + Support Chat update 002 completed successfully'
  AS migration_status;
