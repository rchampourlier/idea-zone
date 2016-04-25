# Ensure the request is made by a logged in admin.
# This is just done by checking the value of the
# session's "admin" boolean attribute.
#
# It's not secure since it's stored in the cookie, but at
# least Phoenix ensures the cookie's data is somehow
# ciphered.
defmodule IdeaZone.Plugs.EnsureAdmin do
  require IEx
  import Plug.Conn
  alias Phoenix.Controller

  def init(default), do: default

  def call(conn, _default) do
    if get_session(conn, :admin) do
      links = [
        %{title: "Contents", href: "/admin/contents"},
        %{title: "Content types", href: "/admin/content_types"},
        %{title: "Disconnect", href: "/admin/logout"}
      ]
      conn |> assign(:links, links)
    else
      conn
        |> Controller.put_flash(:error, "You must be logged in as an admin to access this page!")
        |> Controller.redirect(to: "/admin/login")
    end
  end
end
