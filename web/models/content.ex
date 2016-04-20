defmodule IdeaZone.Content do
  use IdeaZone.Web, :model
  alias IdeaZone.Repo

  schema "contents" do
    field :label, :string
    field :description, :string
    field :language, :string

    belongs_to :status, IdeaZone.ContentStatus
    belongs_to :type, IdeaZone.ContentType

    has_many :comments, IdeaZone.Comment
    has_many :votes, IdeaZone.Vote

    timestamps
  end

  @required_fields ~w(label description language type_id status_id)
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

  # Query built using this article as a guide:
  # http://rachbelaid.com/postgres-full-text-search-is-good-enough/
  #
  # TODO: optimisation / indexing
  # TODO: generalize Ecto custom SQL queries (see http://stackoverflow.com/questions/27751216/how-to-use-raw-sql-with-ecto-repo)
  #
  # @param search_terms [Array of String]
  def search(search_terms) do
    fields = ["id"] ++ @required_fields ++ @optional_fields |> Enum.join(", ")
    sql_terms = search_terms |> Enum.join(" & ")
    query = """
SELECT
  #{fields},
  ts_rank(c_search.documents, to_tsquery('fr', '#{sql_terms}')) AS rank
FROM (
  SELECT
    *,
    setweight(to_tsvector(contents.language::regconfig, contents.label), 'A') || setweight(to_tsvector(contents.language::regconfig, contents.description), 'B') AS documents
  FROM contents
) c_search
WHERE ts_rank(c_search.documents, to_tsquery('fr', '#{sql_terms}')) <> 0
ORDER BY ts_rank(c_search.documents, to_tsquery('fr', '#{sql_terms}')) DESC
LIMIT 10;
    """
    { :ok, response } = Ecto.Adapters.SQL.query(Repo, query, [])
    Enum.map(response.rows, fn(row) ->
      fields = Enum.reduce(
        Enum.zip(response.columns, row), %{}, fn({key, value}, map) ->
          Map.put(map, key, value)
        end)
      Ecto.Schema.__load__(__MODULE__, nil, nil, [], fields, &Repo.__adapter__.load/2)
    end)
  end
end
