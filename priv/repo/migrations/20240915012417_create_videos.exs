defmodule YoutubeSummarizer.Repo.Migrations.CreateVideos do
  use Ecto.Migration

  def change do
    create table(:videos) do
      add :url, :string
      add :language, :string
      add :subtitle_text, :text

      timestamps(type: :utc_datetime)
    end
  end
end
