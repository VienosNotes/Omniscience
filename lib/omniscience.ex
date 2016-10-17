defmodule Omniscience do
  use Slack
  
  def main([token]) do
    IO.puts "start omniscence as #{token}"
    provider = Omniscience.ImageProvider.get_provider(:onmemory)
    start_agent(provider)
    {:ok, _} = Omniscience.start_link(token)    
  end

  def start_agent(provider) do
    {:ok, pid} = Agent.start_link(fn -> provider end, name: __MODULE__)
    pid
  end

  def handle_message(message = %{type: "message"}, slack) do
    prov = Agent.get(__MODULE__, fn prov -> prov end)
    spawn fn ->
      Enum.map(parse_message(message), fn name -> apply(prov, [name]) end)
      |> List.foldl("", fn(name, acc) -> acc <> "\n" <> name end)
      |> send_message(message.channel, slack)
    end
  end
  def handle_message(_,_), do: :ok

  def parse_message(%{text: text}) do
    Regex.scan(~r/《(.+?)》/, text)
    |> Enum.map(fn([_,name]) -> name end)
  end
  def parse_message(_), do: []  
end



