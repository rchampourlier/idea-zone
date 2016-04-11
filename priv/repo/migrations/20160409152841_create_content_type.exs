defmodule IdeaZone.Repo.Migrations.CreateContentType do
  use Ecto.Migration

  def change do
    create table(:content_types) do
      add :label, :string

      timestamps
    end

  end
end
