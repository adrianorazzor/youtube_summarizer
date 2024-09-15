defmodule YoutubeSummarizer.Youtube.Video do
  use Ecto.Schema
  import Ecto.Changeset

  schema "videos" do
    field :language, :string
    field :subtitle_text, :string
    field :url, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(video, attrs) do
    video
    |> cast(attrs, [:url, :language, :subtitle_text])
    |> validate_required([:url, :language, :subtitle_text])
  end
end
