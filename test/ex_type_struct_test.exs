defmodule ExTypeStructTest do
  use ExUnit.Case

  describe "struct with 0 expr" do
    defmodule EmptyStruct do
      use ExTypeStruct do
      end
    end

    test "struct with 0 expr" do
      assert struct!(EmptyStruct).__struct__ == EmptyStruct

      assert_raise KeyError, fn ->
        struct!(EmptyStruct, unknown: 123)
      end
    end
  end

  describe "struct with 1 expr" do
    defmodule StructWithOneExprV1 do
      use ExTypeStruct do
        @type t
      end
    end

    defmodule StructWithOneExprV2 do
      use ExTypeStruct do
        @type t()
      end
    end

    defmodule StructWithOneExprV3 do
      use ExTypeStruct do
        @type t()
      end
    end

    defmodule StructWithOneExprV4 do
      use ExTypeStruct, do: @type(t())
    end

    test "struct with 1 type expr" do
      for mod <- [
            StructWithOneExprV1,
            StructWithOneExprV2,
            StructWithOneExprV3,
            StructWithOneExprV4
          ] do
        assert struct!(mod).__struct__ == mod

        assert_raise KeyError, fn ->
          struct!(mod, unknown: 123)
        end
      end
    end

    defmodule StructWithOneExprV5 do
      use ExTypeStruct do
        name :: String.t()
      end
    end

    defmodule StructWithOneExprV6 do
      use ExTypeStruct, do: name :: String.t()
    end

    test "struct with 1 required field expr" do
      for mod <- [StructWithOneExprV5, StructWithOneExprV6] do
        assert struct!(mod, name: "good").__struct__ == mod

        assert_raise ArgumentError, fn ->
          struct!(mod)
        end
      end
    end

    defmodule StructWithOneExprV7 do
      use ExTypeStruct do
        name :: String.t() \\ "hello"
      end
    end

    defmodule StructWithOneExprV8 do
      use ExTypeStruct, do: name :: String.t() \\ "hello"
    end

    test "struct with 1 optional field expr" do
      for mod <- [StructWithOneExprV7, StructWithOneExprV8] do
        assert struct!(mod).__struct__ == mod
        assert struct!(mod).name == "hello"

        assert struct!(mod, name: "good").__struct__ == mod
        assert struct!(mod, name: "good").name == "good"
      end
    end
  end

  describe "struct with mixed exprs" do
    defmodule StructWithMixExprV1 do
      use ExTypeStruct do
        name :: String.t()
        age :: integer() \\ 10
      end
    end

    test "struct with mix exprs v1" do
      assert s = struct!(StructWithMixExprV1, name: "hello")
      assert s.__struct__ == StructWithMixExprV1
      assert s.name == "hello"
      assert s.age == 10

      assert s2 = struct!(StructWithMixExprV1, name: "world", age: 20)
      assert s2.__struct__ == StructWithMixExprV1
      assert s2.name == "world"
      assert s2.age == 20
    end

    defmodule StructWithMixExprV2 do
      use ExTypeStruct do
        @typep t_name(x, y)

        field_1 :: x
        field_2 :: [y]
        field_3 :: float() \\ 1.2
      end

      # remove warning about "private t_name/2 not been used"
      @type use_t_name(a, b) :: t_name(a, b)
    end

    test "struct with mix exprs v2" do
      assert s = struct!(StructWithMixExprV2, field_1: 123, field_2: [])
      assert s.__struct__ == StructWithMixExprV2
      assert s.field_1 == 123
      assert s.field_2 == []
      assert s.field_3 == 1.2

      assert s = struct!(StructWithMixExprV2, field_1: 123, field_2: [], field_3: 2.4)
      assert s.__struct__ == StructWithMixExprV2
      assert s.field_1 == 123
      assert s.field_2 == []
      assert s.field_3 == 2.4
    end
  end

  describe "unhappy path" do
    test "should raise erro with invalid expr" do
      assert_raise ArgumentError, ~r/Invalid argument/, fn ->
        Code.eval_quoted(
          quote do
            defmodule UnhappyV1 do
              use ExTypeStruct
            end
          end
        )
      end

      assert_raise ArgumentError, ~r/Invalid expression/, fn ->
        Code.eval_quoted(
          quote do
            defmodule UnhappyV2 do
              use ExTypeStruct do
                unknown_expression
              end
            end
          end
        )
      end

      assert_raise ArgumentError, ~r/Invalid expression/, fn ->
        Code.eval_quoted(
          quote do
            defmodule UnhappyV3 do
              use ExTypeStruct do
                @typexxx t()

                name :: integer
              end
            end
          end
        )
      end

      assert_raise ArgumentError, ~r/Invalid expression/, fn ->
        Code.eval_quoted(
          quote do
            defmodule UnhappyV4 do
              use ExTypeStruct do
                name \\ 123
              end
            end
          end
        )
      end
    end
  end
end
