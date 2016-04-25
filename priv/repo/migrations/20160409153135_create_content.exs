defmodule IdeaZone.Repo.Migrations.CreateContent do
  use Ecto.Migration

  def change do
    create table(:contents) do
      add :label, :string
      add :description, :text
      add :hidden, :boolean, default: false, null: false
      add :official_answer, :text
      add :language, :string
      add :status, :string
      add :type_id, references(:content_types)

      timestamps
    end

    create index(:contents, [:language])
    create index(:contents, [:status])
    create index(:contents, [:type_id])
  end
end
