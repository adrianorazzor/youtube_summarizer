defmodule YoutubeSummarizerWeb.SummarizerLive do
  use YoutubeSummarizerWeb, :live_view

  alias YoutubeSummarizer.Youtube
  alias YoutubeSummarizer.Summarization

  def mount(_params, _session, socket) do
    {:ok, assign(socket, url: "", languge: "en", summary: nil, error: nil)}
  end


  def handle_event("summarize", %{"url" => url, "language" => language}, socket)  do
    case Youtube.get_subtitle_text(url, language) do
      {:ok, video} ->
        case Summarization.create_summary(video.subtitle_text) do
          {:ok, summary} ->
            {:noreply, assign(socket, summary: summary, error: nil)}
          {:error, _changeset} ->
            {:noreply, assign(socket, error: "Failed to create summary", summary: nil)}
        end
      {:error, _changeset} ->
        {:noreply, assign(socket, error: "Failed to fetch subtitles", summary: nil)}
    end
  end

  def handle_event("regenerate", _, socket) do
    case Summarization.create_summary(socket.assigns.summary.original_text) do
      {:ok, summary} ->
        {:noreply, assign(socket, summary: summary, error: nil)}
      {:error, _changeset} ->
        {:noreply, assign(socket, error: "Failed to regenerate summary")}
    end
  end

  def handle_event("expand", _, socket) do
    case Summarization.expand_summary(socket.assigns.summary) do
      {:ok, expand_summary} ->
        {:noreply, assign(socket, summary: expand_summary, error: nil)}
      {:error, _} ->
        {:noreply, assign(socket, error: "Failed to expand summary")}
    end
  end
end
