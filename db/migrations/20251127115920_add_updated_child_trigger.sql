-- vim: set ft=pgsql :

-- migrate:up
CREATE OR REPLACE FUNCTION public.touch_parent_set()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'DELETE') THEN
        UPDATE public.Sets
        SET updated_at = NOW()
        WHERE set_id = OLD.set_id;
        RETURN OLD;
    ELSE
        UPDATE public.Sets
        SET updated_at = NOW()
        WHERE set_id = NEW.set_id;

        IF (TG_OP = 'UPDATE' AND OLD.set_id IS DISTINCT FROM NEW.set_id) THEN
             UPDATE public.Sets SET updated_at = NOW() WHERE set_id = OLD.set_id;
        END IF;

        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION public.touch_parent_folder()
RETURNS TRIGGER AS $$
DECLARE
    v_parent_id INT;
    v_old_parent_id INT;
BEGIN
    IF TG_TABLE_NAME = 'sets' THEN
        v_parent_id := CASE WHEN TG_OP = 'DELETE' THEN OLD.folder_id ELSE NEW.folder_id END;
        v_old_parent_id := CASE WHEN TG_OP = 'UPDATE' THEN OLD.folder_id ELSE NULL END;
    ELSIF TG_TABLE_NAME = 'folders' THEN
        v_parent_id := CASE WHEN TG_OP = 'DELETE' THEN OLD.parent_folder_id ELSE NEW.parent_folder_id END;
        v_old_parent_id := CASE WHEN TG_OP = 'UPDATE' THEN OLD.parent_folder_id ELSE NULL END;
    END IF;

    IF v_parent_id IS NOT NULL THEN
        UPDATE public.Folders SET updated_at = NOW() WHERE folder_id = v_parent_id;
    END IF;

    IF v_old_parent_id IS NOT NULL AND v_old_parent_id IS DISTINCT FROM v_parent_id THEN
        UPDATE public.Folders SET updated_at = NOW() WHERE folder_id = v_old_parent_id;
    END IF;

    IF TG_OP = 'DELETE' THEN RETURN OLD; ELSE RETURN NEW; END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


CREATE TRIGGER trg_touch_set_on_card
    AFTER INSERT OR UPDATE OR DELETE ON public.Cards
    FOR EACH ROW EXECUTE FUNCTION public.touch_parent_set();

CREATE TRIGGER trg_touch_folder_on_set
    AFTER INSERT OR UPDATE OR DELETE ON public.Sets
    FOR EACH ROW EXECUTE FUNCTION public.touch_parent_folder();

CREATE TRIGGER trg_touch_folder_on_subfolder
    AFTER INSERT OR UPDATE OR DELETE ON public.Folders
    FOR EACH ROW EXECUTE FUNCTION public.touch_parent_folder();


-- migrate:down
DROP TRIGGER IF EXISTS trg_touch_folder_on_subfolder ON public.Folders;
DROP TRIGGER IF EXISTS trg_touch_folder_on_set ON public.Sets;
DROP TRIGGER IF EXISTS trg_touch_set_on_card ON public.Cards;

DROP FUNCTION IF EXISTS public.touch_parent_folder();
DROP FUNCTION IF EXISTS public.touch_parent_set();
