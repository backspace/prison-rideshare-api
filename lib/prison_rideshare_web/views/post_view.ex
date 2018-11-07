defmodule PrisonRideshareWeb.PostView do
  use PrisonRideshareWeb, :view
  use JaSerializer.PhoenixView

  attributes([
    :content,
    :unread,
    :inserted_at,
    :updated_at
  ])

  has_one(
    :poster,
    type: "user",
    include: true,
    serializer: PrisonRideshareWeb.UserView
  )

  def unread(post, conn) do
    resource = Guardian.Plug.current_resource(conn)

    user =
      case resource do
        %PrisonRideshareWeb.User{} -> resource
        _ -> %{}
      end

    user.id not in (post.readings || [])
  end
end
