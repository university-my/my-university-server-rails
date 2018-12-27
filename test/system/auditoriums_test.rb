require "application_system_test_case"

class AuditoriumsTest < ApplicationSystemTestCase
  setup do
    @auditoriums = auditoriums(:one)
  end

  test "visiting the index" do
    visit auditoriums_url
    assert_selector "h1", text: "auditoriums"
  end

  test "creating a Auditorium" do
    visit auditoriums_url
    click_on "New Auditorium"

    fill_in "Name", with: @auditorium.name
    click_on "Create Auditorium"

    assert_text "Auditorium was successfully created"
    click_on "Back"
  end

  test "updating a Auditorium" do
    visit auditoriums_url
    click_on "Edit", match: :first

    fill_in "Name", with: @auditorium.name
    click_on "Update Auditorium"

    assert_text "Auditorium was successfully updated"
    click_on "Back"
  end

  test "destroying a Auditorium" do
    visit auditoriums_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Auditorium was successfully destroyed"
  end
end
