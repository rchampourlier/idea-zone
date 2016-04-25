defmodule IdeaZone.ContentController do
  use IdeaZone.Web, :controller

  alias IdeaZone.Comment
  alias IdeaZone.Content
  alias IdeaZone.ContentType
  alias IdeaZone.Vote

  plug :scrub_params, "content" when action in [:create]

  def index(conn, _params) do
    contents = Content
      |> Repo.all
      |> Repo.preload([:type])
    conn
      |> assign(:contents, contents)
      |> render("index.html")
  end

  def new(conn, params) do
    changeset = Content.changeset(%Content{}, %{"label" => params["label"] || ""})
    conn
      |> assign_types
      |> assign(:changeset, changeset)
      |> render("new.html")
  end

  def create(conn, %{"content" => content_params}) do
    content_params = content_params
      |> Map.merge(%{
        "status" => default_status,
        "language" => "fr"
      })
    changeset = Content.changeset(%Content{}, content_params)

    case Repo.insert(changeset) do
      {:ok, _content} ->
        conn
        |> put_flash(:info, "Content created successfully.")
        |> redirect(to: content_path(conn, :index))
      {:error, changeset} ->
        conn
          |> assign_types
          |> assign(:changeset, changeset)
          |> render("new.html")
    end
  end

  # SELECT * FROM (SELECT contents.*, SUM(CASE vote_type WHEN 'for' THEN 1 WHEN 'against' THEN -1 ELSE 0 END) FROM contents RIGHT JOIN votes ON contents.id = votes.content_id GROUP BY contents.id) c WHERE c.id = 1;
  def show(conn, %{"id" => id}) do
    user_session_token = get_session(conn, :session_token)
    content = Content
      |> Repo.get!(id)
      |> Repo.preload([:comments, :type, :votes])
      |> Content.calculate_vote_score
      |> Content.calculate_vote_type_for_current_user(user_session_token)

    comment_changeset = Comment.changeset(%Comment{content_id: id}, %{})
    vote_changeset = Vote.changeset(%Vote{content_id: id}, %{})

    conn
      |> assign(:content, content)
      |> assign(:comment_changeset, comment_changeset)
      |> assign(:vote_changeset, vote_changeset)
      |> render("show.html")
  end

  defp assign_types(conn) do
    types = Repo.all(from(type in ContentType, select: {type.label, type.id}))
    conn |> assign(:types, types)
  end

  defp default_status do
    "in_progress"
  end
end
