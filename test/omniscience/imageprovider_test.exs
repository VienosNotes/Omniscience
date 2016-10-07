defmodule ImageProviderTest do  
  use ExUnit.Case
  doctest Omniscience.ImageProvider
  
  test "parsing card list" do
     sample_input = """
　英語名：Accomplished Automaton
日本語名：成し遂げた自動機械（なしとげたじどうきかい）
　コスト：(７)
　タイプ：アーティファクト・クリーチャー --- 構築物(Construct)
製造１（このクリーチャーが戦場に出たとき、これの上に+1/+1カウンターを１個置くか、無色の1/1の霊気装置(Servo)アーティファクト・クリーチャー・トークンを１体生成する。）
　Ｐ／Ｔ：5/7
イラスト：Daarken
　セット：Kaladesh
　稀少度：コモン


　英語名：Acrobatic Maneuver
日本語名：軽業の妙技（かるわざのみょうぎ）
　コスト：(２)(白)
　タイプ：インスタント
あなたがコントロールするクリーチャー１体を対象とし、それを追放する。その後、そのカードをオーナーのコントロール下で戦場に戻す。
カードを１枚引く。
イラスト：Winona Nelson
　セット：Kaladesh
　稀少度：コモン


　英語名：Aerial Responder
日本語名：空中対応員（くうちゅうたいおういん）
　コスト：(１)(白)(白)
　タイプ：クリーチャー --- ドワーフ(Dwarf)・兵士(Soldier)
飛行、警戒、絆魂
　Ｐ／Ｔ：2/3
イラスト：Raoul Vitale
　セット：Kaladesh
　稀少度：アンコモン
"""

    result = Omniscience.ImageProvider.parse_list(sample_input)
    expect = [
      {"Accomplished Automaton", "成し遂げた自動機械"},
      {"Acrobatic Maneuver", "軽業の妙技"},
      {"Aerial Responder", "空中対応員"}
    ]
    assert result == expect
  end
end
