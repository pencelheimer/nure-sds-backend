-- vim: set ft=pgsql :

-- migrate:up
CREATE OR REPLACE FUNCTION public.set_mastery(p_set public.Sets)
RETURNS INT AS $$
DECLARE
    v_user_id TEXT := current_setting('request.jwt.claims', true)::json->>'sub';
BEGIN
    RETURN (
        SELECT COALESCE(
            AVG(
                CASE
                    WHEN pr.total_count = 0 THEN 0
                    ELSE (pr.correct_count::numeric / pr.total_count) * 100
                END
            ),
            0
        )::INT
        FROM public.Cards c
        LEFT JOIN public.Progress pr
            ON c.card_id = pr.card_id AND pr.user_id = v_user_id
        WHERE c.set_id = p_set.set_id
    );
END;
$$ LANGUAGE plpgsql STABLE;

COMMENT ON FUNCTION public.set_mastery IS 'Computed Field: Returns the average mastery percentage (0-100) for the set based on user progress.';

GRANT EXECUTE ON FUNCTION public.set_mastery(public.Sets) TO anon, api_user;


-- migrate:down
DROP FUNCTION IF EXISTS public.set_mastery(public.Sets);
