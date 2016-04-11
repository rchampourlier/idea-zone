defmodule IdeaZone.Admin.ContentTypeController do
  use IdeaZone.Web, :controller

  alias IdeaZone.ContentType

  plug :scrub_params, "content_type" when action in [:create, :update]

  def index(conn, _params) do
    content_types = Repo.all(ContentType)
    render(conn, "index.html", content_types: content_types)
  end

  def new(conn, _params) do
    changeset = ContentType.changeset(%ContentType{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"content_type" => content_type_params}) do
    changeset = ContentType.changeset(%ContentType{}, content_type_params)

    case Repo.insert(changeset) do
      {:ok, _content_type} ->
        conn
        |> put_flash(:info, "Content type created successfully.")
        |> redirect(to: admin_content_type_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    content_type = Repo.get!(ContentType, id)
    render(conn, "show.html", content_type: content_type)
  end

  def edit(conn, %{"id" => id}) do
    content_type = Repo.get!(ContentType, id)
    changeset = ContentType.changeset(content_type)
    render(conn, "edit.html", content_type: content_type, changeset: changeset)
  end

  def update(conn, %{"id" => id, "content_type" => content_type_params}) do
    content_type = Repo.get!(ContentType, id)
    changeset = ContentType.changeset(content_type, content_type_params)

    case Repo.update(changeset) do
      {:ok, content_type} ->
        conn
        |> put_flash(:info, "Content type updated successfully.")
        |> redirect(to: admin_content_type_path(conn, :show, content_type))
      {:error, changeset} ->
        render(conn, "edit.html", content_type: content_type, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    content_type = Repo.get!(ContentType, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(content_type)

    conn
    |> put_flash(:info, "Content type deleted successfully.")
    |> redirect(to: admin_content_type_path(conn, :index))
  end
end
