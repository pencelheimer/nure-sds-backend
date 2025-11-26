-- migrate:up
DROP TABLE IF EXISTS public.Users CASCADE;

CREATE TABLE public.Users (
    id TEXT PRIMARY KEY,
    username TEXT NOT NULL,
    avatar_url TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    last_login TIMESTAMPTZ DEFAULT NOW(),
 
    CONSTRAINT chk_users_id_not_empty CHECK (length(trim(id)) > 0),
    CONSTRAINT chk_users_username_length CHECK (length(trim(username)) >= 2)
);

COMMENT ON TABLE public.Users IS $$User Profiles

Stores user identity data synchronized from Auth0.
This table serves as the root entity for all user-owned data (folders, sets, progress).
$$;
COMMENT ON COLUMN public.Users.id IS 'Unique identifier from Auth0 (Subject ID). Used as the primary key.';
COMMENT ON COLUMN public.Users.username IS 'User display name.';
COMMENT ON COLUMN public.Users.avatar_url IS 'URL to the user avatar image.';
COMMENT ON COLUMN public.Users.last_login IS 'Timestamp of the last successful synchronization/login.';

ALTER TABLE public.Users ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users are viewable by everyone" ON public.Users
    FOR SELECT USING (true);

CREATE POLICY "Users can update own profile" ON public.Users
    FOR UPDATE USING (id = current_setting('request.jwt.claims', false)::json->>'sub');

CREATE POLICY "Users can insert own profile" ON public.Users
    FOR INSERT WITH CHECK (id = current_setting('request.jwt.claims', false)::json->>'sub');

GRANT SELECT, INSERT, UPDATE ON public.Users TO api_user;
GRANT SELECT ON public.Users TO anon;


-- migrate:down
DROP POLICY IF EXISTS "Users can insert own profile" ON public.Users;
DROP POLICY IF EXISTS "Users can update own profile" ON public.Users;
DROP POLICY IF EXISTS "Users are viewable by everyone" ON public.Users;

REVOKE SELECT, INSERT, UPDATE ON public.Users FROM api_user;
REVOKE SELECT ON public.Users FROM anon;

DROP TABLE IF EXISTS public.Users CASCADE;
