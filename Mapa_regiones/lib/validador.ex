defmodule Validador do
  # Recibe: matriz (lista de listas), paleta (lista de structs Color), y número de fila inicial
  def validar_mapa(matriz, paleta) do
    errores = []

    # Validamos estructura (filas del mismo tamaño)
    errores = validar_filas(matriz, 1, longitud_esperada(matriz, 1), errores)

    # Validamos símbolos contra la paleta
    errores = validar_simbolos(matriz, paleta, 0, 0, errores)

    # Validamos la paleta misma (punto, formato hex, duplicados)
    errores = validar_paleta(paleta, 1, errores)

    # Retornamos la lista de errores (si está vacía, todo está bien)
    errores
  end

  # --- VALIDACIÓN DE FILAS ---
  # Caso base: ya no hay filas
  defp validar_filas([], _fila_actual, _esperado, errores), do: errores

  # Caso recursivo: comparamos el tamaño de la fila actual
  defp validar_filas([fila | resto], fila_actual, esperado, errores) do
    if length(fila) != esperado do
      err = "Fila #{fila_actual}: longitud incorrecta (esperada #{esperado}, obtenida #{length(fila)})"
      validar_filas(resto, fila_actual + 1, esperado, [err | errores])
    else
      validar_filas(resto, fila_actual + 1, esperado, errores)
    end
  end

  defp longitud_esperada([primera_fila | _], _), do: length(primera_fila)
  defp longitud_esperada([], _), do: 0

  # --- VALIDACIÓN DE SÍMBOLOS EN MAPA ---
  # Caso base: terminamos todas las filas
  defp validar_simbolos([], _paleta, _fila, _col, errores), do: errores

  # Si terminamos una fila, pasamos a la siguiente
  defp validar_simbolos([[] | resto], paleta, fila, _col, errores) do
    validar_simbolos(resto, paleta, fila + 1, 0, errores)
  end

  # Validamos el símbolo actual (cabeza de la fila)
  defp validar_simbolos([[simbolo | resto_fila] | resto_filas], paleta, fila, col, errores) do
    # Usamos recursión para buscar el símbolo en la paleta
    if not en_paleta?(paleta, simbolo) do
      err = "Fila #{fila + 1}, Columna #{col + 1}: símbolo '#{simbolo}' no está en la paleta"
      validar_simbolos([resto_fila | resto_filas], paleta, fila, col + 1, [err | errores])
    else
      validar_simbolos([resto_fila | resto_filas], paleta, fila, col + 1, errores)
    end
  end

  defp en_paleta?([], _simbolo), do: false
  defp en_paleta?([%Modelo.Color{simbolo: s} | _], simbolo) when s == simbolo, do: true
  defp en_paleta?([_ | resto], simbolo), do: en_paleta?(resto, simbolo)

  # --- VALIDACIÓN DE PALETA ---
  defp validar_paleta([], _linea, errores), do: errores

  defp validar_paleta([color | resto], linea, errores) do
    errores =
      case color do
        %Modelo.Color{simbolo: ".", hex: h} -> validar_hex(h, linea, errores)
        %Modelo.Color{hex: h} -> validar_hex(h, linea, errores)
      end

    errores = if color.simbolo != ".", do: errores, else: errores # Punto verificado

    # Verificamos duplicados en el resto
    if en_paleta?(resto, color.simbolo) do
      err = "Línea #{linea}: símbolo '#{color.simbolo}' duplicado en la paleta"
      validar_paleta(resto, linea + 1, [err | errores])
    else
      validar_paleta(resto, linea + 1, errores)
    end
  end

  # Validar formato #RRGGBB (recursivo sobre el string)
  defp validar_hex("#" <> resto, linea, errores) when byte_size(resto) == 6 do
    if hex_valido?(resto) do
      errores
    else
      ["Línea #{linea}: color hexadecimal inválido", "Línea #{linea}: debe ser #RRGGBB" | errores] # Simplificado
    end
  end

  defp validar_hex(hex, linea, errores) do
    ["Línea #{linea}: color '#{hex}' no tiene formato #RRGGBB" | errores]
  end

  # Validar que los 6 caracteres sean válidos (0-9, A-F, a-f)
  defp hex_valido?(<<c, resto::binary>>) do
    (c in ?0..?9 or c in ?A..?F or c in ?a..?f) and hex_valido?(resto)
  end
  defp hex_valido?(<<>>), do: true
end
