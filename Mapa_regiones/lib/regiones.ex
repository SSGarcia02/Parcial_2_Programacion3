defmodule Regiones do
  # Encuentra todas las regiones en la matriz.
  # Retorna una lista de %Modelo.Region{}
  def encontrar_todas(matriz) do
    # Iniciamos el recorrido desde la fila 0, columna 0, con un mapa de visitados vacío
    recorrer_casillas(matriz, 0, 0, %{}, [])
  end

  # --- RECORRIDO PRINCIPAL (Casillas no visitadas) ---

  # Si nos pasamos del número de filas, terminamos
  defp recorrer_casillas(matriz, fila, _col, visitados, regiones) when fila >= length(matriz) do
    Enum.reverse(regiones)
  end

  # Si terminamos las columnas de la fila actual, pasamos a la siguiente fila
  defp recorrer_casillas(matriz, fila, col, visitados, regiones) when col >= length(hd(matriz)) do
    recorrer_casillas(matriz, fila + 1, 0, visitados, regiones)
  end

  # Procesamos la casilla actual
  defp recorrer_casillas(matriz, fila, col, visitados, regiones) do
    simbolo = obtener_simbolo(matriz, fila, col)

    cond do
      # Si ya la visitamos o es fondo (.), la ignoramos y seguimos
      Map.has_key?(visitados, {fila, col}) or simbolo == "." ->
        recorrer_casillas(matriz, fila, col + 1, visitados, regiones)

      # Si es un símbolo nuevo, exploramos su región completa
      true ->
        {nuevos_visitados, celdas} = explorar_vecinos(matriz, fila, col, simbolo, visitados, [])

        region = construir_region(simbolo, celdas)
        id = length(regiones) + 1
        region = %{region | id: id}

        recorrer_casillas(matriz, fila, col + 1, nuevos_visitados, [region | regiones])
    end
  end

  # --- EXPLORACIÓN DE VECINOS (DFS) ---

  # Caso base: coordenadas fuera de los límites
  defp explorar_vecinos(_matriz, f, c, _simbolo, visitados, celdas)
       when f < 0 or c < 0 do
    {visitados, celdas}
  end

  defp explorar_vecinos(matriz, f, c, simbolo, visitados, celdas) do
    if f >= length(matriz) or c >= length(hd(matriz)) do
      {visitados, celdas}
    else
      simbolo_actual = obtener_simbolo(matriz, f, c)

      cond do
        # Si ya está visitada, o no es el mismo símbolo, o es fondo (por seguridad)
        Map.has_key?(visitados, {f, c}) or simbolo_actual != simbolo or simbolo == "." ->
          {visitados, celdas}

        # Si es válida, la marcamos como visitada y exploramos sus 4 vecinos
        true ->
          visitados = Map.put(visitados, {f, c}, true)
          celdas = [{f, c} | celdas]

          # Explorar Arriba
          {v1, c1} = explorar_vecinos(matriz, f - 1, c, simbolo, visitados, celdas)
          # Explorar Abajo
          {v2, c2} = explorar_vecinos(matriz, f + 1, c, simbolo, v1, c1)
          # Explorar Izquierda
          {v3, c3} = explorar_vecinos(matriz, f, c - 1, simbolo, v2, c2)
          # Explorar Derecha
          explorar_vecinos(matriz, f, c + 1, simbolo, v3, c3)
      end
    end
  end

  # --- CONSTRUCCIÓN DE LA REGIÓN ---

  defp construir_region(simbolo, celdas) do
    area = length(celdas)

    # Calcular caja envolvente (desde y hasta)
    {min_f, max_f, min_c, max_c} = calcular_caja(celdas)

    desde = {min_f, min_c}
    hasta = {max_f, max_c}

    # El perímetro requiere revisar los 4 vecinos de cada celda
    perimetro = calcular_perimetro(celdas)

    %Modelo.Region{
      id: 0, # Se asigna afuera
      simbolo: simbolo,
      celdas: celdas,
      area: area,
      perimetro: perimetro,
      desde: desde,
      hasta: hasta
    }
  end

  defp calcular_caja([{f, c} | resto]) do
    calcular_caja(resto, f, f, c, c)
  end
  defp calcular_caja([], min_f, max_f, min_c, max_c), do: {min_f, max_f, min_c, max_c}

  defp calcular_caja([{f, c} | resto], min_f, max_f, min_c, max_c) do
    nuevo_min_f = min(f, min_f)
    nuevo_max_f = max(f, max_f)
    nuevo_min_c = min(c, min_c)
    nuevo_max_c = max(c, max_c)
    calcular_caja(resto, nuevo_min_f, nuevo_max_f, nuevo_min_c, nuevo_max_c)
  end

  # --- CÁLCULO DE PERÍMETRO ---

  # El perímetro es la cantidad de lados que dan al exterior o a otro símbolo.
  # Como no tenemos la matriz completa aquí, simplemente asumimos que si un vecino
  # NO está en la lista de celdas de esta región, cuenta como perímetro.
  defp calcular_perimetro(celdas) do
    # Usamos un MapSet para búsquedas O(1)
    conjunto = MapSet.new(celdas)

    Enum.reduce(celdas, 0, fn {f, c}, acc ->
      vecinos = [{f-1, c}, {f+1, c}, {f, c-1}, {f, c+1}]
      # Contamos cuántos vecinos NO están en la región
      lados = Enum.count(vecinos, fn v -> not MapSet.member?(conjunto, v) end)
      acc + lados
    end)
  end

  # --- HELPERS ---

  defp obtener_simbolo(matriz, fila, col) do
    matriz
    |> Enum.at(fila)
    |> Enum.at(col)
  end
end
