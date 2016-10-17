defmodule EnumExTest do  
  use ExUnit.Case
  doctest Omniscience.EnumEx

  def pred(n) do
    rem(n, 3) == 0
  end
  
  test "can take first element that pred returns true" do
    sample = [1,2,3,4,5,6]
    assert Omniscience.EnumEx.firstp(sample, &pred/1) == 3
  end

  test "return nil when passed argument is empty" do
    assert Omniscience.EnumEx.firstp([], &pred/1) == nil
  end
end
