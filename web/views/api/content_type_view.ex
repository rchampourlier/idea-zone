defmodule IdeaZone.API.ContentTypeView do
  use IdeaZone.Web, :view

  def render("index.json", %{content_types: content_types}) do
    %{data: render_many(content_types, IdeaZone.API.ContentTypeView, "content_type.json")}
  end

  def render("show.json", %{content_type: content_type}) do
    %{data: render_one(content_type, IdeaZone.API.ContentView, "content_type.json")}
  end

  def render("content_type.json", %{content_type: content_type}) do
    %{id: content_type.id,
      label: content_type.label
    }
  end
end
