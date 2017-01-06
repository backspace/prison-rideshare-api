defmodule PrisonRideshare.UserView do
  use PrisonRideshare.Web, :view

  def render("index.json", %{users: users}) do
    %{data: render_many(users, PrisonRideshare.UserView, "user.json")}
  end

  def render("show.json", %{user: user}) do
    %{data: render_one(user, PrisonRideshare.UserView, "user.json")}
  end

  def render("user.json", %{user: user}) do
    %{
    	"type": "user",
    	"id": user.id,
    	"attributes": %{
    		"email": user.email
    	}
    }
  end
end
