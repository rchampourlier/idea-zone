defmodule IdeaZone.Repo.Migrations.CreateComment do
  use Ecto.Migration

  def change do
    create table(:comments) do
      add :user_session_token, :string
      add :text, :text
      add :content_id, references(:contents)

      timestamps
    end

    create index(:comments, [:content_id])
  end
end
