defmodule Omniscience.EnumEx do
  def firstp(target, pred) do
    case target do
      [head|tail] -> if pred.(head) do head else firstp(tail, pred) end	
      [] -> nil
	something -> IO.puts something
    end
  end
end
