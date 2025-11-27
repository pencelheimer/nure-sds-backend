-- vim: set ft=pgsql :

-- migrate:up
CREATE OR REPLACE FUNCTION public.populate_german_course()
RETURNS json AS $$
DECLARE
    v_user_id TEXT := current_setting('request.jwt.claims', true)::json->>'sub';
    v_root_folder_id INT;
    v_sub_folder_id INT;
    v_set_id INT;
    v_count INT;
BEGIN
    INSERT INTO public.Folders (user_id, parent_folder_id, folder_name)
    VALUES (v_user_id, NULL, 'Німецька мова 🇩🇪')
    RETURNING folder_id INTO v_root_folder_id;

    INSERT INTO public.Folders (user_id, parent_folder_id, folder_name)
    VALUES (v_user_id, v_root_folder_id, 'Граматика та лексика')
    RETURNING folder_id INTO v_sub_folder_id;

    INSERT INTO public.Sets (user_id, folder_id, set_name, is_public)
    VALUES (v_user_id, v_sub_folder_id, 'Дієслова з прийменниками (B1/B2)', true)
    RETURNING set_id INTO v_set_id;

    INSERT INTO public.Cards (set_id, front_text, back_text)
    VALUES 
    (v_set_id, 'abhängen von [D]', 'залежати від' || chr(10) || 'Das hängt von der Situation ab.'),
    (v_set_id, 'abraten von [D]', 'відмовляти когось від чогось' || chr(10) || 'Ich rate dir vom Kauf des Computers ab.'),
    (v_set_id, 'achten auf [A]', 'звертати увагу на' || chr(10) || 'Achte bitte auf Fehler!'),
    (v_set_id, 'anfangen mit [D]', 'починати з' || chr(10) || 'Ich fange mit der Arbeit an.'),
    (v_set_id, 'Angst haben vor [D]', 'боятися чогось' || chr(10) || 'Ich habe Angst vor Spinnen.'),
    (v_set_id, 'ankommen auf [A]', 'залежати від' || chr(10) || 'Es kommt nur auf deine Fähigkeiten an.'),
    (v_set_id, 'arbeiten an [D]', 'працювати над' || chr(10) || 'Sie arbeitet an einem neuen Projekt.'),
    (v_set_id, 'sich ärgern über [A]', 'злитися через' || chr(10) || 'Sie ärgert sich über deine Bemerkung.'),
    (v_set_id, 'aufhören mit [D]', 'припиняти щось' || chr(10) || 'Ich höre mit dem Tanzkurs auf.'),
    (v_set_id, 'aufpassen auf [A]', 'пильнувати, наглядати за' || chr(10) || 'Ich muss auf meine Schwester aufpassen.'),
    (v_set_id, 'sich ausruhen von [D]', 'відпочивати від' || chr(10) || 'Er ruht sich vom Stress aus.'),
    (v_set_id, 'sich bedanken für [A]', 'дякувати за' || chr(10) || 'Sie bedankt sich für die Blumen.'),
    (v_set_id, 'beginnen mit [D]', 'починати з' || chr(10) || 'Wir beginnen mit der Lektion 5.'),
    (v_set_id, 'sich beklagen über [A]', 'скаржитися на' || chr(10) || 'Sie beklagen sich über das Chaos im Hotel.'),
    (v_set_id, 'beneiden um [A]', 'заздрити через' || chr(10) || 'Ich beneide dich um dein Wissen.'),
    (v_set_id, 'sich beschäftigen mit [D]', 'займатися чимось' || chr(10) || 'Ich beschäftige mich mit Vielem.'),
    (v_set_id, 'sich beschweren über [A]', 'скаржитися на' || chr(10) || 'Wir beschweren uns über den Lärm.'),
    (v_set_id, 'bestehen aus [D]', 'складатися з' || chr(10) || 'Das Kostüm besteht aus Jacke und Rock.'),
    (v_set_id, 'bestehen auf [D]', 'наполягати на' || chr(10) || 'Er besteht auf seinem Recht.'),
    (v_set_id, 'sich beteiligen an [D]', 'брати участь у' || chr(10) || 'Ich beteilige mich am Spiel.'),
    (v_set_id, 'betrachten als [A]', 'вважати кимось/чимось' || chr(10) || 'Sie betrachtet ihn als Freund.'),
    (v_set_id, 'sich bewerben um [A]', 'подаватися на' || chr(10) || 'Er bewirbt sich um eine neue Stelle.'),
    (v_set_id, 'sich beziehen auf [A]', 'посилатися на' || chr(10) || 'Ich beziehe mich auf den zweiten Absatz.'),
    (v_set_id, 'bitten um [A]', 'просити про' || chr(10) || 'Er bittet sie um einen Gefallen.'),
    (v_set_id, 'danken für [A]', 'дякувати за' || chr(10) || 'Ich danke dir für die Hilfe.'),
    (v_set_id, 'denken an [A]', 'думати про' || chr(10) || 'Er denkt an dich.'),
    (v_set_id, 'denken über [A]', 'міркувати про' || chr(10) || 'Er denkt gut über dich.'),
    (v_set_id, 'sich eignen für [A]', 'підходити для' || chr(10) || 'Er eignet sich für jede Arbeit.'),
    (v_set_id, 'sich einigen mit [D]', 'домовитися з' || chr(10) || 'Wir einigen uns mit dir.'),
    (v_set_id, 'einladen zu [D]', 'запрошувати на' || chr(10) || 'Ich lade dich zum Essen ein.'),
    (v_set_id, 'einverstanden sein mit [D]', 'погоджуватись із' || chr(10) || 'Ich bin mit deinem Vorschlag einverstanden.'),
    (v_set_id, 'sich entscheiden für [A]', 'вирішувати на користь' || chr(10) || 'Ich entscheide mich für die Freiheit.'),
    (v_set_id, 'sich entschließen zu [D]', 'зважитися на' || chr(10) || 'Er hat sich zu ihren Gunsten entschlossen.'),
    (v_set_id, 'sich erinnern an [A]', 'пам''ятати, згадувати' || chr(10) || 'Er erinnert sich an sie.'),
    (v_set_id, 'erzählen von [D]', 'розповідати про' || chr(10) || 'Er erzählt vom Weltkrieg.'),
    (v_set_id, 'folgen auf [A]', 'слідувати за' || chr(10) || 'Der Sommer folgt auf den Frühling.'),
    (v_set_id, 'fragen nach [D]', 'питати про' || chr(10) || 'Er fragt nach deiner Telefonnummer.'),
    (v_set_id, 'sich freuen auf [A]', 'радіти наперед' || chr(10) || 'Ich freue mich schon sehr auf die Ferien.'),
    (v_set_id, 'sich freuen über [A]', 'радіти чомусь' || chr(10) || 'Ich freue mich über deinen Erfolg.'),
    (v_set_id, 'sich fürchten vor [D]', 'боятися чогось' || chr(10) || 'Du fürchtest dich vor der Dunkelheit?'),
    (v_set_id, 'gehören zu [D]', 'належати до' || chr(10) || 'Er gehört zu mir.'),
    (v_set_id, 'sich gewöhnen an [A]', 'звикати до' || chr(10) || 'Wir hatten uns gerade an sie gewöhnt.'),
    (v_set_id, 'gratulieren zu [D]', 'вітати з' || chr(10) || 'Ich gratuliere dir zu deiner Hochzeit.'),
    (v_set_id, 'grüßen von [D]', 'передавати вітання від' || chr(10) || 'Schöne Grüße von Andrea.'),
    (v_set_id, 'halten von [D]', 'мати думку про' || chr(10) || 'Ich halte nichts von ihm.'),
    (v_set_id, 'halten für [A]', 'вважати кимось/чимось' || chr(10) || 'Er hält ihn für ein Genie.'),
    (v_set_id, 'es handelt sich um [A]', 'йдеться про' || chr(10) || 'Es handelt sich um einen Präzedenzfall.'),
    (v_set_id, 'helfen bei [D]', 'допомагати з' || chr(10) || 'Er hilft ihr bei den Aufgaben.'),
    (v_set_id, 'sich interessieren für [A]', 'цікавитися чимось' || chr(10) || 'Wir interessieren uns für viele Dinge.'),
    (v_set_id, 'interessiert sein an [D]', 'бути зацікавленим у' || chr(10) || 'Er ist sehr interessiert an dieser Arbeit.'),
    (v_set_id, 'sich kümmern um [A]', 'піклуватися про' || chr(10) || 'Er kümmert sich um die Kinder.'),
    (v_set_id, 'lachen über [A]', 'сміятися з' || chr(10) || 'Er lacht über den Witz.'),
    (v_set_id, 'leiden an [D]', 'страждати на' || chr(10) || 'Sie leidet an einer Allergie.'),
    (v_set_id, 'leiden unter [D]', 'страждати через' || chr(10) || 'Sie leiden unter der Trennung.'),
    (v_set_id, 'liefern an [A]', 'постачати комусь' || chr(10) || 'Wir liefern nur an Privatkunden.'),
    (v_set_id, 'nachdenken über [A]', 'обдумувати щось' || chr(10) || 'Sie denkt über ihr Handeln nach.'),
    (v_set_id, 'passen zu [D]', 'пасувати до' || chr(10) || 'Rot passt nicht zu rosa.'),
    (v_set_id, 'protestieren gegen [A]', 'протестувати проти' || chr(10) || 'Sie protestieren gegen rechte Gewalt.'),
    (v_set_id, 'demonstrieren für [A]', 'демонструвати за' || chr(10) || 'Sie demonstrieren für eine autofreie Zone.'),
    (v_set_id, 'raten zu [D]', 'радити щось' || chr(10) || 'Ich rate dir zu Geduld.'),
    (v_set_id, 'reagieren auf [A]', 'реагувати на' || chr(10) || 'Sie reagiert nicht auf diesen Namen.'),
    (v_set_id, 'reden über [A]', 'говорити про' || chr(10) || 'Er redet nur über Medizin.'),
    (v_set_id, 'sagen zu [D]', 'сказати щодо' || chr(10) || 'Er sagt zu allem "Ja und Amen."'),
    (v_set_id, 'schreiben an [A]', 'писати комусь' || chr(10) || 'Sie schreiben Briefe an ihre Freunde.'),
    (v_set_id, 'sorgen für [A]', 'піклуватися про' || chr(10) || 'Sie sorgt für dich.'),
    (v_set_id, 'sich sorgen um [A]', 'турбуватися про' || chr(10) || 'Sie sorgt sich um dein Wohlergehen.'),
    (v_set_id, 'spielen mit [D]', 'грати з' || chr(10) || 'Sie spielt mit ihren Tieren.'),
    (v_set_id, 'sprechen mit [D]', 'розмовляти з' || chr(10) || 'Sie spricht deutsch mit ihm.'),
    (v_set_id, 'sprechen über [A]', 'говорити про' || chr(10) || 'Er spricht über Lessings „Emilia Galotti".'),
    (v_set_id, 'stimmen für [A]', 'голосувати за' || chr(10) || 'Wir stimmen für ihn.'),
    (v_set_id, 'sich streiten um [A]', 'сваритися через' || chr(10) || 'Sie streiten sich um das Geld.'),
    (v_set_id, 'suchen nach [D]', 'шукати щось' || chr(10) || 'Ich suche nach einer Lösung für mein Problem.'),
    (v_set_id, 'teilnehmen an [D]', 'брати участь у' || chr(10) || 'Wir nehmen nicht an der Verlosung teil.'),
    (v_set_id, 'träumen von [D]', 'мріяти про' || chr(10) || 'Er träumt vom großen Glück in Amerika.'),
    (v_set_id, 'überreden zu [D]', 'вмовляти на' || chr(10) || 'Sie überredete ihn zu diesem Vergehen.'),
    (v_set_id, 'übersetzen in [A]', 'перекладати на' || chr(10) || 'Wir übersetzen ins Deutsche.'),
    (v_set_id, 'überzeugen von [D]', 'переконувати в' || chr(10) || 'Ich bin von deinem Vorschlag nicht überzeugt.'),
    (v_set_id, 'sich unterhalten mit [D]', 'спілкуватися з' || chr(10) || 'Ihr unterhaltet euch mit Freunden.'),
    (v_set_id, 'sich unterhalten über [A]', 'говорити про' || chr(10) || 'Wir haben uns über Dalí unterhalten.'),
    (v_set_id, 'unterscheiden von [D]', 'відрізняти від' || chr(10) || 'Ich kann sie nicht voneinander unterscheiden.'),
    (v_set_id, 'sich verabreden mit [D]', 'домовлятися з' || chr(10) || 'Wir verabreden uns mit zwei Franzosen.'),
    (v_set_id, 'sich verabschieden von [D]', 'прощатися з' || chr(10) || 'Sie verabschiedet sich von ihrer Familie.'),
    (v_set_id, 'vergleichen mit [D]', 'порівнювати з' || chr(10) || 'Sie vergleicht sich mit ihr.'),
    (v_set_id, 'verkaufen an [A]', 'продавати комусь' || chr(10) || 'Sie verkaufen auch an Minderjährige?'),
    (v_set_id, 'sich verlassen auf [A]', 'покладатися на' || chr(10) || 'Er verlässt sich auf dich.'),
    (v_set_id, 'sich verlieben in [A]', 'закохатися в' || chr(10) || 'Er hat sich in sie verliebt.'),
    (v_set_id, 'sich verstehen mit [D]', 'ладнати з' || chr(10) || 'Wir verstehen uns gut mit ihr.'),
    (v_set_id, 'verzichten auf [A]', 'відмовлятися від' || chr(10) || 'Ich verzichte auf meine Rechte.'),
    (v_set_id, 'warnen vor [D]', 'попереджати про' || chr(10) || 'Wir warnen Sie vor möglichen Gefahren.'),
    (v_set_id, 'warten auf [A]', 'чекати на' || chr(10) || 'Sie warten auf eine Antwort.'),
    (v_set_id, 'sich wenden an [A]', 'звертатися до' || chr(10) || 'Wenden Sie sich bitte an meinen Vorgesetzten!'),
    (v_set_id, 'wissen über [A]', 'знати про' || chr(10) || 'Ich weiß nichts über dich.'),
    (v_set_id, 'sich wundern über [A]', 'дивуватися чомусь' || chr(10) || 'Er wundert sich über sich selbst.'),
    (v_set_id, 'zählen zu [D]', 'належати до' || chr(10) || 'Sie zählt zur Familie.'),
    (v_set_id, 'zunehmen an [D]', 'зростати в' || chr(10) || 'Er nimmt an Gewicht zu.');

    GET DIAGNOSTICS v_count = ROW_COUNT;

    RETURN json_build_object(
        'status', 'success',
        'root_folder_id', v_root_folder_id,
        'set_id', v_set_id
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, pg_temp;

COMMENT ON FUNCTION public.populate_german_course IS 'Creates a demonstration structure (Folders, Sets, Cards) for learning German.';

GRANT EXECUTE ON FUNCTION public.populate_german_course() TO api_user;


-- migrate:down
DROP FUNCTION IF EXISTS public.populate_german_course();
