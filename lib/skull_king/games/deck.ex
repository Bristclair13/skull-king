defmodule SkullKing.Games.Deck do
  defmodule Card do
    defstruct [:color, :value, :special, :image]
  end

  def new_deck() do
    basic_cards =
      for value <- values(), color <- colors() do
        %Card{color: color, value: value, image: "/images/cards/#{color}-#{value}.jpeg"}
      end

    surrender_cards =
      Enum.map(1..5, fn _n ->
        %Card{value: 0, special: :surrender, image: "/images/cards/surrender.jpeg"}
      end)

    deck = basic_cards ++ surrender_cards
    Enum.shuffle(deck)
  end

  defp values(), do: Enum.to_list(1..14)
  defp colors(), do: [:green, :yellow, :purple, :black]
end
