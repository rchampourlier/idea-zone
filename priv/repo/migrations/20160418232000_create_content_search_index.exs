defmodule Repo.Migrations.ContentSearch do
  use Ecto.Migration

  def up do
    execute "CREATE EXTENSION unaccent;"
    execute "CREATE TEXT SEARCH CONFIGURATION fr ( COPY = french );"
    execute "ALTER TEXT SEARCH CONFIGURATION fr ALTER MAPPING FOR hword, hword_part, word WITH unaccent, french_stem;"
  end

  def down do
    execute "DROP TEXT SEARCH CONFIGURATION fr;"
    execute "DROP EXTENSION unaccent;"
  end
end
