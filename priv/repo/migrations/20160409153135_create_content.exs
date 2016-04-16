defmodule IdeaZone.Repo.Migrations.CreateContent do
  use Ecto.Migration

  def change do
    create table(:contents) do
      add :label, :string
      add :description, :text
      add :type_id, references(:content_types)
      add :status_id, references(:content_statuses)

      timestamps
    end

    create index(:contents, [:type_id])
    create index(:contents, [:status_id])
  end
end
