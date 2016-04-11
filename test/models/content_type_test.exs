defmodule IdeaZone.ContentTypeTest do
  use IdeaZone.ModelCase

  alias IdeaZone.ContentType

  @valid_attrs %{label: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = ContentType.changeset(%ContentType{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = ContentType.changeset(%ContentType{}, @invalid_attrs)
    refute changeset.valid?
  end
end
