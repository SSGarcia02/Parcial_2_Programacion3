defmodule Alcance do
  @moduledoc """
  Calcula los centros alcanzables usando un Stream infinito.
  """

  def calcular(grafo, origen) do
    # Paso 0: conjunto inicial con solo el origen
    inicial = MapSet.new([origen])

    # Stream infinito
    stream_infinito =
      Stream.iterate(inicial, fn conjunto_actual ->
        expandir_conjunto(grafo, conjunto_actual)
      end)

    # Usamos reduce_while para consumir y detenernos al estabilizar.
    # El acumulador es {lista_estados_invertida, ultimo_conjunto, paso_actual, paso_estabilizacion}
    Enum.reduce_while(stream_infinito, {[], nil, 0, nil}, fn conjunto, {acumulados, anterior, paso, _estab} ->
      if anterior != nil and MapSet.equal?(conjunto, anterior) do
        # Caso base: el conjunto actual es igual al anterior. Nos detenemos.
        # Retornamos {:halt, {estados, ultimo, paso, paso_estabilizacion}}
        {:halt, {acumulados, anterior, paso, paso}}
      else
        # Caso recursivo: el conjunto sigue cambiando. Guardamos y seguimos.
        nuevos_acumulados = [{paso, conjunto} | acumulados]
        {:cont, {nuevos_acumulados, conjunto, paso + 1, nil}}
      end
    end)
    |> case do
      {acumulados, _anterior, _paso, paso_estabilizacion} ->
        # Invertimos la lista para que quede del Paso 0 al N
        {invertir(acumulados), paso_estabilizacion}
    end
  end

  # Expande un conjunto: añade los destinos de todos los tramos que salen
  # de los centros ya alcanzados.
  defp expandir_conjunto(grafo, conjunto) do
    # Iteramos recursivamente sobre los elementos del conjunto
    expandir_iter(MapSet.to_list(conjunto), grafo, conjunto)
  end

  defp expandir_iter([], _grafo, acumulado), do: acumulado

  defp expandir_iter([centro | resto], grafo, acumulado) do
    # Obtenemos los tramos que salen de este centro
    tramos = Map.get(grafo, centro, [])
    # Agregamos los destinos al conjunto
    nuevo_acumulado = agregar_destinos(tramos, acumulado)
    expandir_iter(resto, grafo, nuevo_acumulado)
  end

  defp agregar_destinos([], acumulado), do: acumulado

  defp agregar_destinos([%Tramo{destino: d} | resto], acumulado) do
    nuevo_acumulado = MapSet.put(acumulado, d)
    agregar_destinos(resto, nuevo_acumulado)
  end

  # Función auxiliar recursiva para invertir una lista
  defp invertir(lista), do: invertir(lista, [])
  defp invertir([], acc), do: acc
  defp invertir([head | tail], acc), do: invertir(tail, [head | acc])
end
