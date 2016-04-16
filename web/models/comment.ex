defmodule IdeaZone.Comment do
  use IdeaZone.Web, :model

  schema "comments" do
    field :text, :string
    belongs_to :content, IdeaZone.Content

    timestamps
  end

  @required_fields ~w(content_id text)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end
