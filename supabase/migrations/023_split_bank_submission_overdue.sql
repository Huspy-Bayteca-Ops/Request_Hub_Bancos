-- ============================================================
-- Migration 023: Split "Bank Submission Overdue" in two
--
-- The cron now checks the general deal (pipeline 6) linked via the
-- Opportunity ID field of the bank deal:
--   • general deal at "Bank offers received" (stage 65) or later
--       → 'Bank Submission Overdue - Con otras Ofertas'
--   • otherwise
--       → 'Bank Submission Overdue - Sin Otras Ofertas'
--
-- 1. Renames the existing category to "- Sin Otras Ofertas"
--    (existing tickets keep their category).
-- 2. Creates "- Con otras Ofertas" with a copy of the same routing rule.
-- ============================================================

UPDATE categories
SET name        = 'Bank Submission Overdue - Sin Otras Ofertas',
    description = 'Auto: deal bancario en stage Bank Submission (70) con más de 48h; el deal general (pipeline 6) aún no tiene ofertas'
WHERE name = 'Bank Submission Overdue';

INSERT INTO categories (name, description, is_system, is_active) VALUES (
  'Bank Submission Overdue - Con otras Ofertas',
  'Auto: deal bancario en stage Bank Submission (70) con más de 48h; el deal general (pipeline 6) ya está en Bank offers received (65) o más adelante',
  TRUE, TRUE
)
ON CONFLICT (name) DO NOTHING;

INSERT INTO routing_rules (
  category_id, owner_email, backup_owner_email, default_priority, sla_hours,
  assignee_emails, bank_overrides
)
SELECT
  con.id, r.owner_email, r.backup_owner_email, r.default_priority, r.sla_hours,
  r.assignee_emails, r.bank_overrides
FROM routing_rules r
JOIN categories sin ON sin.id = r.category_id
                   AND sin.name = 'Bank Submission Overdue - Sin Otras Ofertas'
CROSS JOIN categories con
WHERE con.name = 'Bank Submission Overdue - Con otras Ofertas'
ON CONFLICT (category_id) DO NOTHING;
