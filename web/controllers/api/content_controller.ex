defmodule IdeaZone.API.ContentController do
  use IdeaZone.Web, :controller

  alias IdeaZone.Comment
  alias IdeaZone.Content
  alias IdeaZone.ContentStatus
  alias IdeaZone.ContentType
  alias IdeaZone.Vote

  import Ecto.Query, only: [from: 2]

  def index(conn, %{"filter" => filter}) do
    filter = "%#{filter}%"
    query = from c in Content,
      where: like(c.label, ^filter) or like(c.description, ^filter),
      select: c
    contents = query
      |> Repo.all
      |> Repo.preload([:status, :type])
    render(conn, "index.json", contents: contents)
  end

  def index(conn, _params) do
    contents = Content
      |> Repo.all
      |> Repo.preload([:status, :type])
    render(conn, "index.json", contents: contents)
  end
end
