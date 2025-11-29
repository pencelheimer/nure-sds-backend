-- vim: set ft=pgsql :

-- migrate:up
CREATE OR REPLACE FUNCTION public.folder_stats(p_folder public.Folders)
RETURNS json AS $$
DECLARE
    v_stats json;
BEGIN
    WITH RECURSIVE folder_tree AS (
        SELECT folder_id
        FROM public.Folders
        WHERE folder_id = p_folder.folder_id

        UNION ALL

        SELECT f.folder_id 
        FROM public.Folders f
        JOIN folder_tree ft ON f.parent_folder_id = ft.folder_id
    )
    SELECT json_build_object(
        'total_subfolders', (COUNT(folder_id) - 1),

        'total_sets', (
            SELECT COUNT(*)
            FROM public.Sets s
            WHERE s.folder_id IN (SELECT folder_id FROM folder_tree)
        )
    ) INTO v_stats
    FROM folder_tree;

    RETURN v_stats;
END;
$$ LANGUAGE plpgsql STABLE;

COMMENT ON FUNCTION public.folder_stats IS 'Computed Field: Returns recursive count of all subfolders and sets contained within.';

GRANT EXECUTE ON FUNCTION public.folder_stats(public.Folders) TO api_user;


-- migrate:down
DROP FUNCTION IF EXISTS public.folder_stats(public.Folders);
