defmodule Omniscience.ImageProvider do
  @moduledoc"""
  カード名からカード画像のURLを生成するプロバイダを生成するためのモジュールです。
  """

  def whisper() do
    case File.read "whisper.txt" do
      {:ok, raw} -> raw
      _ -> get_whisper
    end    
  end
  
  def get_provider(:onmemory) do
    name_map = parse_list(whisper())
    fn(name) ->
      case normalize_lang(name, name_map) do
	{:ok, normalized} -> get_url normalized
	{:error, reason} -> {:error, reason}
      end
    end      
  end

  def get_provider(:sqlite) do
    nil
  end
  
  def parse_list(raw) do
    cards = String.replace(raw, "\r", "") |> String.split("\n\n")
    Enum.flat_map(cards,
      fn(c) ->
	if Enum.count(Regex.scan(~r/英語名/, c)) > 1 do
	  c
	  |> String.replace("　英語名：",  "\n\n　英語名：")
	  |> parse_list
	else
	  lines = String.split(c, "\n")	
	  [{
	    Enum.find(lines, fn(line) -> String.starts_with?(line, "　英語名：") end)
	    |> format_eng,
	    Enum.find(lines, fn(line) -> String.starts_with?(line, "日本語名：") end)
	    |> format_jpn
	  }]	       
	end
      end)
  end

  def format_eng(eng) do
    case eng do
      nil -> nil
      _ -> String.replace_prefix(eng, "　英語名：", "")
      |> String.replace("AE", "æ")
      |> String.downcase	
    end
  end

  def format_jpn(jpn) do
    case jpn do
      nil -> nil
      _ ->
	head_trimmed = String.replace_prefix(jpn, "日本語名：", "")
	Regex.replace(~r/（.*）/, head_trimmed, "")
    end
  end
  
  def update_storage(card_list) do
    {:ok, card_list}
  end

  def get_whisper() do
    "http://whisper.wisdom-guild.net/search.php?name=&name_ope=and&mcost=&mcost_op=able&mcost_x=may&ccost_more=0&ccost_less=&msw_gt=0&msw_lt=&msu_gt=0&msu_lt=&msb_gt=0&msb_lt=&ms_ope=and&msr_gt=0&msr_lt=&msg_gt=0&msg_lt=&msc_gt=0&msc_lt=&msp_gt=0&msp_lt=&msh_gt=0&msh_lt=&color_multi=able&color_ope=and&rarity_ope=or&text=&text_ope=and&oracle=&oracle_ope=and&p_more=&p_less=&t_more=&t_less=&l_more=&l_less=&display=cardname&supertype_ope=or&cardtype_ope=or&subtype_ope=or&format=all&exclude=no&set_ope=or&illus_ope=or&illus_ope=or&flavor=&flavor_ope=and&sort=name_en&sort_op=&output=text"
  end

  def normalize_lang(name, name_map) do
    lower = String.downcase name
    ae = lower |> String.downcase |> String.replace("ae", "æ")
    match = Enum.find(name_map, fn(n) ->
      case n do
	{^lower, _} -> n
	{_, ^lower} -> n
	_ -> case n do
	       {^ae, _} -> n
	       _ -> nil
	     end	  
      end
    end)

    case match do
      {en, _} -> {:ok, en}
      _ -> {:error, "#{name} not found from database"}
    end
  end

  def get_url(name) do
    IO.puts "searching #{name}"
    encoded = encode name
    url = "http://gatherer.wizards.com/Pages/Search/Default.aspx?special=true&name=+[m/^#{encoded}$/]"
    result = HTTPoison.get(url)

    # retry only one time
    %{headers: headers} = case result do
      {:ok, res} -> res
      _ -> HTTPoison.get!(url)
    end
    
    loc_header = Enum.find headers, fn({key, _}) -> key == "Location" end
    
    location = case loc_header do
		 {_, h} -> h
		 _ -> nil
	       end
    
    if location == nil do
      IO.inspect headers
      {:error, "something is wrong"}
    else
      mvid = Regex.replace(~r(/Pages/Card/Details.aspx\?multiverseid=), location, "")
      if Integer.parse(mvid) == :error do
	{:error, "mvid fetch failed, location = #{location}, mvid = #{mvid}"}
      else
	{:ok, "http://gatherer.wizards.com/Handlers/Image.ashx?multiverseid=#{mvid}&type=card"}
      end
    end
  end

  def encode(name) do
    name
    |> String.replace(" ", "\\s")
    |> String.replace("?", "\\?")
  end
end











