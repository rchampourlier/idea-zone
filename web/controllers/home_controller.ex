defmodule IdeaZone.HomeController do
  use IdeaZone.Web, :controller

  def show(conn, _params) do
    conn |> redirect(to: content_path(conn, :index))
  end
end
