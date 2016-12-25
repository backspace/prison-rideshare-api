defmodule PrisonRideshare.User do
  use PrisonRideshare.Web, :model
  use Coherence.Schema

  schema "users" do
    field :name, :string
    field :email, :string
    field :admin, :boolean, default: false
    coherence_schema

    timestamps
  end

  def changeset(model, params \\ %{}) do
    model
    # FIXME this should be prevented 😬
    |> cast(params, [:name, :email, :admin] ++ coherence_fields)
    |> validate_required([:name, :email])
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:email)
    |> validate_coherence(params)
  end
end
