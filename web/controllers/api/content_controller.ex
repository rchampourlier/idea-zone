defmodule IdeaZone.API.ContentController do
  use IdeaZone.Web, :controller
  alias IdeaZone.Content

  import Ecto.Query, only: [from: 2]

  def index(conn, %{"filter" => ""}) do
    contents = Content
      |> Repo.all
      |> Repo.preload([:status, :type])
    render(conn, "index.json", contents: contents)
  end
  def index(conn, %{"filter" => filter}) do
    search_terms = filter |> String.split(" ")
    contents = Content.search(search_terms) |> Repo.preload([:status, :type])
    render(conn, "index.json", contents: contents)
  end

  def index(conn, _params) do
    contents = Content
      |> Repo.all
      |> Repo.preload([:status, :type])
    render(conn, "index.json", contents: contents)
  end
end
