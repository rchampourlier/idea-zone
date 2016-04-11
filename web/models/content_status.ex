defmodule IdeaZone.ContentStatus do
  use IdeaZone.Web, :model

  schema "content_statuses" do
    field :label, :string
    field :default, :boolean

    timestamps
  end

  @required_fields ~w(label default)
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
