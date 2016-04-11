defmodule IdeaZone.ContentStatusTest do
  use IdeaZone.ModelCase

  alias IdeaZone.ContentStatus

  @valid_attrs %{label: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = ContentStatus.changeset(%ContentStatus{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = ContentStatus.changeset(%ContentStatus{}, @invalid_attrs)
    refute changeset.valid?
  end
end
