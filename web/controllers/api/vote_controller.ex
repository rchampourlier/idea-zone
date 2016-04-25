defmodule IdeaZone.API.VoteController do
  use IdeaZone.Web, :controller
  alias IdeaZone.Vote

  plug :scrub_params, "vote" when action in [:create]

  @doc """
  POST /api/contents

  Creates a new Content record if there is no record with the same
  user_session_token. If there is already one and the vote is not
  of the same type (for/against), the existing vote is updated.
  Otherwise an error status is returned with the appropriate error
  message.

  Expected params:
    - content_id [String]
    - user_session_token [String]
    - vote_type [String]
  """
  def create(conn, %{"vote" => vote_params}) do
    user_session_token = get_session(conn, :session_token)
    vote_params = Map.merge(vote_params, %{"user_session_token" => user_session_token})

    changeset = Vote.changeset(%Vote{}, vote_params)
    case Vote.process_vote(changeset) do
      {:ok, vote} -> render(conn, "show.json", vote: vote)
      {:error, messages} -> render(conn, "error.json", messages: messages)
    end
  end
end
