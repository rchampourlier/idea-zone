defmodule Repo.Migrations.SetupContentSearch do
  use Ecto.Migration

  def up do
    # Setup text search configurations
    execute "CREATE EXTENSION unaccent;"
    execute "CREATE TEXT SEARCH CONFIGURATION fr ( COPY = french );"
    execute "ALTER TEXT SEARCH CONFIGURATION fr ALTER MAPPING FOR hword, hword_part, word WITH unaccent, french_stem;"
    execute "CREATE TEXT SEARCH CONFIGURATION en ( COPY = english );"

    # Setup index
    execute "ALTER TABLE contents ADD COLUMN tsv tsvector;"
    execute "CREATE INDEX tsv_index ON contents USING gin(tsv);"

    # Fill the index for current contents
    execute """
    UPDATE contents
    SET tsv = setweight(to_tsvector(contents.language::regconfig, contents.label), 'A') ||
              setweight(to_tsvector(contents.language::regconfig, contents.description), 'D')
    """

    # Setup a function to update the tsv index column for contents
    execute """
    CREATE FUNCTION contents_search_trigger() RETURNS trigger AS $$
    begin
      new.tsv := setweight(to_tsvector(new.language::regconfig, new.label), 'A') ||
                 setweight(to_tsvector(new.language::regconfig, new.description), 'D');
      return new;
    end
    $$ LANGUAGE plpgsql;
    """

    # Create a trigger to apply this function on contents update
    execute """
    CREATE TRIGGER tsvectorupdate BEFORE INSERT OR UPDATE
    ON contents FOR EACH ROW EXECUTE PROCEDURE contents_search_trigger();
    """
  end

  def down do
    execute "DROP TRIGGER tsvectorupdate ON contents;"
    execute "DROP FUNCTION contents_search_trigger();"
    execute "DROP TEXT SEARCH CONFIGURATION en;"
    execute "DROP TEXT SEARCH CONFIGURATION fr;"
    execute "DROP EXTENSION unaccent;"
  end
end
