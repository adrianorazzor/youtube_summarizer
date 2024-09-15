defmodule YoutubeSummarizer.SummarizationTest do
  use YoutubeSummarizer.DataCase

  alias YoutubeSummarizer.Summarization

  describe "summaries" do
    alias YoutubeSummarizer.Summarization.Summary

    import YoutubeSummarizer.SummarizationFixtures

    @invalid_attrs %{original_text: nil, summary_text: nil}

    test "list_summaries/0 returns all summaries" do
      summary = summary_fixture()
      assert Summarization.list_summaries() == [summary]
    end

    test "get_summary!/1 returns the summary with given id" do
      summary = summary_fixture()
      assert Summarization.get_summary!(summary.id) == summary
    end

    test "create_summary/1 with valid data creates a summary" do
      valid_attrs = %{original_text: "some original_text", summary_text: "some summary_text"}

      assert {:ok, %Summary{} = summary} = Summarization.create_summary(valid_attrs)
      assert summary.original_text == "some original_text"
      assert summary.summary_text == "some summary_text"
    end

    test "create_summary/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Summarization.create_summary(@invalid_attrs)
    end

    test "update_summary/2 with valid data updates the summary" do
      summary = summary_fixture()
      update_attrs = %{original_text: "some updated original_text", summary_text: "some updated summary_text"}

      assert {:ok, %Summary{} = summary} = Summarization.update_summary(summary, update_attrs)
      assert summary.original_text == "some updated original_text"
      assert summary.summary_text == "some updated summary_text"
    end

    test "update_summary/2 with invalid data returns error changeset" do
      summary = summary_fixture()
      assert {:error, %Ecto.Changeset{}} = Summarization.update_summary(summary, @invalid_attrs)
      assert summary == Summarization.get_summary!(summary.id)
    end

    test "delete_summary/1 deletes the summary" do
      summary = summary_fixture()
      assert {:ok, %Summary{}} = Summarization.delete_summary(summary)
      assert_raise Ecto.NoResultsError, fn -> Summarization.get_summary!(summary.id) end
    end

    test "change_summary/1 returns a summary changeset" do
      summary = summary_fixture()
      assert %Ecto.Changeset{} = Summarization.change_summary(summary)
    end
  end
end
