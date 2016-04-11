# Virtual model (not-persisted) that handles the password submission
# to login as an admin.
#
# TODO:
#   - apply normal changeset validation to handle empty password error
#   - add password check as a standard changeset validation
defmodule IdeaZone.AdminSession do
  use IdeaZone.Web, :model

  schema "admin_sessions" do
    field :password, :string
  end

  @required_fields ~w(password)
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

  def verify_password(changeset) do
    submitted_password = changeset.changes.password
    expected_password = Application.get_env(:idea_zone, :admin_password)
    if submitted_password == expected_password do
      {:ok, nil}
    else
      {:error, "Wrong password!"}
    end
  end
end
