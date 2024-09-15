defmodule YoutubeSummarizer.Repo do
  use Ecto.Repo,
    otp_app: :youtube_summarizer,
    adapter: Ecto.Adapters.Postgres
end
