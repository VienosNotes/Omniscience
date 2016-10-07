defmodule MtgJsonTest do  
  use ExUnit.Case
  doctest MtgJson

  test "get multiverse id" do
    assert MtgJson.get_multiverse_id("稲妻") == 1
  end

  test "load cards from json" do
    assert MtgJson.load_cards("") == {%Card{name: "Lightning Bolt", jpname: "稲妻", mid: 1}}
  end

  test "update storage" do
    assert MtgJson.update_storage({}) == {:ok}
  end
end
