defmodule IdeaZone.API.ContentView do
  use IdeaZone.Web, :view

  def render("index.json", %{contents: contents}) do
    %{data: render_many(contents, IdeaZone.API.ContentView, "content.json")}
  end

  def render("show.json", %{content: content}) do
    %{data: render_one(content, IdeaZone.API.ContentView, "content.json")}
  end

  def render("content.json", %{content: content}) do
    %{id: content.id,
      label: content.label,
      description: content.description,
      officialAnswer: content.official_answer || "",
      status: content.status,
      type: content.type.label,
      voteScore: content.vote_score,
      voteForCurrentUser: content.vote_type_for_current_user}
  end
end
