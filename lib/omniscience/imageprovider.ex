defmodule Omniscience.ImageProvider do
  def whisper() do
  end    
  
  def load_cards() do
    whisper() |> parse_list |> update_storage
  end

  def parse_list(raw) do
    cards = String.split(raw, "\n\n")
    Enum.map(cards,
      fn(c) -> lines = String.split(c, "\n")
	{
	  Omniscience.EnumEx.firstp(lines, fn(line) -> String.starts_with?(line, "　英語名：") end)
	  |> format_eng,
	  Omniscience.EnumEx.firstp(lines, fn(line) -> String.starts_with?(line, "日本語名：") end)
	  |> format_jpn
	}	       
      end)      
  end

  def format_eng(eng) do
    case eng do
      nil -> nil
      _ -> String.replace_prefix(eng, "　英語名：", "")
    end
  end

  def format_jpn(jpn) do
    case jpn do
      nil -> nil
      _ ->
	head_trimmed = String.replace_prefix(jpn, "日本語名：", "")
	Regex.replace(~r/（.*/, head_trimmed, "")
    end
  end
  
  def update_storage(card_list) do
    {:ok}
  end
end



