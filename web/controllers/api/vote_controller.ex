defmodule IdeaZone.API.VoteController do
  require IEx
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
    - user_session_token [String]
    - vote_type [String]

  ## TODO
    - check `content_id` param matches the vote's
  """
  def create(conn, %{"content_id" => content_id, "vote" => vote_params}) do
    user_session_token = get_session(conn, :session_token)
    vote_params = Map.merge(vote_params, %{"user_session_token" => user_session_token})

    changeset = Vote.changeset(%Vote{}, Map.merge(vote_params, %{"content_id" => content_id}))

    case Repo.insert(changeset) do
      {:ok, vote} -> render(conn, "show.json", vote: vote)
      {:error, changeset} -> render(conn, "error.json", messages: changeset)
    end
  end

  def update(conn, %{"id" => id, "content_id" => _content_id, "vote" => vote_params}) do
    user_session_token = get_session(conn, :session_token)
    vote_params = Map.merge(vote_params, %{"user_session_token" => user_session_token})

    vote = Repo.get!(Vote, id)
    changeset = Vote.changeset(vote, vote_params)

    case Repo.update(changeset) do
      {:ok, vote} -> render(conn, "show.json", vote: vote)
      {:error, changeset} -> render(conn, "error.json", messages: changeset)
    end
  end
end
