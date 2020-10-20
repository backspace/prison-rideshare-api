defmodule PrisonRideshareWeb.User do
  use PrisonRideshareWeb, :model

  schema "users" do
    field(:email, :string)
    field(:password_hash, :string)

    field(:admin, :boolean)

    field(:password, :string, virtual: true)
    field(:password_confirmation, :string, virtual: true)

    timestamps(type: :utc_datetime)
    field(:last_seen_at, :naive_datetime)
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:email, :password, :password_confirmation])
    |> validate_required([:email, :password, :password_confirmation])
    |> validate_format(:email, ~r/@/)
    |> validate_length(:password, min: 8)
    |> validate_confirmation(:password)
    |> hash_password
    |> unique_constraint(:email)
  end

  def password_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:password, :password_confirmation])
    |> validate_required([:password, :password_confirmation])
    |> validate_length(:password, min: 8)
    |> validate_confirmation(:password)
    |> hash_password
  end

  def admin_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:admin])
  end

  defp hash_password(%{valid?: false} = changeset), do: changeset

  defp hash_password(%{valid?: true} = changeset) do
    hashedpw = Comeonin.Bcrypt.hashpwsalt(Ecto.Changeset.get_field(changeset, :password))

    Ecto.Changeset.put_change(changeset, :password_hash, hashedpw)
    |> Ecto.Changeset.put_change(:password, nil)
    |> Ecto.Changeset.put_change(:password_confirmation, nil)
  end
end
