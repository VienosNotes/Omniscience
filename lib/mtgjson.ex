defmodule Card do
  defstruct name: nil, jpname: nil, mid: nil
end

defmodule MtgJson do
  
  def get_multiverse_id(name) do    
    1
  end

  def load_cards(json) do
    {%Card{name: "Lightning Bolt", jpname: "稲妻", mid: 1}}
  end

  def update_storage(card_list) do
    {:ok}
  end
  
end



