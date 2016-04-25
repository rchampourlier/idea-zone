defmodule IdeaZone.Vote do
  require IEx
  use IdeaZone.Web, :model
  alias IdeaZone.Repo

  schema "votes" do
    field :user_session_token, :string
    field :vote_type, :string
    belongs_to :content, IdeaZone.Content

    timestamps
  end

  @required_fields ~w(user_session_token content_id vote_type)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> unique_constraint(:user_session_token, name: :votes_content_id_user_session_token_index)
  end

  def process_vote(changeset) do
    vote_type = changeset.changes.vote_type
    existing_vote = find_vote(changeset.changes)
    case existing_vote do
      %{vote_type: ^vote_type} -> {:error, messages: ["already voted #{vote_type}"]}
      %{vote_type: _} -> Repo.delete(existing_vote)
      nil -> Repo.insert(changeset)
    end
  end

  def find_vote(%{content_id: content_id, user_session_token: user_session_token}) do
    query = from v in __MODULE__,
      where: v.content_id == ^content_id,
      where: v.user_session_token == ^user_session_token
    Repo.all(query) |> Enum.at(0)
  end
end
