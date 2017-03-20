defmodule PrisonRideshare.Repo.Migrations.CreateReimbursement do
  use Ecto.Migration

  def change do
    create table(:reimbursements, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :food_expenses, :integer
      add :car_expenses, :integer

      add :person_id, references(:people, on_delete: :nothing, type: :binary_id)
      add :ride_id, references(:rides, type: :binary_id)

      add :donation, :boolean, default: false
      add :processed, :boolean, default: false

      timestamps()
    end
    create index(:reimbursements, [:person_id])

  end
end
