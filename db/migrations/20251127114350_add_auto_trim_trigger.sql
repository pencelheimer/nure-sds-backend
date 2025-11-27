-- vim: set ft=pgsql :

-- migrate:up
CREATE OR REPLACE FUNCTION public.auto_trim_strings()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_TABLE_NAME = 'folders' THEN
        NEW.folder_name := trim(regexp_replace(NEW.folder_name, '\s+', ' ', 'g'));
    END IF;

    IF TG_TABLE_NAME = 'sets' THEN
        NEW.set_name := trim(regexp_replace(NEW.set_name, '\s+', ' ', 'g'));
    END IF;

    IF TG_TABLE_NAME = 'cards' THEN
        NEW.front_text := trim(NEW.front_text);
        NEW.back_text := trim(NEW.back_text);
    END IF;

    IF TG_TABLE_NAME = 'users' THEN
        NEW.username := trim(regexp_replace(NEW.username, '\s+', ' ', 'g'));
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_trim_users
    BEFORE INSERT OR UPDATE OF username ON public.Users
    FOR EACH ROW EXECUTE FUNCTION public.auto_trim_strings();

CREATE TRIGGER trg_trim_folders
    BEFORE INSERT OR UPDATE OF folder_name ON public.Folders
    FOR EACH ROW EXECUTE FUNCTION public.auto_trim_strings();

CREATE TRIGGER trg_trim_sets
    BEFORE INSERT OR UPDATE OF set_name ON public.Sets
    FOR EACH ROW EXECUTE FUNCTION public.auto_trim_strings();

CREATE TRIGGER trg_trim_cards
    BEFORE INSERT OR UPDATE OF front_text, back_text ON public.Cards
    FOR EACH ROW EXECUTE FUNCTION public.auto_trim_strings();


-- migrate:down
DROP TRIGGER IF EXISTS trg_trim_cards ON public.Cards;
DROP TRIGGER IF EXISTS trg_trim_sets ON public.Sets;
DROP TRIGGER IF EXISTS trg_trim_folders ON public.Folders;
DROP TRIGGER IF EXISTS trg_trim_users ON public.Users;
DROP FUNCTION IF EXISTS public.auto_trim_strings();
