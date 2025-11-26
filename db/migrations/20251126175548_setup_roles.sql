-- migrate:up
DROP ROLE IF EXISTS api_user;
DROP ROLE IF EXISTS anon;
DROP ROLE IF EXISTS authenticator;

CREATE ROLE authenticator NOINHERIT LOGIN PASSWORD 'password';
CREATE ROLE anon NOLOGIN;
CREATE ROLE api_user NOLOGIN;

GRANT usage ON schema public TO anon;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO anon;
REVOKE ALL PRIVILEGES ON TABLE public.schema_migrations FROM anon;

GRANT usage ON schema public TO api_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO api_user;
REVOKE ALL PRIVILEGES ON TABLE public.schema_migrations FROM api_user;

GRANT anon TO authenticator;
GRANT api_user TO authenticator;


-- migrate:down
REVOKE anon FROM authenticator;
REVOKE api_user FROM authenticator;

REVOKE usage ON schema public FROM anon;
REVOKE SELECT ON ALL TABLES IN SCHEMA public FROM anon;

REVOKE usage ON schema public FROM api_user;
REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA public FROM api_user;

DROP ROLE IF EXISTS api_user;
DROP ROLE IF EXISTS anon;
DROP ROLE IF EXISTS authenticator;
