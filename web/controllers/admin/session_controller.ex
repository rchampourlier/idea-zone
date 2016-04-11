defmodule IdeaZone.Admin.SessionController do
  require IEx
  use IdeaZone.Web, :controller

  alias IdeaZone.AdminSession

  plug :scrub_params, "admin_session" when action in [:create]

  def new(conn, _params) do
    conn
      |> assign(:changeset, AdminSession.changeset(%AdminSession{}))
      |> render("new.html")
  end

  def create(conn, %{"admin_session" => admin_session_params}) do
    changeset = AdminSession.changeset(%AdminSession{}, admin_session_params)

    case AdminSession.verify_password(changeset) do
      {:ok, _message} ->
        conn
          |> put_session(:admin, true)
          |> put_flash(:info, "Successfully logged in.")
          |> redirect(to: admin_content_path(conn, :index))
      {:error, message} ->
        conn
          |> assign(:changeset, changeset)
          |> put_flash(:error, message)
          |> render("new.html")
    end
  end

  # GET /admin/logout
  def delete(conn, _params) do
    conn
      |> put_session(:admin, nil)
      |> put_flash(:info, "Successfully logged out.")
      |> redirect(to: content_path(conn, :index))
  end
end
