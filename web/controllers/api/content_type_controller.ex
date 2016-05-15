defmodule IdeaZone.API.ContentTypeController do
  use IdeaZone.Web, :controller

  alias IdeaZone.ContentType

  def index(conn, _params) do
    content_types = Repo.all(ContentType)
    conn
      |> assign(:content_types, content_types)
      |> render("index.json")
  end
end
