defmodule IdeaZone.Content do
  use IdeaZone.Web, :model

  schema "contents" do
    field :label, :string
    field :description, :string
    belongs_to :type, IdeaZone.ContentType
    belongs_to :status, IdeaZone.ContentStatus

    timestamps
  end

  @required_fields ~w(label description type_id status_id)
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
