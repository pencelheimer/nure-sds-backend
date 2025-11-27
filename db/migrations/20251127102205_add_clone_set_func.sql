-- vim: set ft=pgsql :

-- migrate:up
CREATE OR REPLACE FUNCTION public.clone_public_set(
    p_source_set_id INT
)
RETURNS json AS $$
DECLARE
    v_new_set_id INT;
    v_user_id TEXT := current_setting('request.jwt.claims', true)::json->>'sub';
    v_source_set RECORD;
BEGIN
    v_source_set := (SELECT * FROM public.Sets
        WHERE set_id = p_source_set_id AND is_public = true);

    IF v_source_set IS NULL THEN
        RAISE EXCEPTION 'Set not found or not public';
    END IF;

    INSERT INTO public.Sets (user_id, folder_id, set_name, is_public)
    VALUES (v_user_id, NULL, v_source_set.set_name || ' (Copy)', false)
    RETURNING set_id INTO v_new_set_id;

    INSERT INTO public.Cards (set_id, front_text, back_text)
    SELECT v_new_set_id, front_text, back_text
    FROM public.Cards
    WHERE set_id = p_source_set_id;

    RETURN json_build_object('new_set_id', v_new_set_id, 'status', 'success');
END;
$$ LANGUAGE plpgsql SECURITY DEFINER; 

COMMENT ON FUNCTION public.clone_public_set IS 'Copies a public set and its cards to the current user''s library.';

GRANT EXECUTE ON FUNCTION public.clone_public_set(INT) TO api_user;


-- migrate:down
DROP FUNCTION IF EXISTS public.clone_public_set(INT);
