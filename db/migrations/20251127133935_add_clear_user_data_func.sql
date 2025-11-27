-- vim: set ft=pgsql :

-- migrate:up
CREATE OR REPLACE FUNCTION public.clear_user_data()
RETURNS json AS $$
DECLARE
    v_user_id TEXT := current_setting('request.jwt.claims', true)::json->>'sub';
    v_folders_count INT;
    v_sets_count INT;
BEGIN
    DELETE FROM public.Folders 
    WHERE user_id = v_user_id;

    GET DIAGNOSTICS v_folders_count = ROW_COUNT;

    DELETE FROM public.Sets
    WHERE user_id = v_user_id;

    GET DIAGNOSTICS v_sets_count = ROW_COUNT;

    DELETE FROM public.Progress 
    WHERE user_id = v_user_id;

    RETURN json_build_object(
        'status', 'success',
        'stats', json_build_object(
            'deleted_folders', v_folders_count,
            'deleted_sets', v_sets_count
        )
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, pg_temp;

COMMENT ON FUNCTION public.clear_user_data IS 'Deletes all Folders, Sets, Cards, and Progress for the current user (Account Reset).';

GRANT EXECUTE ON FUNCTION public.clear_user_data() TO api_user;


-- migrate:down
DROP FUNCTION IF EXISTS public.clear_user_data();
