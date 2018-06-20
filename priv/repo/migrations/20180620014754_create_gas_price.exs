defmodule PrisonRideshare.Repo.Migrations.CreateGasPrice do
  use Ecto.Migration

  def change do
    create table(:gas_prices, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:price, :integer)

      timestamps()
    end
  end
end
