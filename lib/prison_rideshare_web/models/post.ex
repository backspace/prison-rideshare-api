defmodule PrisonRideshareWeb.Post do
  use PrisonRideshareWeb, :model

  schema "posts" do
    field(:content, :string)
    # Pre-Markdown mobiledoc, kept so the conversion can be undone. Not exposed
    # by the API and not writable through any changeset.
    field(:content_mobiledoc, :string)
    field(:readings, {:array, :binary_id}, default: [])
    belongs_to(:poster, PrisonRideshareWeb.User, foreign_key: :poster_id)

    timestamps(type: :naive_datetime)
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:content, :poster_id])
    |> validate_required([:content, :poster_id])
  end

  def readings_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:readings])
  end
end
