defmodule YoutubeSummarizer.YoutubeTest do
  use YoutubeSummarizer.DataCase

  alias YoutubeSummarizer.Youtube

  describe "videos" do
    alias YoutubeSummarizer.Youtube.Video

    import YoutubeSummarizer.YoutubeFixtures

    @invalid_attrs %{language: nil, subtitle_text: nil, url: nil}

    test "list_videos/0 returns all videos" do
      video = video_fixture()
      assert Youtube.list_videos() == [video]
    end

    test "get_video!/1 returns the video with given id" do
      video = video_fixture()
      assert Youtube.get_video!(video.id) == video
    end

    test "create_video/1 with valid data creates a video" do
      valid_attrs = %{language: "some language", subtitle_text: "some subtitle_text", url: "some url"}

      assert {:ok, %Video{} = video} = Youtube.create_video(valid_attrs)
      assert video.language == "some language"
      assert video.subtitle_text == "some subtitle_text"
      assert video.url == "some url"
    end

    test "create_video/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Youtube.create_video(@invalid_attrs)
    end

    test "update_video/2 with valid data updates the video" do
      video = video_fixture()
      update_attrs = %{language: "some updated language", subtitle_text: "some updated subtitle_text", url: "some updated url"}

      assert {:ok, %Video{} = video} = Youtube.update_video(video, update_attrs)
      assert video.language == "some updated language"
      assert video.subtitle_text == "some updated subtitle_text"
      assert video.url == "some updated url"
    end

    test "update_video/2 with invalid data returns error changeset" do
      video = video_fixture()
      assert {:error, %Ecto.Changeset{}} = Youtube.update_video(video, @invalid_attrs)
      assert video == Youtube.get_video!(video.id)
    end

    test "delete_video/1 deletes the video" do
      video = video_fixture()
      assert {:ok, %Video{}} = Youtube.delete_video(video)
      assert_raise Ecto.NoResultsError, fn -> Youtube.get_video!(video.id) end
    end

    test "change_video/1 returns a video changeset" do
      video = video_fixture()
      assert %Ecto.Changeset{} = Youtube.change_video(video)
    end
  end
end
