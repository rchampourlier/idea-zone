defmodule IdeaZone.VoteController do
  require IEx
  use IdeaZone.Web, :controller
  alias IdeaZone.Vote

  plug :scrub_params, "vote" when action in [:create]

  def create(conn, %{"vote" => vote_params}) do
    user_session_token = get_session(conn, :session_token)
    vote_params = Map.merge(vote_params, %{"user_session_token" => user_session_token})
    changeset = Vote.changeset(%Vote{}, vote_params)

    content_id = changeset.changes.content_id

    # IEx.pry
    case Repo.insert(changeset) do
      {:ok, _content} ->
        conn
        |> put_flash(:success, "Your vote was added!")
        |> redirect(to: content_path(conn, :show, content_id))
      {:error, %{errors: [user_session_token: "has already been taken"]}} ->
        conn
          |> put_flash(:error, "You already voted for this content")
          |> redirect(to: content_path(conn, :show, content_id))
      {:error, changeset} ->
        conn
          |> put_flash(:error, "Failed to add vote.")
          |> redirect(to: content_path(conn, :show, content_id))
    end
  end
end
