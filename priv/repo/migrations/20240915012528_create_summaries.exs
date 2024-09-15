defmodule YoutubeSummarizer.Repo.Migrations.CreateSummaries do
  use Ecto.Migration

  def change do
    create table(:summaries) do
      add :original_text, :text
      add :summary_text, :text

      timestamps(type: :utc_datetime)
    end
  end
end
