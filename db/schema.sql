\restrict CW6bBlCWrUUzIciVCKUyoFXg0mX8PNdp4Nv8XMySsWKT4fiZbIfAdfQkJaKMTvM

-- Dumped from database version 17.7
-- Dumped by pg_dump version 17.7

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA public IS '
# FlashDeck API 📚

Welcome to the **FlashDeck API** documentation.
';


--
-- Name: sync_user(text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.sync_user(p_username text, p_avatar_url text DEFAULT NULL::text) RETURNS json
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public', 'pg_temp'
    AS $$
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
$$;


--
-- Name: FUNCTION sync_user(p_username text, p_avatar_url text); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.sync_user(p_username text, p_avatar_url text) IS 'Sync Auth0 User

Upserts the authenticated user into the database using the JWT `sub` claim as the ID.
Call this endpoint immediately after login on the frontend to ensure the user exists in the local DB.
';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: cards; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cards (
    card_id integer NOT NULL,
    set_id integer NOT NULL,
    front_text text NOT NULL,
    back_text text NOT NULL,
    CONSTRAINT chk_card_back_not_empty CHECK ((length(TRIM(BOTH FROM back_text)) > 0)),
    CONSTRAINT chk_card_front_not_empty CHECK ((length(TRIM(BOTH FROM front_text)) > 0))
);


--
-- Name: TABLE cards; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.cards IS 'Flashcards

Individual study items containing a front (question) and back (answer) side.
Cards strictly belong to a Set and inherit access permissions from it.
';


--
-- Name: COLUMN cards.front_text; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.cards.front_text IS 'The question or main content shown on the front of the card.';


--
-- Name: COLUMN cards.back_text; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.cards.back_text IS 'The answer or content shown on the back of the card.';


--
-- Name: cards_card_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.cards ALTER COLUMN card_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.cards_card_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: folders; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.folders (
    folder_id integer NOT NULL,
    user_id text NOT NULL,
    parent_folder_id integer,
    folder_name character varying(100) NOT NULL,
    CONSTRAINT chk_folder_name_not_empty CHECK ((length(TRIM(BOTH FROM folder_name)) > 0))
);


--
-- Name: TABLE folders; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.folders IS 'Study Folders

Hierarchical structure for organizing study sets.
Supports **infinite nesting** via the `parent_folder_id` self-reference.
Roots folders have `parent_folder_id` set to `NULL`.
';


--
-- Name: COLUMN folders.user_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.folders.user_id IS 'The owner of the folder.';


--
-- Name: COLUMN folders.parent_folder_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.folders.parent_folder_id IS 'ID of the parent folder. If NULL, this is a root-level folder.';


--
-- Name: COLUMN folders.folder_name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.folders.folder_name IS 'Display name of the folder.';


--
-- Name: folders_folder_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.folders ALTER COLUMN folder_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.folders_folder_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: progress; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.progress (
    user_id text NOT NULL,
    card_id integer NOT NULL,
    last_correct boolean,
    total_count integer DEFAULT 0,
    correct_count integer DEFAULT 0,
    CONSTRAINT chk_progress_correct_le_total CHECK ((correct_count <= total_count)),
    CONSTRAINT chk_progress_correct_non_negative CHECK ((correct_count >= 0)),
    CONSTRAINT chk_progress_total_non_negative CHECK ((total_count >= 0))
);


--
-- Name: TABLE progress; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.progress IS 'Learning Statistics

Tracks the user''''s performance on specific cards.
';


--
-- Name: COLUMN progress.last_correct; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.progress.last_correct IS 'Result of the most recent review attempt. NULL indicates not yet reviewed.';


--
-- Name: COLUMN progress.total_count; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.progress.total_count IS 'Total number of times this card has been reviewed.';


--
-- Name: COLUMN progress.correct_count; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.progress.correct_count IS 'Number of times the user answered correctly.';


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: sets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sets (
    set_id integer NOT NULL,
    user_id text NOT NULL,
    folder_id integer,
    set_name character varying(100) NOT NULL,
    is_public boolean DEFAULT false,
    creation_date timestamp with time zone DEFAULT now(),
    CONSTRAINT chk_set_name_not_empty CHECK ((length(TRIM(BOTH FROM set_name)) > 0))
);


--
-- Name: TABLE sets; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.sets IS 'Flashcard Sets

A collection of flashcards created by a user.
Sets can be marked as **public**, making them readable by all users (including anonymous ones).
';


--
-- Name: COLUMN sets.folder_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sets.folder_id IS 'The folder containing this set. Can be NULL if the set is at the root level.';


--
-- Name: COLUMN sets.is_public; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sets.is_public IS 'Visibility flag. If true, the set is readable by all anonymous and authenticated users.';


--
-- Name: sets_set_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.sets ALTER COLUMN set_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sets_set_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id text NOT NULL,
    username text NOT NULL,
    avatar_url text,
    created_at timestamp with time zone DEFAULT now(),
    last_login timestamp with time zone DEFAULT now(),
    CONSTRAINT chk_users_id_not_empty CHECK ((length(TRIM(BOTH FROM id)) > 0)),
    CONSTRAINT chk_users_username_length CHECK ((length(TRIM(BOTH FROM username)) >= 2))
);


--
-- Name: TABLE users; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.users IS 'User Profiles

Stores user identity data synchronized from Auth0.
This table serves as the root entity for all user-owned data (folders, sets, progress).
';


--
-- Name: COLUMN users.id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.users.id IS 'Unique identifier from Auth0 (Subject ID). Used as the primary key.';


--
-- Name: COLUMN users.username; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.users.username IS 'User display name.';


--
-- Name: COLUMN users.avatar_url; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.users.avatar_url IS 'URL to the user avatar image.';


--
-- Name: COLUMN users.last_login; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.users.last_login IS 'Timestamp of the last successful synchronization/login.';


--
-- Name: cards cards_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cards
    ADD CONSTRAINT cards_pkey PRIMARY KEY (card_id);


--
-- Name: folders folders_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.folders
    ADD CONSTRAINT folders_pkey PRIMARY KEY (folder_id);


--
-- Name: progress pk_progress; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.progress
    ADD CONSTRAINT pk_progress PRIMARY KEY (user_id, card_id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: sets sets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sets
    ADD CONSTRAINT sets_pkey PRIMARY KEY (set_id);


--
-- Name: sets uq_set_name_user; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sets
    ADD CONSTRAINT uq_set_name_user UNIQUE (user_id, set_name);


--
-- Name: CONSTRAINT uq_set_name_user ON sets; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON CONSTRAINT uq_set_name_user ON public.sets IS 'Ensures that a user cannot have two sets with the exact same name.';


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: cards fk_card_set; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cards
    ADD CONSTRAINT fk_card_set FOREIGN KEY (set_id) REFERENCES public.sets(set_id) ON DELETE CASCADE;


--
-- Name: folders fk_folder_parent; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.folders
    ADD CONSTRAINT fk_folder_parent FOREIGN KEY (parent_folder_id) REFERENCES public.folders(folder_id) ON DELETE CASCADE;


--
-- Name: folders fk_folder_user; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.folders
    ADD CONSTRAINT fk_folder_user FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: progress fk_progress_card; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.progress
    ADD CONSTRAINT fk_progress_card FOREIGN KEY (card_id) REFERENCES public.cards(card_id) ON DELETE CASCADE;


--
-- Name: progress fk_progress_user; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.progress
    ADD CONSTRAINT fk_progress_user FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: sets fk_set_folder; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sets
    ADD CONSTRAINT fk_set_folder FOREIGN KEY (folder_id) REFERENCES public.folders(folder_id) ON DELETE SET NULL;


--
-- Name: sets fk_set_user; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sets
    ADD CONSTRAINT fk_set_user FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: cards Cards modifiable by Set owner; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Cards modifiable by Set owner" ON public.cards USING ((EXISTS ( SELECT 1
   FROM public.sets s
  WHERE ((s.set_id = cards.set_id) AND (s.user_id = ((current_setting('request.jwt.claims'::text, false))::json ->> 'sub'::text))))));


--
-- Name: cards Cards viewable via parent Set; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Cards viewable via parent Set" ON public.cards FOR SELECT USING ((EXISTS ( SELECT 1
   FROM public.sets s
  WHERE ((s.set_id = cards.set_id) AND ((s.user_id = ((current_setting('request.jwt.claims'::text, true))::json ->> 'sub'::text)) OR (s.is_public = true))))));


--
-- Name: folders Folders are private; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Folders are private" ON public.folders USING ((user_id = ((current_setting('request.jwt.claims'::text, false))::json ->> 'sub'::text)));


--
-- Name: progress Progress is private; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Progress is private" ON public.progress USING ((user_id = ((current_setting('request.jwt.claims'::text, false))::json ->> 'sub'::text)));


--
-- Name: sets Sets modifiable by owner; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Sets modifiable by owner" ON public.sets USING ((user_id = ((current_setting('request.jwt.claims'::text, false))::json ->> 'sub'::text)));


--
-- Name: sets Sets viewable by owner or public; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Sets viewable by owner or public" ON public.sets FOR SELECT USING (((user_id = ((current_setting('request.jwt.claims'::text, true))::json ->> 'sub'::text)) OR (is_public = true)));


--
-- Name: users Users are viewable by everyone; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users are viewable by everyone" ON public.users FOR SELECT USING (true);


--
-- Name: users Users can insert own profile; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can insert own profile" ON public.users FOR INSERT WITH CHECK ((id = ((current_setting('request.jwt.claims'::text, false))::json ->> 'sub'::text)));


--
-- Name: users Users can update own profile; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can update own profile" ON public.users FOR UPDATE USING ((id = ((current_setting('request.jwt.claims'::text, false))::json ->> 'sub'::text)));


--
-- Name: cards; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.cards ENABLE ROW LEVEL SECURITY;

--
-- Name: folders; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.folders ENABLE ROW LEVEL SECURITY;

--
-- Name: progress; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.progress ENABLE ROW LEVEL SECURITY;

--
-- Name: sets; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.sets ENABLE ROW LEVEL SECURITY;

--
-- Name: users; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

--
-- PostgreSQL database dump complete
--

\unrestrict CW6bBlCWrUUzIciVCKUyoFXg0mX8PNdp4Nv8XMySsWKT4fiZbIfAdfQkJaKMTvM


--
-- Dbmate schema migrations
--

INSERT INTO public.schema_migrations (version) VALUES
    ('20251126175548'),
    ('20251126180129'),
    ('20251126180433'),
    ('20251126180638'),
    ('20251126180847'),
    ('20251126181909'),
    ('20251126191715'),
    ('20251126193935');
