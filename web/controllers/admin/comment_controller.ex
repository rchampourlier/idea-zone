defmodule IdeaZone.Admin.CommentController do
  use IdeaZone.Web, :controller

  alias IdeaZone.Comment

  plug :scrub_params, "comment" when action in [:create, :update]

  def edit(conn, %{"id" => id}) do
    comment = Repo.get!(Comment, id)
    changeset = Comment.changeset(comment)
    conn
      |> assign(:changeset, changeset)
      |> assign(:comment, comment)
      |> render("edit.html")
  end

  def update(conn, %{"id" => id, "comment" => comment_params}) do
    comment = Repo.get!(Comment, id)
    changeset = Comment.changeset(comment, comment_params)

    case Repo.update(changeset) do
      {:ok, comment} ->
        conn
          |> put_flash(:info, "Comment updated successfully.")
          |> redirect(to: admin_content_path(conn, :show, comment.content_id))
      {:error, changeset} ->
        conn
          |> put_flash(:error, "Comment could not be updated.")
          |> redirect(to: admin_content_path(conn, :show, comment.content_id))
    end
  end

  def toggle(conn, %{"id" => id}) do
    comment = Repo.get!(Comment, id)
    changeset = Comment.changeset(comment, %{hidden: !comment.hidden})

    case Repo.update(changeset) do
      {:ok, comment} ->
        conn
          |> put_flash(:info, "Comment successfully toggled.")
          |> redirect(to: admin_content_path(conn, :show, comment.content_id))
      {:error, changeset} ->
        conn
          |> put_flash(:error, "Comment could not be toggled.")
          |> redirect(to: admin_content_path(conn, :show, comment.content_id))
    end
  end
end
