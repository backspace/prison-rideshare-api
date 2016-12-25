defmodule PrisonRideshare.Repo.Migrations.CreateReimbursement do
  use Ecto.Migration

  def change do
    create table(:reimbursements, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :amount, :integer
      add :person_id, references(:people, on_delete: :nothing, type: :binary_id)

      timestamps()
    end
    create index(:reimbursements, [:person_id])

  end
end
