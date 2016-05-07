defmodule IdeaZone.VoteController do
  use IdeaZone.Web, :controller
  alias IdeaZone.Vote

  plug :scrub_params, "vote" when action in [:create]

  def create(conn, %{"content_id" => content_id, "vote" => vote_params}) do
    user_session_token = get_session(conn, :session_token)
    vote_params = Map.merge(vote_params, %{"user_session_token" => user_session_token})

    changeset = Vote.changeset(%Vote{}, Map.merge(vote_params, %{"content_id" => content_id}))

    case Repo.insert(changeset) do
      {:ok, _vote} ->
        conn
        |> put_flash(:success, "Vote updated successfully.")
        |> redirect(to: content_path(conn, :show, content_id))
      {:error, _changeset} ->
        conn
          |> put_flash(:error, "Failed to add vote.")
          |> redirect(to: content_path(conn, :show, content_id))
    end
  end

  def update(conn, %{"id" => id, "content_id" => content_id, "vote" => vote_params}) do
    user_session_token = get_session(conn, :session_token)
    vote_params = Map.merge(vote_params, %{"user_session_token" => user_session_token})

    vote = Repo.get!(Vote, id)
    changeset = Vote.changeset(vote, vote_params)

    case Repo.update(changeset) do
      {:ok, _vote} ->
        conn
        |> put_flash(:success, "Vote updated successfully.")
        |> redirect(to: content_path(conn, :show, content_id))
      {:error, _changeset} ->
        conn
          |> put_flash(:error, "Failed to add vote.")
          |> redirect(to: content_path(conn, :show, content_id))
    end
  end
end
