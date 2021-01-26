defmodule ExTypeStruct do
  @moduledoc false

  defmacro __using__(expr) do
    handle_do_block(__MODULE__, __CALLER__, :defstruct, expr)
  end

  defmodule Exception do
    @moduledoc false

    defmacro __using__(expr) do
      ExTypeStruct.handle_do_block(__MODULE__, __CALLER__, :defexception, expr)
    end
  end

  @doc false

  def handle_do_block(module, caller, def_kind, do: {:__block__, _, block}) do
    parse_block(block, module, caller, def_kind)
  end

  # handle do block with only 1 expression
  def handle_do_block(module, caller, def_kind, do: expr) do
    parse_block([expr], module, caller, def_kind)
  end

  def handle_do_block(module, caller, _def_kind, expr) do
    raise ArgumentError,
          "Invalid argument: must be `do ... end` instead of `#{Macro.to_string(expr)}` #{
            format_error_context(caller, module)
          }"
  end

  defp parse_block(block, module, caller, def_kind) do
    {type_kind, type_name_and_params, rest} = parse_type_head(block)

    {enforce_keys, fields, types} = parse_type_fields(rest, module, caller)

    quote do
      @enforce_keys unquote(enforce_keys)
      unquote(def_kind)(unquote(fields))

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

  defp parse_type_fields([], _module, _caller) do
    {[], [], []}
  end

  # handle optional field: `name :: type \\ default_value`
  defp parse_type_fields(
         [{:\\, _, [{:"::", _, [{name, _, ctx}, type]}, default_expr]} | rest],
         module,
         caller
       )
       when is_atom(name) and is_atom(ctx) do
    {enforce_keys, fields, types} = parse_type_fields(rest, module, caller)

    {enforce_keys, [{name, default_expr} | fields], [{name, type} | types]}
  end

  # handle required field: `name :: type`
  defp parse_type_fields([{:"::", _, [{name, _, ctx}, type]} | rest], module, caller)
       when is_atom(name) and is_atom(ctx) do
    {enforce_keys, fields, types} = parse_type_fields(rest, module, caller)

    {[name | enforce_keys], [{name, nil} | fields], [{name, type} | types]}
  end

  defp parse_type_fields([invalid_expr | _rest], module, caller) do
    raise ArgumentError,
          "Invalid expression: `#{Macro.to_string(invalid_expr)}` #{
            format_error_context(caller, module)
          }"
  end

  defp format_error_context(caller, module) do
    "when use #{inspect(module)} within module #{inspect(caller.module)} in file #{caller.file}:#{
      caller.line
    }."
  end
end
