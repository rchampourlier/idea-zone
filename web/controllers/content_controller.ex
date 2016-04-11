defmodule IdeaZone.ContentController do
  use IdeaZone.Web, :controller
  require IEx

  alias IdeaZone.Content
  alias IdeaZone.ContentStatus
  alias IdeaZone.ContentType

  plug :scrub_params, "content" when action in [:create, :update]
  plug IdeaZone.Plugs.SessionToken when action in [:show]

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
