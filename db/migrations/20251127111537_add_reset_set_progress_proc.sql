-- vim: set ft=pgsql :

-- migrate:up
CREATE PROCEDURE public.reset_set_progress(
    p_set_id INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_user_id TEXT := current_setting('request.jwt.claims', true)::json->>'sub';
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM public.Sets
        WHERE set_id = p_set_id AND user_id = v_user_id
    ) THEN
        RAISE EXCEPTION 'Access denied: Set not found or not owned by user';
    END IF;

    UPDATE public.Progress p
    SET
        total_count = 0,
        correct_count = 0,
        last_correct = NULL
    FROM public.Cards c
    WHERE p.card_id = c.card_id
      AND c.set_id = p_set_id
      AND p.user_id = v_user_id;

    COMMIT;
END;
$$;

COMMENT ON PROCEDURE public.reset_set_progress IS 'Resets learning statistics for all cards in a specific set. Access denied if not owner.';

GRANT EXECUTE ON PROCEDURE public.reset_set_progress(INT) TO api_user;


-- migrate:down
DROP PROCEDURE IF EXISTS public.reset_set_progress(INT);
