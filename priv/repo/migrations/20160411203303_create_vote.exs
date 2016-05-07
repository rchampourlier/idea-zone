defmodule IdeaZone.Repo.Migrations.CreateVote do
  use Ecto.Migration

  def change do
    create table(:votes) do
      add :content_id, references(:contents)
      add :vote_type, :string, default: "neutral"
      add :user_session_token, :string

      timestamps
    end

    create index(:votes, [:content_id])
    create unique_index(:votes, [:content_id, :user_session_token])
  end
end
