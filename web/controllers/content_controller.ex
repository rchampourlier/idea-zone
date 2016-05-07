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

  # DUPLICATION with web/controllers/admin/content_controller.ex
  def show(conn, %{"id" => id}) do
    user_session_token = get_session(conn, :session_token)

    content = Content
      |> Repo.get!(id)
      |> Repo.preload([:comments, :type, :votes])
      |> Content.calculate_vote_score
      |> Content.calculate_vote_for_user(user_session_token)

    comment_changeset = Comment.changeset(%Comment{content_id: id}, %{})
    vote = Content.get_vote_for_user(content, user_session_token)
    vote_changeset = Vote.changeset(vote || %Vote{}, %{})

    conn
      |> assign(:content, content)
      |> assign(:comment_changeset, comment_changeset)
      |> assign(:vote_changeset, vote_changeset)
      |> assign(:vote_action, vote_action(conn, content, vote))
      |> assign(:vote_settings, vote_settings(vote))
      |> render("show.html")
  end

  def vote_action(conn, content, nil), do: content_vote_path(conn, :create, content)
  def vote_action(conn, content, vote), do: content_vote_path(conn, :update, content, vote)

  def vote_settings(nil), do: %{up: %{type: "for", enabled: true}, down: %{type: "against", enabled: true}}
  def vote_settings(%{vote_type: "for"}), do: %{up: %{type: "for", enabled: false}, down: %{type: "neutral", enabled: true}}
  def vote_settings(%{vote_type: "neutral"}), do: %{up: %{type: "for", enabled: true}, down: %{type: "against", enabled: true}}
  def vote_settings(%{vote_type: "against"}), do: %{up: %{type: "neutral", enabled: true}, down: %{type: "against", enabled: false}}

  def assign_types(conn) do
    types = Repo.all(from(type in ContentType, select: {type.label, type.id}))
    conn |> assign(:types, types)
  end

  defp default_status, do: "in_progress"
end
