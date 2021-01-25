defmodule ExTypeStruct do
  @moduledoc false

  @doc false
  defmacro __using__(do: {:__block__, _, block}) do
    parse_block(block, __CALLER__)
  end

  # handle do block with only 1 expression
  defmacro __using__(do: expr) do
    parse_block([expr], __CALLER__)
  end

  defmacro __using__(expr) do
    raise ArgumentError,
          "Invalid argument: must be `do ... end` instead of `#{Macro.to_string(expr)}` #{
            format_error_context(__CALLER__)
          }"
  end

  defp parse_block(block, caller) do
    {type_kind, type_name_and_params, rest} = parse_type_head(block)

    {enforce_keys, fields, types} = parse_type_fields(rest, caller)

    quote do
      @enforce_keys unquote(enforce_keys)
      defstruct unquote(fields)

      @unquote(type_kind)(
        unquote(type_name_and_params) :: %__MODULE__{
          unquote_splicing(types)
        }
      )
    end
  end

  defp parse_type_head([{:@, _, [{type_kind, _, [type_name_and_params]}]} | rest])
       when type_kind in [:type, :typep, :opaque] do
    {type_kind, type_name_and_params, rest}
  end

  # default type head is `@type t() :: ...`
  defp parse_type_head(rest) do
    {:type, quote(do: t()), rest}
  end

  defp parse_type_fields([], _caller) do
    {[], [], []}
  end

  # handle optional field: `name :: type \\ default_value`
  defp parse_type_fields(
         [{:\\, _, [{:"::", _, [{name, _, ctx}, type]}, default_expr]} | rest],
         caller
       )
       when is_atom(name) and is_atom(ctx) do
    {enforce_keys, fields, types} = parse_type_fields(rest, caller)

    {enforce_keys, [{name, default_expr} | fields], [{name, type} | types]}
  end

  # handle required field: `name :: type`
  defp parse_type_fields([{:"::", _, [{name, _, ctx}, type]} | rest], caller)
       when is_atom(name) and is_atom(ctx) do
    {enforce_keys, fields, types} = parse_type_fields(rest, caller)

    {[name | enforce_keys], [{name, nil} | fields], [{name, type} | types]}
  end

  defp parse_type_fields([invalid_expr | _rest], caller) do
    raise ArgumentError,
          "Invalid expression: `#{Macro.to_string(invalid_expr)}` #{format_error_context(caller)}"
  end

  defp format_error_context(caller) do
    "when use ExTypeStruct in module #{caller.module} in file #{caller.file}:#{caller.line}."
  end
end
