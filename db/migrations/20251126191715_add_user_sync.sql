-- vim: set ft=pgsql :

-- migrate:up
CREATE OR REPLACE FUNCTION public.sync_user(
    p_username text,
    p_avatar_url text DEFAULT NULL
)
RETURNS json AS $$
DECLARE
  jwt_sub text := current_setting('request.jwt.claims', false)::json->>'sub'; 
BEGIN
  INSERT INTO public.Users (id, username, avatar_url, last_login)
  VALUES (jwt_sub, p_username, p_avatar_url, now())
  ON CONFLICT (id) DO UPDATE
  SET
    username = EXCLUDED.username,
    avatar_url = COALESCE(EXCLUDED.avatar_url, public.Users.avatar_url),
    last_login = now();

  RETURN json_build_object(
    'status', 'synced',
    'id', jwt_sub,
    'username', p_username
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, pg_temp;

COMMENT ON FUNCTION public.sync_user IS $$Sync Auth0 User

Upserts the authenticated user into the database using the JWT `sub` claim as the ID.
Call this endpoint immediately after login on the frontend to ensure the user exists in the local DB.
$$;

GRANT EXECUTE ON FUNCTION public.sync_user(text, text) TO api_user;


-- migrate:down
REVOKE EXECUTE ON FUNCTION public.sync_user(text, text) FROM api_user;

DROP FUNCTION IF EXISTS public.sync_user(text, text);
