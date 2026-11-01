defmodule Busqueda do
  @moduledoc """
  Búsqueda de itinerarios simples y cálculo de criterios óptimos.
  """

  @doc """
  Encuentra todos los itinerarios simples entre origen y destino.
  Retorna una lista de %Itinerario{}.
  """
  def encontrar_itinerarios(grafo, origen, destino) do
    # Llamamos al DFS con el camino actual [origen], los tramos recorridos [],
    # el acumulador de minutos (0), costo (0) y la lista de resultados ([]).
    dfs(grafo, origen, destino, [origen], [], 0, 0, [])
  end

  # Caso base: llegamos al destino
  defp dfs(_grafo, destino, destino, centros_rev, tramos_rev, min, cos, resultados) do
    # Invertimos las listas para que queden en el orden correcto
    centros = invertir(centros_rev)
    tramos = invertir(tramos_rev)

    itinerario = %Itinerario{
      centros: centros,
      minutos: min,
      costo: cos,
      tramos: tramos
    }
    # Agregamos el itinerario encontrado a los resultados
    [itinerario | resultados]
  end

  # Caso recursivo: seguimos explorando desde el centro actual
  defp dfs(grafo, actual, destino, centros_rev, tramos_rev, min, cos, resultados) do
    # Obtenemos los tramos que salen del centro actual
    tramos_salida = Map.get(grafo, actual, [])

    # Exploramos cada tramo de salida recursivamente
    explorar_tramos(tramos_salida, grafo, actual, destino, centros_rev, tramos_rev, min, cos, resultados)
  end

  # Función auxiliar para explorar los tramos de salida sin usar Enum
  defp explorar_tramos([], _grafo, _actual, _destino, _centros_rev, _tramos_rev, _min, _cos, resultados) do
    resultados
  end

  defp explorar_tramos([%Tramo{destino: sig} = tramo | resto], grafo, actual, destino, centros_rev, tramos_rev, min, cos, resultados) do
    if contiene?(centros_rev, sig) do
      # Si el siguiente centro ya está en el camino, no lo visitamos (evita ciclos)
      explorar_tramos(resto, grafo, actual, destino, centros_rev, tramos_rev, min, cos, resultados)
    else
      # Si no está, lo agregamos al camino y exploramos
      nuevos_centros = [sig | centros_rev]
      nuevos_tramos = [tramo | tramos_rev]
      nuevos_min = min + tramo.minutos
      nuevos_cos = cos + tramo.costo

      # Llamada recursiva principal
      resultados_actualizados = dfs(grafo, sig, destino, nuevos_centros, nuevos_tramos, nuevos_min, nuevos_cos, resultados)

      # Continuamos con el resto de tramos de salida
      explorar_tramos(resto, grafo, actual, destino, centros_rev, tramos_rev, min, cos, resultados_actualizados)
    end
  end

  # Búsqueda recursiva en una lista (sin Enum.member?)
  defp contiene?([], _elem), do: false
  defp contiene?([head | _], elem) when head == elem, do: true
  defp contiene?([_ | tail], elem), do: contiene?(tail, elem)

  # Inversión recursiva (sin Enum.reverse)
  defp invertir(lista), do: invertir(lista, [])
  defp invertir([], acc), do: acc
  defp invertir([head | tail], acc), do: invertir(tail, [head | acc])

  # ---------------------------------------------------------
  # Criterios óptimos (a) menos tramos, (b) menor tiempo, (c) menor costo
  # ---------------------------------------------------------

  @doc """
  Calcula los tres criterios óptimos y retorna una tupla con las listas de índices ganadores.
  Los índices corresponden a la posición en la lista de itinerarios (1-based).
  """
  def calcular_criterios(itinerarios) do
    # Primero calculamos los valores mínimos para cada criterio
    min_tramos = minimo_por(itinerarios, fn it -> length(it.centros) - 1 end)
    min_tiempo = minimo_por(itinerarios, fn it -> it.minutos end)
    min_costo  = minimo_por(itinerarios, fn it -> it.costo end)

    # Luego obtenemos los índices (1-based) que empatan en el mínimo
    ganadores_tramos = indices_iguales(itinerarios, fn it -> length(it.centros) - 1 end, min_tramos, 1, [])
    ganadores_tiempo = indices_iguales(itinerarios, fn it -> it.minutos end, min_tiempo, 1, [])
    ganadores_costo  = indices_iguales(itinerarios, fn it -> it.costo end, min_costo, 1, [])

    {ganadores_tramos, ganadores_tiempo, ganadores_costo}
  end

  # Encuentra el valor mínimo aplicando una función a cada itinerario
  defp minimo_por([], _func), do: :infinity
  defp minimo_por([it | resto], func), do: minimo_rec(resto, func, func.(it))

  defp minimo_rec([], _func, actual_min), do: actual_min
  defp minimo_rec([it | resto], func, actual_min) do
    val = func.(it)
    nuevo_min = if val < actual_min, do: val, else: actual_min
    minimo_rec(resto, func, nuevo_min)
  end

  # Encuentra los índices donde la función aplicada al itinerario es igual al mínimo
  defp indices_iguales([], _func, _min, _idx, acc), do: invertir(acc)
  defp indices_iguales([it | resto], func, min, idx, acc) do
    if func.(it) == min do
      indices_iguales(resto, func, min, idx + 1, [idx | acc])
    else
      indices_iguales(resto, func, min, idx + 1, acc)
    end
  end
end
