-- vim: set ft=pgsql :

-- migrate:up
DROP TABLE IF EXISTS public.Progress CASCADE;

CREATE TABLE public.Progress (
    user_id TEXT NOT NULL,
    card_id INT NOT NULL,
    last_correct BOOLEAN DEFAULT NULL,
    total_count INT DEFAULT 0,
    correct_count INT DEFAULT 0,

    CONSTRAINT pk_progress PRIMARY KEY (user_id, card_id),
    CONSTRAINT fk_progress_user FOREIGN KEY (user_id) REFERENCES public.Users (id) ON DELETE CASCADE,
    CONSTRAINT fk_progress_card FOREIGN KEY (card_id) REFERENCES public.Cards (card_id) ON DELETE CASCADE,

    CONSTRAINT chk_progress_total_non_negative CHECK (total_count >= 0),
    CONSTRAINT chk_progress_correct_non_negative CHECK (correct_count >= 0),

    CONSTRAINT chk_progress_correct_le_total CHECK (correct_count <= total_count)
);

COMMENT ON TABLE public.Progress IS $$Learning Statistics

Tracks the user''s performance on specific cards.
$$;
COMMENT ON COLUMN public.Progress.last_correct IS 'Result of the most recent review attempt. NULL indicates not yet reviewed.';
COMMENT ON COLUMN public.Progress.total_count IS 'Total number of times this card has been reviewed.';
COMMENT ON COLUMN public.Progress.correct_count IS 'Number of times the user answered correctly.';

ALTER TABLE public.Progress ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Progress is private" ON public.Progress
    FOR ALL USING (user_id = current_setting('request.jwt.claims', false)::json->>'sub');

GRANT SELECT, INSERT, UPDATE, DELETE ON public.Progress TO api_user;


-- migrate:down
DROP POLICY IF EXISTS "Progress is private" ON public.Progress;

REVOKE ALL ON public.Progress FROM api_user;

DROP TABLE IF EXISTS public.Progress CASCADE;
