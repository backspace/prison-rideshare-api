defmodule PrisonRideshare.Repo.Migrations.AddLastSeenAtToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :last_seen_at, :naive_datetime, default: fragment("to_timestamp(0)")
    end

    execute("""
    UPDATE users
    SET last_seen_at = subquery.max_inserted_at
    FROM (
      SELECT users.id, MAX(versions.inserted_at) as max_inserted_at
      FROM users
      JOIN versions ON versions.originator_id = users.id
      GROUP BY users.id
    ) AS subquery
    WHERE users.id = subquery.id
    """, "")
  end
end
