defmodule ExTypeStruct.ExceptionTest do
  use ExUnit.Case

  describe "normal case" do
    defmodule MyException do
      use ExTypeStruct.Exception do
        message :: String.t() \\ "my bad"
      end
    end

    test "should be able to raise" do
      assert_raise MyException, "my bad", fn ->
        raise MyException
      end

      assert_raise MyException, "im ok", fn ->
        raise MyException, message: "im ok"
      end
    end
  end
end
