defmodule SkullKing.Users.User do
  use Ecto.Schema

  import Ecto.Changeset

  alias SkullKing.Users.User

  @type t :: %__MODULE__{
          name: String.t(),
          google_id: String.t()
        }

  @primary_key {:id, UXID, autogenerate: true, prefix: "users"}
  schema "users" do
    field :name, :string
    field :google_id, :string

    timestamps()
  end

  def changeset(%User{} = user, params) do
    user
    |> cast(params, [:name, :google_id])
    |> validate_required([:name, :google_id])
    |> unique_constraint(:google_id)
  end
end
