defmodule IdeaZone.Vote do
  use IdeaZone.Web, :model

  schema "votes" do
    field :user_session_token, :string
    belongs_to :content, IdeaZone.Content

    timestamps
  end

  @required_fields ~w(user_session_token content_id)
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
end
