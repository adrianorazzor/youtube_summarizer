defmodule YoutubeSummarizerWeb.SummarizerLive do
  use YoutubeSummarizerWeb, :live_view

  alias YoutubeSummarizer.Youtube
  alias YoutubeSummarizer.Summarization

  def mount(_params, session, socket) do
    {:ok, assign(socket,
      url: "",
      language: "en",
      summary: nil,
      error: nil,
      user: session["user"],
      loading: false
    )}
  end


  def handle_event("summarize", %{"url" => url, "language" => language}, socket) do
    if socket.assigns.user do
      case Youtube.get_subtitle_text(url, language, socket) do
        {:ok, video} ->
          case Summarization.create_summary(video.subtitle_text) do
            {:ok, summary} ->
              {:noreply, assign(socket, summary: summary, error: nil)}
            {:error, reason} ->
              {:noreply, assign(socket, error: reason, summary: nil)}
          end
        {:error, reason} ->
          {:noreply, assign(socket, error: reason, summary: nil)}
      end
    else
      {:noreply, redirect(socket, to: "/auth/youtube")}
    end
  end

  def handle_event("regenerate", _, socket) do
    case Summarization.create_summary(socket.assigns.summary.original_text) do
      {:ok, summary} ->
        {:noreply, assign(socket, summary: summary, error: nil, loading: false)}
      {:error, reason} ->
        {:noreply, assign(socket, error: reason, loading: false)}
    end
  end

  def handle_event("expand", _, socket) do
    {:noreply, assign(socket, loading: true, error: nil)}

    case Summarization.expand_summary(socket.assigns.summary) do
      {:ok, expand_summary} ->
        {:noreply, assign(socket, summary: expand_summary, error: nil, loading: false)}
      {:error, reason} ->
        {:noreply, assign(socket, error: reason, loading: false)}
    end
  end
end
