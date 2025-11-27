-- vim: set ft=pgsql :

-- migrate:up
CREATE OR REPLACE FUNCTION public.card_status(p_card public.Cards)
RETURNS TEXT AS $$
DECLARE
    v_user_id TEXT := current_setting('request.jwt.claims', true)::json->>'sub';
    v_total INT;
    v_correct INT;
BEGIN
    SELECT total_count, correct_count
    INTO v_total, v_correct
    FROM public.Progress
    WHERE card_id = p_card.card_id AND user_id = v_user_id;

    IF v_total IS NULL OR v_total = 0 THEN
        RETURN 'New';
    ELSIF v_correct >= 5 AND (v_correct::numeric / v_total) > 0.8 THEN
        RETURN 'Mastered';
    ELSE
        RETURN 'Learning';
    END IF;
END;
$$ LANGUAGE plpgsql STABLE;

COMMENT ON FUNCTION public.card_status IS 'Computed Field: Returns "New", "Learning", or "Mastered".';

GRANT EXECUTE ON FUNCTION public.card_status(public.Cards) TO anon, api_user;


-- migrate:down
DROP FUNCTION IF EXISTS public.card_status(public.Cards);
