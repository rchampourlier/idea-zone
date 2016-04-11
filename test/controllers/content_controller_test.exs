defmodule IdeaZone.ContentControllerTest do
  use IdeaZone.ConnCase

  alias IdeaZone.Content
  @valid_attrs %{description: "some content", label: "some content"}
  @invalid_attrs %{}

  setup do
    conn = conn()
    {:ok, conn: conn}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, content_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing contents"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, content_path(conn, :new)
    assert html_response(conn, 200) =~ "New content"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, content_path(conn, :create), content: @valid_attrs
    assert redirected_to(conn) == content_path(conn, :index)
    assert Repo.get_by(Content, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, content_path(conn, :create), content: @invalid_attrs
    assert html_response(conn, 200) =~ "New content"
  end

  test "shows chosen resource", %{conn: conn} do
    content = Repo.insert! %Content{}
    conn = get conn, content_path(conn, :show, content)
    assert html_response(conn, 200) =~ "Show content"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_raise Ecto.NoResultsError, fn ->
      get conn, content_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    content = Repo.insert! %Content{}
    conn = get conn, content_path(conn, :edit, content)
    assert html_response(conn, 200) =~ "Edit content"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    content = Repo.insert! %Content{}
    conn = put conn, content_path(conn, :update, content), content: @valid_attrs
    assert redirected_to(conn) == content_path(conn, :show, content)
    assert Repo.get_by(Content, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    content = Repo.insert! %Content{}
    conn = put conn, content_path(conn, :update, content), content: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit content"
  end

  test "deletes chosen resource", %{conn: conn} do
    content = Repo.insert! %Content{}
    conn = delete conn, content_path(conn, :delete, content)
    assert redirected_to(conn) == content_path(conn, :index)
    refute Repo.get(Content, content.id)
  end
end
