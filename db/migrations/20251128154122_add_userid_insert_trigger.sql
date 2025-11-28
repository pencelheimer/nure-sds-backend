-- vim: set ft=pgsql :

-- migrate:up
CREATE OR REPLACE FUNCTION public.set_user_id_from_jwt()
RETURNS TRIGGER AS $$
DECLARE
  jwt_sub TEXT := current_setting('request.jwt.claims', true)::json->>'sub';
BEGIN
  IF jwt_sub IS NULL OR length(trim(jwt_sub)) = 0 THEN
      RAISE EXCEPTION 'JWT sub not found in session context.';
  END IF;

  NEW.user_id = jwt_sub;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql
SECURITY DEFINER;

COMMENT ON FUNCTION public.set_user_id_from_jwt() IS 'Automatically sets the user_id column from the JWT subject ID in the session context before INSERT/UPDATE.';


CREATE TRIGGER tr_set_user_id_folder
BEFORE INSERT ON public.Folders
FOR EACH ROW
EXECUTE FUNCTION public.set_user_id_from_jwt();

CREATE TRIGGER tr_set_user_id_set
BEFORE INSERT ON public.Sets
FOR EACH ROW
EXECUTE FUNCTION public.set_user_id_from_jwt();

CREATE TRIGGER tr_set_user_id_progress
BEFORE INSERT ON public.Progress
FOR EACH ROW
EXECUTE FUNCTION public.set_user_id_from_jwt();


-- migrate:down
DROP TRIGGER IF EXISTS tr_set_user_id_folder ON public.Folders;
DROP TRIGGER IF EXISTS tr_set_user_id_set ON public.Sets;
DROP TRIGGER IF EXISTS tr_set_user_id_progress ON public.Progress;

DROP FUNCTION IF EXISTS public.set_user_id_from_jwt();
