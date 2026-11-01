defmodule Depuracion do
  @moduledoc """
  Depura la red de tramos de forma recursiva (Requisito 7).
  Sin usar Enum ni Stream dentro de las funciones recursivas.
  """

  def depurar(tramos) do
    depurar_rec(tramos, MapSet.new(), [], [])
  end

  # Caso base: lista vacía, devolvemos los acumuladores invertidos
  defp depurar_rec([], _vistos, validos, descartes) do
    {invertir(validos), invertir(descartes)}
  end

  # Caso recursivo: origen == destino (descartamos)
  defp depurar_rec([{n, texto, {:ok, %Tramo{origen: o, destino: d}}} | resto], vistos, validos, descartes)
       when o == d do
    descartes = [{n, texto, "origen y destino iguales"} | descartes]
    depurar_rec(resto, vistos, validos, descartes)
  end

  # Caso recursivo: tramo válido en formato, verificamos duplicados
  defp depurar_rec([{n, texto, {:ok, %Tramo{origen: o, destino: d} = tramo}} | resto], vistos, validos, descartes) do
    if MapSet.member?(vistos, {o, d}) do
      # Es un duplicado
      depurar_rec(resto, vistos, validos, [{n, texto, "duplicado"} | descartes])
    else
      # Es válido y nuevo (usamos el struct 'tramo' que ya viene en el patrón)
      vistos = MapSet.put(vistos, {o, d})
      validos = [{n, tramo} | validos]
      depurar_rec(resto, vistos, validos, descartes)
    end
  end

  # Caso recursivo: ignorar errores de parseo (ya se manejaron en Archivos)
  defp depurar_rec([_error | resto], vistos, validos, descartes) do
    depurar_rec(resto, vistos, validos, descartes)
  end

  # Inversión recursiva sin Enum
  defp invertir(lista), do: invertir(lista, [])
  defp invertir([], acc), do: acc
  defp invertir([head | tail], acc), do: invertir(tail, [head | acc])
end
