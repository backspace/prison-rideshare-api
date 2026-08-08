defmodule PrisonRideshare.Repo.Migrations.AddPostsContentMobiledoc do
  use Ecto.Migration

  # Retains the pre-conversion mobiledoc so the Markdown migration is reversible.
  def change do
    alter table(:posts) do
      add(:content_mobiledoc, :text)
    end
  end
end
