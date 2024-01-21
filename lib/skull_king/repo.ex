defmodule SkullKing.Repo do
  use Ecto.Repo,
    otp_app: :skull_king,
    adapter: Ecto.Adapters.Postgres
end
