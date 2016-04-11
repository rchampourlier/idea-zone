defmodule IdeaZone.Admin.ContentController do
  use IdeaZone.Web, :controller

  alias IdeaZone.Content
  alias IdeaZone.ContentStatus
  alias IdeaZone.ContentType

  plug :scrub_params, "content" when action in [:create, :update]

  def index(conn, _params) do
    contents = Content |> Repo.all |> Repo.preload([:status, :type])
    render(conn, "index.html", contents: contents)
  end

  def new(conn, _params) do
    conn
      |> assign_statuses_and_types
      |> assign(:changeset, Content.changeset(%Content{}))
      |> render("new.html")
  end

  def create(conn, %{"content" => content_params}) do
    content_params = Map.merge(content_params, %{"status_id" => default_status_id})
    changeset = Content.changeset(%Content{}, content_params)

    case Repo.insert(changeset) do
      {:ok, _content} ->
        conn
        |> put_flash(:info, "Content created successfully.")
        |> redirect(to: content_path(conn, :index))
      {:error, changeset} ->
        conn
          |> assign_statuses_and_types
          |> assign(:changeset, changeset)
          |> render("new.html")
    end
  end

  def show(conn, %{"id" => id}) do
    content = Repo.get!(Content, id)
    render(conn, "show.html", content: content)
  end

  def edit(conn, %{"id" => id}) do
    content = Repo.get!(Content, id)
    changeset = Content.changeset(content)
    conn
      |> assign_statuses_and_types
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
        |> redirect(to: content_path(conn, :show, content))
      {:error, changeset} ->
        conn
          |> assign_statuses_and_types
          |> assign(:content, content)
          |> assign(:changeset, changeset)
          |> render("edit.html")
    end
  end

  def delete(conn, %{"id" => id}) do
    content = Repo.get!(Content, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(content)

    conn
    |> put_flash(:info, "Content deleted successfully.")
    |> redirect(to: content_path(conn, :index))
  end

  defp assign_statuses_and_types(conn) do
    statuses = Repo.all(from(status in ContentStatus, select: {status.label, status.id}))
    types = Repo.all(from(type in ContentType, select: {type.label, type.id}))
    conn
      |> assign(:statuses, statuses)
      |> assign(:types, types)
  end

  defp default_status_id do
    Repo.all(from s in ContentStatus, where: s.default == true, select: s)
      |> List.first
      |> Map.get(:id)
  end
end
