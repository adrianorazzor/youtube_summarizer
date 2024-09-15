defmodule YoutubeSummarizer.Summarization.Summary do
  use Ecto.Schema
  import Ecto.Changeset

  schema "summaries" do
    field :original_text, :string
    field :summary_text, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(summary, attrs) do
    summary
    |> cast(attrs, [:original_text, :summary_text])
    |> validate_required([:original_text, :summary_text])
  end
end
