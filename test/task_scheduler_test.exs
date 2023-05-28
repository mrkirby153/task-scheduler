defmodule TaskSchedulerTest do
  use ExUnit.Case
  doctest TaskScheduler

  test "greets the world" do
    assert TaskScheduler.hello() == :world
  end
end
