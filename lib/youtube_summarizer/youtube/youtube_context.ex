defmodule YoutubeSummarizer.Youtube do
  @moduledoc """
  The Youtube context.
  """

  import Ecto.Query, warn: false
  alias YoutubeSummarizer.Repo

  alias YoutubeSummarizer.Youtube.Video
  alias YoutubeSummarizer.Youtube.Client


  def list_videos do
    Repo.all(Video)
  end


  def get_video!(id), do: Repo.get!(Video, id)


  def create_video(attrs \\ %{}) do
    %Video{}
    |> Video.changeset(attrs)
    |> Repo.insert()
  end


  def update_video(%Video{} = video, attrs) do
    video
    |> Video.changeset(attrs)
    |> Repo.update()
  end


  def delete_video(%Video{} = video) do
    Repo.delete(video)
  end

  def change_video(%Video{} = video, attrs \\ %{}) do
    Video.changeset(video, attrs)
  end

  def get_subtitle_text(url, language) do
    with {:ok, subtitle_text} <- Client.fetch_subtitles(url, language) do
      %Video{}
      |> Video.changeset(%{url: url, language: language, subtitle_text: subtitle_text})
      |> Ecto.Changeset.apply_action(:insert)
    end
  end
end
