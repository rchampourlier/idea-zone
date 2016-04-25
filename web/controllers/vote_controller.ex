defmodule IdeaZone.VoteController do
  use IdeaZone.Web, :controller
  alias IdeaZone.Vote

  plug :scrub_params, "vote" when action in [:create]

  def create(conn, %{"vote" => vote_params}) do
    user_session_token = get_session(conn, :session_token)
    vote_params = Map.merge(vote_params, %{"user_session_token" => user_session_token})

    changeset = Vote.changeset(%Vote{}, vote_params)
    content_id = changeset.changes.content_id

    case Vote.process_vote(changeset) do
      {:ok, vote} ->
        conn
        |> put_flash(:success, "Your vote was taken into account!")
        |> redirect(to: content_path(conn, :show, content_id))
      {:error, messages} -> render(conn, "error.json", messages: messages)
        error_message = Enum.join(messages, ", ")
        conn
          |> put_flash(:error, "Failed to add vote #{error_message}.")
          |> redirect(to: content_path(conn, :show, content_id))
    end
  end
end
