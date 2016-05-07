defmodule IdeaZone.Vote do
  @moduledoc """
  Resource representing user votes on `Content`s.

  ## Fields
    - `user_session_token`: String, the session token of the user
      that created the vote.
    - `vote_type`: String, may be "for", "against" or "neutral"

  ## TODO
    - Add validation on `vote_type` to ensure it's in the expected
      values.
  """
  use IdeaZone.Web, :model

  schema "votes" do
    field :user_session_token, :string
    field :vote_type, :string, default: "neutral"

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
end
