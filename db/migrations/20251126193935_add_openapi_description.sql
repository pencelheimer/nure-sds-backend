-- migrate:up
COMMENT ON SCHEMA public IS $$
# FlashDeck API 📚

Welcome to the **FlashDeck API** documentation.
$$;


-- migrate:down
COMMENT ON SCHEMA public IS NULL;
