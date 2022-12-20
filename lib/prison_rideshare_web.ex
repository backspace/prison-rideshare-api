defmodule PrisonRideshareWeb do
  @moduledoc """
  A module that keeps using definitions for controllers,
  views and so on.

  This can be used in your application as:

      use PrisonRideshareWeb, :controller
      use PrisonRideshareWeb, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below.
  """

  def model do
    quote do
      use Ecto.Schema

      import Ecto
      import Ecto.Changeset
      import Ecto.Query

      @primary_key {:id, :binary_id, autogenerate: true}
      @foreign_key_type :binary_id
    end
  end

  def controller do
    quote do
      use Phoenix.Controller, namespace: PrisonRideshareWeb

      alias PrisonRideshare.Repo
      import Ecto
      import Ecto.Query

      alias PrisonRideshareWeb.Router.Helpers, as: Routes
      import PrisonRideshareWeb.Gettext

      import PrisonRideshare.VersionInformation
    end
  end

  def view do
    quote do
      use Phoenix.View,
        root: "lib/prison_rideshare_web/templates",
        namespace: PrisonRideshareWeb

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [get_csrf_token: 0, get_flash: 2, view_module: 1]

      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      import PrisonRideshareWeb.Router.Helpers
      import PrisonRideshareWeb.ErrorHelpers
      import PrisonRideshareWeb.Gettext

      import PrisonRideshareWeb.MoneyHelper
    end
  end

  def router do
    quote do
      use Phoenix.Router
    end
  end

  def channel do
    quote do
      use Phoenix.Channel

      alias PrisonRideshare.Repo
      import Ecto
      import Ecto.Query
      import PrisonRideshareWeb.Gettext
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
