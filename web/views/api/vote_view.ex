defmodule IdeaZone.API.VoteView do
  use IdeaZone.Web, :view

  def render("show.json", %{vote: vote}) do
    %{status: "ok",
      data: render_one(vote, IdeaZone.API.VoteView, "vote.json")}
  end

  def render("vote.json", %{vote: vote}) do
    %{id: vote.id,
      contentId: vote.content_id,
      userSessionToken: vote.user_session_token,
      voteType: vote.vote_type}
  end

  def render("error.json", %{messages: messages}) do
    %{status: "error",
      errors: messages}
  end
  def render("error.json", %{changeset: changeset}) do
    %{status: "error",
      errors: changeset}
  end
end
