defmodule IdeaZone.ContentController do
  use IdeaZone.Web, :controller

  alias IdeaZone.Comment
  alias IdeaZone.Content
  alias IdeaZone.ContentStatus
  alias IdeaZone.ContentType
  alias IdeaZone.Vote

  plug :scrub_params, "content" when action in [:create, :update]

  def index(conn, _params) do
    contents = Content
      |> Repo.all
      |> Repo.preload([:status, :type])
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
    content = Content
      |> Repo.get!(id)
      |> Repo.preload([:comments, :status, :type])
    comment_changeset = Comment.changeset(%Comment{content_id: id}, %{})
    vote_changeset = Vote.changeset(%Vote{content_id: id}, %{})
    votes_count = Repo.all(from v in Vote, select: count(v.id)) |> List.first

    conn
      |> assign(:content, content)
      |> assign(:comment_changeset, comment_changeset)
      |> assign(:vote_changeset, vote_changeset)
      |> assign(:votes_count, votes_count)
      |> render("show.html")
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
