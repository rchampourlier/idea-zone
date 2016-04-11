defmodule IdeaZone.Repo.Migrations.CreateContentStatus do
  use Ecto.Migration

  def change do
    create table(:content_statuses) do
      add :label, :string
      add :default, :boolean

      timestamps
    end

  end
end
