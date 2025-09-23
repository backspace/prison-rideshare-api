defmodule PrisonRideshare.Repo.Migrations.AddRideGasPrice do
  use Ecto.Migration

  def change do
    alter table(:rides) do
      add(:gas_price_id, references(:gas_prices, type: :binary_id))
    end
  end
end
