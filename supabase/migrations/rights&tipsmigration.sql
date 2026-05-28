ALTER TABLE public."rights&tips"
ADD COLUMN IF NOT EXISTS content_type text NOT NULL DEFAULT 'tip',
ADD COLUMN IF NOT EXISTS media_url text,
ADD COLUMN IF NOT EXISTS read_time_minutes integer,
ADD COLUMN IF NOT EXISTS is_daily_tip boolean NOT NULL DEFAULT false,
ADD COLUMN IF NOT EXISTS is_featured boolean NOT NULL DEFAULT false;

ALTER TABLE public."rights&tips"
DROP CONSTRAINT IF EXISTS rights_tips_content_type_check;

ALTER TABLE public."rights&tips"
ADD CONSTRAINT rights_tips_content_type_check
CHECK (content_type IN ('tip', 'right', 'article', 'video'));