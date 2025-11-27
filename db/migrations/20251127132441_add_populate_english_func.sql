-- vim: set ft=pgsql :

-- migrate:up
CREATE OR REPLACE FUNCTION public.populate_english_verbs()
RETURNS json AS $$
DECLARE
    v_user_id TEXT := current_setting('request.jwt.claims', true)::json->>'sub';
    v_set_id INT;
    v_count INT;
BEGIN
    INSERT INTO public.Sets (user_id, folder_id, set_name, is_public)
    VALUES (
        v_user_id,
        NULL,
        '10 найпоширеніших нерегулярних дієслів (Англійська мова) 🇬🇧',
        true
    )
    RETURNING set_id INTO v_set_id;

    INSERT INTO public.Cards (set_id, front_text, back_text)
    VALUES 
    (v_set_id, 'be', 'was/were - been' || chr(10) || 'бути'),
    (v_set_id, 'become', 'became - become' || chr(10) || 'ставати'),
    (v_set_id, 'begin', 'began - begun' || chr(10) || 'починати'),
    (v_set_id, 'break', 'broke - broken' || chr(10) || 'ламати'),
    (v_set_id, 'bring', 'brought - brought' || chr(10) || 'приносити'),
    (v_set_id, 'build', 'built - built' || chr(10) || 'будувати'),
    (v_set_id, 'buy', 'bought - bought' || chr(10) || 'купувати'),
    (v_set_id, 'catch', 'caught - caught' || chr(10) || 'ловити'),
    (v_set_id, 'choose', 'chose - chosen' || chr(10) || 'вибирати'),
    (v_set_id, 'come', 'came - come' || chr(10) || 'приходити');

    GET DIAGNOSTICS v_count = ROW_COUNT;

    RETURN json_build_object(
        'status', 'success',
        'set_id', v_set_id
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, pg_temp;

COMMENT ON FUNCTION public.populate_english_verbs IS 'Creates a root set (without a folder) with English verbs.';

GRANT EXECUTE ON FUNCTION public.populate_english_verbs() TO api_user;


-- migrate:down
DROP FUNCTION IF EXISTS public.populate_english_verbs();
