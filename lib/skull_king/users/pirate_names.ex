defmodule SkullKing.PirateNames do
  @pirate_names [
    "William Kidd",
    "Blackbeard",
    "Bartholomew Roberts",
    "Henry Every",
    "Henry Morgan",
    "Stede Bonnet",
    "Thomas Tew",
    "Anne Bonny",
    "Bones",
    "Calico Jack",
    "Edward Low",
    "Howell Davis",
    "Samuel Bellamy",
    "Admiral",
    "Archer",
    "Augie",
    "Azure",
    "Bastian",
    "Belle",
    "Bertha",
    "Booty",
    "Captain",
    "Captain Jolly",
    "Caspian"
  ]

  def random_name() do
    Enum.random(@pirate_names)
  end
end
