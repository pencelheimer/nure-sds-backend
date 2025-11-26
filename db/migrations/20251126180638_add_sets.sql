-- migrate:up
DROP TABLE IF EXISTS public.Sets CASCADE;

CREATE TABLE public.Sets (
    set_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id TEXT NOT NULL,
    folder_id INT NULL,
    set_name VARCHAR(100) NOT NULL,
    is_public BOOLEAN DEFAULT FALSE,
    creation_date TIMESTAMPTZ DEFAULT NOW(),

    CONSTRAINT fk_set_user FOREIGN KEY (user_id) REFERENCES public.Users (id) ON DELETE CASCADE,
    CONSTRAINT fk_set_folder FOREIGN KEY (folder_id) REFERENCES public.Folders (folder_id) ON DELETE SET NULL,
    CONSTRAINT uq_set_name_user UNIQUE (user_id, set_name),

    CONSTRAINT chk_set_name_not_empty CHECK (length(trim(set_name)) > 0)
);

COMMENT ON TABLE public.Sets IS $$Flashcard Sets

A collection of flashcards created by a user.
Sets can be marked as **public**, making them readable by all users (including anonymous ones).
$$;
COMMENT ON COLUMN public.Sets.folder_id IS 'The folder containing this set. Can be NULL if the set is at the root level.';
COMMENT ON COLUMN public.Sets.is_public IS 'Visibility flag. If true, the set is readable by all anonymous and authenticated users.';
COMMENT ON CONSTRAINT uq_set_name_user ON public.Sets IS 'Ensures that a user cannot have two sets with the exact same name.';

ALTER TABLE public.Sets ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Sets viewable by owner or public" ON public.Sets
    FOR SELECT USING (
        user_id = current_setting('request.jwt.claims', true)::json->>'sub' OR is_public = true
    );

CREATE POLICY "Sets modifiable by owner" ON public.Sets
    FOR ALL USING (user_id = current_setting('request.jwt.claims', false)::json->>'sub');

GRANT SELECT, INSERT, UPDATE, DELETE ON public.Sets TO api_user;
GRANT SELECT ON public.Sets TO anon;


-- migrate:down
DROP POLICY IF EXISTS "Sets modifiable by owner" ON public.Sets;
DROP POLICY IF EXISTS "Sets viewable by owner or public" ON public.Sets;

REVOKE ALL ON public.Sets FROM api_user;
REVOKE ALL ON public.Sets FROM anon;

DROP TABLE IF EXISTS public.Sets CASCADE;
