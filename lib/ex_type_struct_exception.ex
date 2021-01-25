defmodule ExTypeStruct.Exception do
  @moduledoc false

  @doc false
  defmacro __using__(do: {:__block__, _, block}) do
    ExTypeStruct.parse_block(block, __CALLER__, :defexception)
  end

  # handle do block with only 1 expression
  defmacro __using__(do: expr) do
    ExTypeStruct.parse_block([expr], __CALLER__, :defexception)
  end

  defmacro __using__(expr) do
    raise ArgumentError,
          "Invalid argument: must be `do ... end` instead of `#{Macro.to_string(expr)}` #{
            ExTypeStruct.format_error_context(__CALLER__, __MODULE__)
          }"
  end
end
