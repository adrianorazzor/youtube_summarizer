defmodule YoutubeSummarizer.Summarization do
  @moduledoc """
  The Summarization context.
  """

  import Ecto.Query, warn: false
  alias YoutubeSummarizer.Repo

  alias YoutubeSummarizer.Summarization.Summary

  def list_summaries do
    Repo.all(Summary)
  end

  def get_summary!(id), do: Repo.get!(Summary, id)

  def update_summary(%Summary{} = summary, attrs) do
    summary
    |> Summary.changeset(attrs)
    |> Repo.update()
  end


  def delete_summary(%Summary{} = summary) do
    Repo.delete(summary)
  end

  def change_summary(%Summary{} = summary, attrs \\ %{}) do
    Summary.changeset(summary, attrs)
  end

  @doc """
  Creates a summary for the given text.
  """
  def create_summary(text) do
   case YoutubeSummarizer.Summarization.Client.summarize(text) do
    {:ok, summary_text} ->
      %Summary{}
      |> Summary.changeset(%{original_text: text, summary_text: summary_text})
      |> Ecto.Changeset.apply_action(:insert)
    {:error, reason} ->
      {:error, reason}
   end
  end

  @doc """
  Expands the given summary.
  """
  def expand_summary(%Summary{} = summary) do
    case YoutubeSummarizer.Summarization.Client.expand(summary.summary_text) do
      {:ok, expandex_text} ->
        {:ok, %{summary | summary_text: expandex_text}}
      {:error, reason} ->
        {:error, reason}
    end
  end
end
