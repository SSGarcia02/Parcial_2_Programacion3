defmodule Itinerario do
  @moduledoc """
  Representa un itinerario simple entre un origen y un destino.
  - centros: lista de centros en orden, p. ej. ["A", "B", "D"]
  - minutos: tiempo total del itinerario
  - costo: costo total del itinerario
  - tramos: lista de %Tramo{} usados (campo auxiliar para el reporte)
  """
  @enforce_keys [:centros, :minutos, :costo]
  defstruct [:centros, :minutos, :costo, tramos: []]
end
