defmodule IdeaZone.Admin.ContentStatusController do
  require IEx
  use IdeaZone.Web, :controller

  alias IdeaZone.ContentStatus

  plug :scrub_params, "content_status" when action in [:create, :update]

  def index(conn, _params) do
    content_statuses = Repo.all(ContentStatus)
    render(conn, "index.html", content_statuses: content_statuses)
  end

  def new(conn, _params) do
    changeset = ContentStatus.changeset(%ContentStatus{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"content_status" => content_status_params}) do
    changeset = ContentStatus.changeset(%ContentStatus{}, content_status_params)

    case Repo.insert(changeset) do
      {:ok, _content_status} ->
        conn
        |> put_flash(:info, "Content status created successfully.")
        |> redirect(to: admin_content_status_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    content_status = Repo.get!(ContentStatus, id)
    render(conn, "show.html", content_status: content_status)
  end

  def edit(conn, %{"id" => id}) do
    content_status = Repo.get!(ContentStatus, id)
    changeset = ContentStatus.changeset(content_status)
    render(conn, "edit.html", content_status: content_status, changeset: changeset)
  end

  def update(conn, %{"id" => id, "content_status" => content_status_params}) do
    content_status = Repo.get!(ContentStatus, id)
    changeset = ContentStatus.changeset(content_status, content_status_params)

    case Repo.update(changeset) do
      {:ok, content_status} ->
        conn
        |> put_flash(:info, "Content status updated successfully.")
        |> redirect(to: admin_content_status_path(conn, :show, content_status))
      {:error, changeset} ->
        render(conn, "edit.html", content_status: content_status, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    content_status = Repo.get!(ContentStatus, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(content_status)

    conn
    |> put_flash(:info, "Content status deleted successfully.")
    |> redirect(to: admin_content_status_path(conn, :index))
  end
end
