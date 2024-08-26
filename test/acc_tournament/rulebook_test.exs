defmodule AccTournament.RulebookTest do
  use AccTournament.DataCase

  alias AccTournament.Rulebook

  describe "doc_pages" do
    alias AccTournament.Rulebook.Page

    import AccTournament.RulebookFixtures

    @invalid_attrs %{title: nil, body: nil, slug: nil}

    test "list_doc_pages/0 returns all doc_pages" do
      page = page_fixture()
      assert Rulebook.list_doc_pages() == [page]
    end

    test "get_page!/1 returns the page with given id" do
      page = page_fixture()
      assert Rulebook.get_page!(page.id) == page
    end

    test "create_page/1 with valid data creates a page" do
      valid_attrs = %{title: "some title", body: "some body", slug: "some slug"}

      assert {:ok, %Page{} = page} = Rulebook.create_page(valid_attrs)
      assert page.title == "some title"
      assert page.body == "some body"
      assert page.slug == "some slug"
    end

    test "create_page/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Rulebook.create_page(@invalid_attrs)
    end

    test "update_page/2 with valid data updates the page" do
      page = page_fixture()
      update_attrs = %{title: "some updated title", body: "some updated body", slug: "some updated slug"}

      assert {:ok, %Page{} = page} = Rulebook.update_page(page, update_attrs)
      assert page.title == "some updated title"
      assert page.body == "some updated body"
      assert page.slug == "some updated slug"
    end

    test "update_page/2 with invalid data returns error changeset" do
      page = page_fixture()
      assert {:error, %Ecto.Changeset{}} = Rulebook.update_page(page, @invalid_attrs)
      assert page == Rulebook.get_page!(page.id)
    end

    test "delete_page/1 deletes the page" do
      page = page_fixture()
      assert {:ok, %Page{}} = Rulebook.delete_page(page)
      assert_raise Ecto.NoResultsError, fn -> Rulebook.get_page!(page.id) end
    end

    test "change_page/1 returns a page changeset" do
      page = page_fixture()
      assert %Ecto.Changeset{} = Rulebook.change_page(page)
    end
  end
end
