defmodule IdeaZone.API.ContentController do
  use IdeaZone.Web, :controller
  alias IdeaZone.Content

  import Ecto.Query, only: [from: 2]

  def index(conn, %{"filter" => "", "include_hidden" => include_hidden}) do
    include_hidden = if include_hidden == "true" do true else false end
    user_session_token = get_session(conn, :session_token)
    contents = fetch(user_session_token, include_hidden: include_hidden && is_admin(conn))
    conn
      |> assign(:contents, contents)
      |> render("index.json")
  end
  def index(conn, %{"filter" => filter, "include_hidden" => include_hidden}) do
    include_hidden = if include_hidden == "true" do true else false end
    user_session_token = get_session(conn, :session_token)
    search_terms = filter |> String.split |> Enum.reject(fn(s) -> String.length(s) == 0 end)
    contents = fetch(user_session_token, search_terms, include_hidden: include_hidden && is_admin(conn))
    conn
      |> assign(:contents, contents)
      |> render("index.json")
  end
  def index(conn, _), do: index(conn, %{"filter" => ""})

  defp fetch(user_session_token, search_terms, include_hidden: include_hidden) do
    ids = Content.search(search_terms)
    query = case include_hidden do
      true -> from c in Content, where: c.id in ^ids
      false -> from c in Content, where: c.id in ^ids and c.hidden == false
    end
    Repo.all(query)
      |> Repo.preload([:votes, :type])
      |> map_vote_scores
      |> map_vote_for_current_user(user_session_token)
  end
  defp fetch(user_session_token, include_hidden: include_hidden) do
    query = case include_hidden do
      true -> from c in Content, select: c
      false -> from c in Content, where: c.hidden == false
    end
    Repo.all(query)
      |> Repo.preload([:votes, :type])
      |> map_vote_scores
      |> map_vote_for_current_user(user_session_token)
      |> sort_on_vote_scores
  end

  defp is_admin(conn), do: get_session(conn, :admin) || false

  defp map_vote_scores(contents) do
    contents |> Enum.map(&(Content.calculate_vote_score(&1)))
  end

  defp map_vote_for_current_user(contents, user_session_token) do
    contents |> Enum.map(&(Content.calculate_vote_for_user(&1, user_session_token)))
  end

  defp sort_on_vote_scores(contents) do
    contents |> Enum.sort(fn(a, b) -> a.vote_score > b.vote_score end)
  end
end
