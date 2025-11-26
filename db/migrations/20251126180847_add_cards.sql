-- migrate:up
DROP TABLE IF EXISTS public.Cards CASCADE;

CREATE TABLE public.Cards (
    card_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    set_id INT NOT NULL,
    front_text TEXT NOT NULL,
    back_text TEXT NOT NULL,

    CONSTRAINT fk_card_set FOREIGN KEY (set_id) REFERENCES public.Sets (set_id) ON DELETE CASCADE,

    CONSTRAINT chk_card_front_not_empty CHECK (length(trim(front_text)) > 0),
    CONSTRAINT chk_card_back_not_empty CHECK (length(trim(back_text)) > 0)
);

COMMENT ON TABLE public.Cards IS $$Flashcards

Individual study items containing a front (question) and back (answer) side.
Cards strictly belong to a Set and inherit access permissions from it.
$$;
COMMENT ON COLUMN public.Cards.front_text IS 'The question or main content shown on the front of the card.';
COMMENT ON COLUMN public.Cards.back_text IS 'The answer or content shown on the back of the card.';

ALTER TABLE public.Cards ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Cards viewable via parent Set" ON public.Cards
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.Sets s
            WHERE s.set_id = public.Cards.set_id
            AND (s.user_id = current_setting('request.jwt.claims', true)::json->>'sub' OR s.is_public = true)
        )
    );

CREATE POLICY "Cards modifiable by Set owner" ON public.Cards
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM public.Sets s
            WHERE s.set_id = public.Cards.set_id
            AND s.user_id = current_setting('request.jwt.claims', false)::json->>'sub'
        )
    );

GRANT SELECT, INSERT, UPDATE, DELETE ON public.Cards TO api_user;
GRANT SELECT ON public.Cards TO anon;

-- migrate:down
DROP POLICY IF EXISTS "Cards modifiable by Set owner" ON public.Cards;
DROP POLICY IF EXISTS "Cards viewable via parent Set" ON public.Cards;

REVOKE ALL ON public.Cards FROM api_user;
REVOKE ALL ON public.Cards FROM anon;

DROP TABLE IF EXISTS public.Cards CASCADE;
