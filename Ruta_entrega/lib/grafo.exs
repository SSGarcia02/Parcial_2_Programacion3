defmodule Grafo do
  @moduledoc """
  Construye y consulta el grafo de la red de distribución.
  """

  @doc """
  Construye un mapa de adyacencia a partir de una lista de {n, %Tramo{}}.
  Devuelve %{centro => [%Tramo{}, ...]}.
  """
  def construir(tramos_validos) do
    # Llamamos a la función recursiva con un mapa vacío
    construir_rec(tramos_validos, %{})
  end

  # Caso base
  defp construir_rec([], grafo), do: grafo

  # Caso recursivo: agregar el tramo al mapa
  defp construir_rec([{_n, %Tramo{origen: o} = tramo} | resto], grafo) do
    # Map.update/4: si la llave existe, agrega el tramo a la lista;
    # si no existe, crea una nueva lista con el tramo.
    nuevo_grafo = Map.update(grafo, o, [tramo], fn lista -> [tramo | lista] end)
    construir_rec(resto, nuevo_grafo)
  end

  @doc """
  Retorna true si el centro existe en el grafo (tiene tramos de salida
  o es destino de algún tramo).
  """
  def existe_centro?(grafo, centro) do
    # Verificamos si es origen (está en las llaves)
    # o si es destino (buscamos en las listas de tramos)
    Map.has_key?(grafo, centro) or es_destino?(grafo, centro)
  end

  # Búsqueda recursiva de si el centro aparece como destino
  defp es_destino?(grafo, centro) do
    es_destino_rec(Map.values(grafo), centro)
  end

  defp es_destino_rec([], _centro), do: false

  defp es_destino_rec([tramos | resto], centro) do
    if algun_tramo_llega_a?(tramos, centro) do
      true
    else
      es_destino_rec(resto, centro)
    end
  end

  defp algun_tramo_llega_a?([], _centro), do: false
  defp algun_tramo_llega_a?([%Tramo{destino: d} | _], centro) when d == centro, do: true
  defp algun_tramo_llega_a?([_ | resto], centro), do: algun_tramo_llega_a?(resto, centro)
end
