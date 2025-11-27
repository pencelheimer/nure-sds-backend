-- vim: set ft=pgsql :

-- migrate:up
CREATE OR REPLACE FUNCTION public.get_study_queue(
    p_set_id INT,
    p_limit INT DEFAULT 10
)
RETURNS TABLE (
    card_id INT,
    front_text TEXT,
    back_text TEXT,
    correct_rate NUMERIC
) AS $$
DECLARE
    v_user_id TEXT := current_setting('request.jwt.claims', true)::json->>'sub';
BEGIN
    RETURN QUERY
    SELECT
        c.card_id,
        c.front_text,
        c.back_text,
        COALESCE(p.correct_count::numeric / NULLIF(p.total_count, 0), 0) as correct_rate
    FROM public.Cards c
    LEFT JOIN public.Progress p ON c.card_id = p.card_id AND p.user_id = v_user_id
    WHERE c.set_id = p_set_id
    ORDER BY
        p.total_count ASC NULLS FIRST,
        (p.correct_count::numeric / NULLIF(p.total_count, 0)) ASC
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql STABLE;

COMMENT ON FUNCTION public.get_study_queue IS 'Returns cards that need review based on user progress.';

GRANT EXECUTE ON FUNCTION public.get_study_queue(INT, INT) TO api_user;


-- migrate:down
DROP FUNCTION IF EXISTS public.get_study_queue(INT, INT);
