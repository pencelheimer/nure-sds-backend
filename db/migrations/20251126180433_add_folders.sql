-- migrate:up
DROP TABLE IF EXISTS public.Folders CASCADE;

CREATE TABLE public.Folders (
    folder_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id TEXT NOT NULL, 
    parent_folder_id INT NULL,
    folder_name VARCHAR(100) NOT NULL,

    CONSTRAINT fk_folder_user FOREIGN KEY (user_id) REFERENCES public.Users (id) ON DELETE CASCADE,
    CONSTRAINT fk_folder_parent FOREIGN KEY (parent_folder_id) REFERENCES public.Folders (folder_id) ON DELETE CASCADE,

    CONSTRAINT chk_folder_name_not_empty CHECK (length(trim(folder_name)) > 0)
);

COMMENT ON TABLE public.Folders IS $$Study Folders

Hierarchical structure for organizing study sets.
Supports **infinite nesting** via the `parent_folder_id` self-reference.
Roots folders have `parent_folder_id` set to `NULL`.
$$;
COMMENT ON COLUMN public.Folders.user_id IS 'The owner of the folder.';
COMMENT ON COLUMN public.Folders.parent_folder_id IS 'ID of the parent folder. If NULL, this is a root-level folder.';
COMMENT ON COLUMN public.Folders.folder_name IS 'Display name of the folder.';

ALTER TABLE public.Folders ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Folders are private" ON public.Folders
    FOR ALL USING (user_id = current_setting('request.jwt.claims', false)::json->>'sub');

GRANT SELECT, INSERT, UPDATE, DELETE ON public.Folders TO api_user;


-- migrate:down
DROP POLICY IF EXISTS "Folders are private" ON public.Folders;

REVOKE ALL ON public.Folders FROM api_user;

DROP TABLE IF EXISTS public.Folders CASCADE;
