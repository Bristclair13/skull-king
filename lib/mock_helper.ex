defmodule SkullKing.MockHelper do
  @moduledoc """
  Aliases the given module as a mock module if the application is in test mode.

  To use this macro first import the module and then call alias and mock.

  ```
  import SkullKing.MockHelper

  alias SkullKing.Users.Repo

  mock SkullKing.Users.Repo
  ```

  Then you can call the module as normal in your code and use mox/hammox in your tests.
  """
  defmacro mock({:__aliases__, ref, mod_parts}) do
    # inside macro so ok to use Mix.env()
    # credo:disable-for-next-line
    if Mix.env() == :test and System.get_env("DISABLE_MOCKS") != "true" do
      mock_module = {:__aliases__, ref, Enum.concat(mod_parts, [:Mock])}
      # convert atom to module
      alias_as = Module.safe_concat([List.last(mod_parts)])

      quote do
        alias unquote(mock_module), as: unquote(alias_as)
      end
    end
  end
end
