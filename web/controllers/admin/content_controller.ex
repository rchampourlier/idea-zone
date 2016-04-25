defmodule IdeaZone.Admin.ContentController do
  use IdeaZone.Web, :controller

  alias IdeaZone.Content
  alias IdeaZone.ContentType

  plug :scrub_params, "content" when action in [:create, :update]

  def index(conn, _params) do
    IdeaZone.ContentController.index(conn, _params)
  end

  def show(conn, %{"id" => id}) do
    content = Content
      |> Repo.get!(id)
      |> Repo.preload([:comments, :type])

    changeset = Content.changeset(content)

    conn
      |> assign(:content, content)
      |> assign(:changeset, changeset)
      |> assign(:toggle_label, toggle_label(content.hidden))
      |> render("show.html")
  end

  def edit(conn, %{"id" => id}) do
    content = Repo.get!(Content, id)
    changeset = Content.changeset(content)
    conn
      |> assign_types
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
          |> assign_types
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
      {:error, changeset} ->
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

  defp assign_types(conn) do
    types = Repo.all(from(type in ContentType, select: {type.label, type.id}))
    conn |> assign(:types, types)
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
      {:error, changeset} ->
        conn
          |> put_flash(:info, "Could not change the status.")
          |> redirect(to: admin_content_path(conn, :show, content))
    end
  end
end
