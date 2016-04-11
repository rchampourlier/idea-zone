defmodule IdeaZone.ContentTypeControllerTest do
  use IdeaZone.ConnCase

  alias IdeaZone.ContentType
  @valid_attrs %{label: "some content"}
  @invalid_attrs %{}

  setup do
    conn = conn()
    {:ok, conn: conn}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, admin_content_type_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing content types"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, admin_content_type_path(conn, :new)
    assert html_response(conn, 200) =~ "New content type"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, admin_content_type_path(conn, :create), content_type: @valid_attrs
    assert redirected_to(conn) == admin_content_type_path(conn, :index)
    assert Repo.get_by(ContentType, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, admin_content_type_path(conn, :create), content_type: @invalid_attrs
    assert html_response(conn, 200) =~ "New content type"
  end

  test "shows chosen resource", %{conn: conn} do
    content_type = Repo.insert! %ContentType{}
    conn = get conn, admin_content_type_path(conn, :show, content_type)
    assert html_response(conn, 200) =~ "Show content type"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_raise Ecto.NoResultsError, fn ->
      get conn, admin_content_type_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    content_type = Repo.insert! %ContentType{}
    conn = get conn, admin_content_type_path(conn, :edit, content_type)
    assert html_response(conn, 200) =~ "Edit content type"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    content_type = Repo.insert! %ContentType{}
    conn = put conn, admin_content_type_path(conn, :update, content_type), content_type: @valid_attrs
    assert redirected_to(conn) == admin_content_type_path(conn, :show, content_type)
    assert Repo.get_by(ContentType, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    content_type = Repo.insert! %ContentType{}
    conn = put conn, admin_content_type_path(conn, :update, content_type), content_type: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit content type"
  end

  test "deletes chosen resource", %{conn: conn} do
    content_type = Repo.insert! %ContentType{}
    conn = delete conn, admin_content_type_path(conn, :delete, content_type)
    assert redirected_to(conn) == admin_content_type_path(conn, :index)
    refute Repo.get(ContentType, content_type.id)
  end
end
