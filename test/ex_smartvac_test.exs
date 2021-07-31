defmodule ExSmartvacTest do
  use ExUnit.Case
  doctest ExSmartvac

  test "greets the world" do
    assert ExSmartvac.hello() == :world
  end
end
