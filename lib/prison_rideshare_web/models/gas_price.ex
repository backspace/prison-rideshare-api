defmodule PrisonRideshareWeb.GasPrice do
  use PrisonRideshareWeb, :model

  schema "gas_prices" do
    field(:price, Money.Ecto.Amount.Type)

    timestamps(type: :naive_datetime)
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:price])
    |> validate_required([:price])
  end
end
