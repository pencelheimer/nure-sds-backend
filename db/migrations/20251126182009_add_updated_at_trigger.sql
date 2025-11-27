-- vim: set ft=pgsql :

-- migrate:up
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_set_timestamp_users
    BEFORE UPDATE ON public.Users
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER trg_set_timestamp_folders
    BEFORE UPDATE ON public.Folders
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER trg_set_timestamp_sets
    BEFORE UPDATE ON public.Sets
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER trg_set_timestamp_cards
    BEFORE UPDATE ON public.Cards
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER trg_set_timestamp_progress
    BEFORE UPDATE ON public.Progress
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();


-- migrate:down
DROP TRIGGER IF EXISTS trg_set_timestamp_progress ON public.Progress;
DROP TRIGGER IF EXISTS trg_set_timestamp_cards ON public.Cards;
DROP TRIGGER IF EXISTS trg_set_timestamp_sets ON public.Sets;
DROP TRIGGER IF EXISTS trg_set_timestamp_folders ON public.Folders;
DROP TRIGGER IF EXISTS trg_set_timestamp_users ON public.Users;
DROP FUNCTION IF EXISTS public.handle_updated_at();
