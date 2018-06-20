defmodule PrisonRideshareWeb.GasPrice do
  use PrisonRideshareWeb, :model

  schema "gas_prices" do
    field(:price, Money.Ecto.Type)

    timestamps(type: :utc_datetime)
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:price])
    |> validate_required([:price])
  end
end
