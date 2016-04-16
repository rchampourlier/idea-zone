defmodule IdeaZone.CommentController do
  use IdeaZone.Web, :controller

  alias IdeaZone.Comment

  plug :scrub_params, "comment" when action in [:create]
  plug IdeaZone.Plugs.EnsureSessionToken

  def create(conn, %{"comment" => comment_params}) do
    changeset = Comment.changeset(%Comment{}, comment_params)
    content_id = changeset.changes.content_id

    case Repo.insert(changeset) do
      {:ok, _content} ->
        conn
        |> put_flash(:info, "Comment created successfully.")
        |> redirect(to: content_path(conn, :show, content_id))
      {:error, changeset} ->
        conn
          |> put_flash(:error, "Failed to add comment.")
          |> redirect(to: content_path(conn, :show, content_id))
    end
  end
end
