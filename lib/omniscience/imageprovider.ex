defmodule Omniscience.ImageProvider do
  def whisper() do
    case File.read "whisper.txt" do
      {:ok, raw} -> raw
      _ -> get_whisper
    end    
  end
  
  def get_provider(:onmemory) do
    name_map = parse_list(whisper())
    fn(name) ->
      {:ok, normalized} = normalize_lang(name, name_map)
      get_url normalized
    end      
  end

  def get_provider(:sqlite) do
    nil
  end
  
  def parse_list(raw) do
    cards = String.replace(raw, "\r", "") |> String.split("\n\n")
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
    match = Omniscience.EnumEx.firstp(name_map, fn(n) ->
      case n do
	{^name, _} -> n
	{_, ^name} -> n
	_ -> nil
      end
    end)

    case match do
      {en, _} -> {:ok, en}
      _ -> {:error, "#{name} not found from database"}
    end
  end

  def get_url(name) do    
    url = "http://gatherer.wizards.com/Pages/Search/Default.aspx?name=+[m/^#{name}$/]"    
    %{headers: headers} = HTTPoison.get!(url)
    
    loc_header = Enum.find headers, fn({key, _}) -> key == "Location" end
    
    location = case loc_header do
		 {_, h} -> h
		 _ -> nil
	       end
    
    mvid = Regex.replace(~r(/Pages/Card/Details.aspx\?multiverseid=), location, "")    
    "http://gatherer.wizards.com/Handlers/Image.ashx?multiverseid=#{mvid}&type=card"
  end
end

