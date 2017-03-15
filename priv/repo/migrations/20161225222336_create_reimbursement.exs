defmodule PrisonRideshare.Repo.Migrations.CreateReimbursement do
  use Ecto.Migration

  def change do
    create table(:reimbursements, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :food_amount, :integer
      add :car_amount, :integer

      add :person_id, references(:people, on_delete: :nothing, type: :binary_id)
      add :ride_id, references(:rides, type: :binary_id)

      timestamps()
    end
    create index(:reimbursements, [:person_id])

  end
end
