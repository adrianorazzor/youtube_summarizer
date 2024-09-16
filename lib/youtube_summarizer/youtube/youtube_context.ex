defmodule YoutubeSummarizer.Youtube do
  @moduledoc """
  The Youtube context.
  """

  import Ecto.Query, warn: false

  alias YoutubeSummarizer.Youtube.Video
  alias YoutubeSummarizer.Youtube.Client
  require Logger

  def get_subtitle_text(url, language, conn) do
    Logger.debug("Getting subtitle text for URL: #{url}, language: #{language}")

    with {:ok, video_id} <- extract_video_id(url),
         {:ok, captions} <- Client.fetch_captions(video_id, conn),
         {:ok, caption_id} <- find_caption_id(captions, language),
         {:ok, subtitle_content} <- Client.fetch_subtitle_content(caption_id, conn) do
      subtitle_text = parse_srt(subtitle_content)
      {:ok, %Video{url: url, language: language, subtitle_text: subtitle_text}}
    else
      {:error, reason} ->
        Logger.error("Error getting subtitle text: #{inspect(reason)}")
        {:error, reason}
    end
  end

  defp extract_video_id(url) do
    case Regex.run(~r{(?:youtube\.com/watch\?v=|youtu\.be/)([^&\?]+)}, url) do
      [_, video_id] ->
        Logger.debug("Extracted video ID: #{video_id}")
        {:ok, video_id}
      _ ->
        Logger.error("Invalid YouTube URL: #{url}")
        {:error, "Invalid YouTube URL"}
    end
  end

  defp find_caption_id(captions, language) do
    Logger.debug("Finding caption ID for language: #{language}")
    Logger.debug("Captions: #{inspect(captions)}")

    case captions do
      %{"items" => items} when is_list(items) ->
        caption = Enum.find(items, fn item ->
          item["snippet"]["language"] == language
        end)

        case caption do
          nil ->
            Logger.error("No captions found for language: #{language}")
            {:error, "No captions found for the specified language"}
          caption ->
            Logger.debug("Found caption ID: #{caption["id"]}")
            {:ok, caption["id"]}
        end
      _ ->
        Logger.error("Unexpected captions format: #{inspect(captions)}")
        {:error, "Unexpected captions format: #{inspect(captions)}"}
    end
  end

  defp parse_srt(srt_content) do
   case srt_content do
    content when is_binary(content) ->
      content
      |> String.split("\n\n")
      |> Enum.map(fn block ->
        [_index, _timestamp | text] = String.split(block, "\n")
        Enum.join(text, " ")
      end)
      |> Enum.join(" ")
      |> String.trim()
    _ ->
      ""
   end
  end

end
