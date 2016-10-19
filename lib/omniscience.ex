defmodule Omniscience do
  use Slack
  
  def main([token]) do
    IO.puts "start omniscence as #{token}"
    provider = Omniscience.ImageProvider.get_provider(:onmemory)
    start_agent(provider)
    {:ok, _} = Omniscience.start_link(token)    
  end

  def start_agent(provider) do
    {:ok, pid} = Agent.start_link(fn -> provider end, name: :provider)
    {:ok, _} = Agent.start_link(fn -> spawn &post_url/0 end, name: :receiver)
    pid
  end

  def handle_message(message = %{type: "message"}, slack) do
    prov = Agent.get(:provider, fn prov -> prov end)
    receiver = Agent.get(:receiver, fn r -> r end)

    parse_message(message)
    |> Enum.reverse
    |> Enum.map(fn(name) ->
      spawn(fn ->
	case apply(prov, [name]) do
	  {:ok, url} -> send receiver, {:ok, "#{name}: #{url}", message, slack}
	  {:error, reason} -> send receiver, {:ok, "Fail to search: #{reason}", message, slack }
	end
      end)    
    end)
  end
  def handle_message(_,_), do: :ok

  def parse_message(%{text: text}) do
    Regex.scan(~r/《(.+?)》/, text)
    |> Enum.map(fn([_,name]) -> name end)
  end
  def parse_message(_), do: []

  def post_url do
    receive do
      {:ok, content, message, slack} ->
	send_message(content, message.channel, slack)
	post_url
    end
  end
end



