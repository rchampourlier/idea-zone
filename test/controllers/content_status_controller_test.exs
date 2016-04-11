defmodule IdeaZone.ContentStatusControllerTest do
  use IdeaZone.ConnCase

  alias IdeaZone.ContentStatus
  @valid_attrs %{label: "some content"}
  @invalid_attrs %{}

  setup do
    conn = conn()
    {:ok, conn: conn}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, admin_content_status_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing content statuses"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, admin_content_status_path(conn, :new)
    assert html_response(conn, 200) =~ "New content status"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, admin_content_status_path(conn, :create), content_status: @valid_attrs
    assert redirected_to(conn) == admin_content_status_path(conn, :index)
    assert Repo.get_by(ContentStatus, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, admin_content_status_path(conn, :create), content_status: @invalid_attrs
    assert html_response(conn, 200) =~ "New content status"
  end

  test "shows chosen resource", %{conn: conn} do
    content_status = Repo.insert! %ContentStatus{}
    conn = get conn, admin_content_status_path(conn, :show, content_status)
    assert html_response(conn, 200) =~ "Show content status"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_raise Ecto.NoResultsError, fn ->
      get conn, admin_content_status_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    content_status = Repo.insert! %ContentStatus{}
    conn = get conn, admin_content_status_path(conn, :edit, content_status)
    assert html_response(conn, 200) =~ "Edit content status"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    content_status = Repo.insert! %ContentStatus{}
    conn = put conn, admin_content_status_path(conn, :update, content_status), content_status: @valid_attrs
    assert redirected_to(conn) == admin_content_status_path(conn, :show, content_status)
    assert Repo.get_by(ContentStatus, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    content_status = Repo.insert! %ContentStatus{}
    conn = put conn, admin_content_status_path(conn, :update, content_status), content_status: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit content status"
  end

  test "deletes chosen resource", %{conn: conn} do
    content_status = Repo.insert! %ContentStatus{}
    conn = delete conn, admin_content_status_path(conn, :delete, content_status)
    assert redirected_to(conn) == admin_content_status_path(conn, :index)
    refute Repo.get(ContentStatus, content_status.id)
  end
end
