defmodule IdeaZone.Admin.ContentController do
  use IdeaZone.Web, :controller

  alias IdeaZone.Comment
  alias IdeaZone.Content
  alias IdeaZone.ContentController
  alias IdeaZone.Vote

  plug :scrub_params, "content" when action in [:create, :update]

  def index(conn, params) do
    IdeaZone.ContentController.index(conn, params)
  end

  # DUPLICATION with web/controllers/content_controller.ex
  def show(conn, %{"id" => id}) do
    user_session_token = get_session(conn, :session_token)

    content = Content
      |> Repo.get!(id)
      |> Repo.preload([:comments, :type, :votes])
      |> Content.calculate_vote_score
      |> Content.calculate_vote_for_user(user_session_token)

    changeset = Content.changeset(content, %{})
    comment_changeset = Comment.changeset(%Comment{content_id: id}, %{})
    vote = Content.get_vote_for_user(content, user_session_token)
    vote_changeset = Vote.changeset(vote || %Vote{}, %{})

    conn
      |> assign(:content, content)
      |> assign(:changeset, changeset)
      |> assign(:comment_changeset, comment_changeset)
      |> assign(:vote_changeset, vote_changeset)
      |> assign(:vote_action, ContentController.vote_action(conn, content, vote))
      |> assign(:vote_settings, ContentController.vote_settings(vote))
      |> assign(:toggle_label, toggle_label(content.hidden))
      |> render("show.html")
  end

  def edit(conn, %{"id" => id}) do
    content = Repo.get!(Content, id)
    changeset = Content.changeset(content)
    conn
      |> ContentController.assign_types
      |> assign(:changeset, changeset)
      |> assign(:content, content)
      |> render("edit.html")
  end

  def update(conn, %{"id" => id, "content" => content_params}) do
    content = Repo.get!(Content, id)
    changeset = Content.changeset(content, content_params)

    case Repo.update(changeset) do
      {:ok, content} ->
        conn
        |> put_flash(:info, "Content updated successfully.")
        |> redirect(to: admin_content_path(conn, :show, content))
      {:error, changeset} ->
        conn
          |> ContentController.assign_types
          |> assign(:content, content)
          |> assign(:changeset, changeset)
          |> render("edit.html")
    end
  end

  def toggle(conn, %{"id" => id}) do
    content = Repo.get!(Content, id)
    label = if content.hidden, do: "displayed", else: "hidden"
    changeset = Content.changeset(content, %{hidden: !content.hidden})

    case Repo.update(changeset) do
      {:ok, content} ->
        conn
          |> put_flash(:info, "Content successfully #{label}")
          |> redirect(to: admin_content_path(conn, :show, content))
      {:error, _changeset} ->
        conn
          |> put_flash(:info, "Could not update the content")
          |> redirect(to: admin_content_path(conn, :show, content))
    end
  end

  def mark_new(conn, %{"id" => id}), do: update_status(conn, id, "new")
  def mark_in_progress(conn, %{"id" => id}), do: update_status(conn, id, "in_progress")
  def mark_solved(conn, %{"id" => id}), do: update_status(conn, id, "solved")

  def delete(conn, %{"id" => id}) do
    content = Repo.get!(Content, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(content)

    conn
    |> put_flash(:info, "Content deleted successfully.")
    |> redirect(to: content_path(conn, :index))
  end

  defp toggle_label(true), do: "Show"
  defp toggle_label(_), do: "Hide"

  defp update_status(conn, id, new_status) do
    content = Repo.get!(Content, id)
    changeset = Content.changeset(content, %{status: new_status})

    case Repo.update(changeset) do
      {:ok, content} ->
        conn
          |> put_flash(:info, "Successfully updated status.")
          |> redirect(to: admin_content_path(conn, :show, content))
      {:error, _changeset} ->
        conn
          |> put_flash(:info, "Could not change the status.")
          |> redirect(to: admin_content_path(conn, :show, content))
    end
  end
end
