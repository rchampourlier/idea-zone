defmodule IdeaZone.CommentController do
  use IdeaZone.Web, :controller

  alias IdeaZone.Comment

  plug :scrub_params, "comment" when action in [:create]
  plug IdeaZone.Plugs.EnsureSessionToken

  def create(conn, %{"content_id" => content_id, "comment" => comment_params}) do
    comment_params = comment_params
      |> Map.merge(%{"content_id" => content_id})
    changeset = Comment.changeset(%Comment{}, comment_params)

    case Repo.insert(changeset) do
      {:ok, _content} ->
        conn
        |> put_flash(:info, "Comment created successfully.")
        |> redirect(to: content_path(conn, :show, content_id))
      {:error, _changeset} ->
        conn
          |> put_flash(:error, "Failed to add comment.")
          |> redirect(to: content_path(conn, :show, content_id))
    end
  end
end
