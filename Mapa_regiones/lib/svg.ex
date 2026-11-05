defmodule Svg do
  def generar(matriz, paleta, regiones, ruta) do
    filas = length(matriz)
    columnas = length(hd(matriz))

    ancho = columnas * 40
    alto = filas * 40

    {:ok, archivo} = File.open(ruta, [:write, :utf8])

    # 1. Encabezado XML y SVG
    IO.puts(archivo, ~s(<?xml version="1.0" encoding="UTF-8"?>))
    IO.puts(archivo, ~s(<svg xmlns="http://www.w3.org/2000/svg" width="#{ancho}" height="#{alto}">))

    # 2. Fondo general (opcional pero recomendado si el mapa no cubre todo)
    # Usamos el color del punto (.) si existe en la paleta
    color_fondo = buscar_color(paleta, ".")
    IO.puts(archivo, ~s(  <rect width="#{ancho}" height="#{alto}" fill="#{color_fondo}" />))

    # 3. Rectángulos de cada casilla
    dibujar_casillas(archivo, matriz, paleta, 0, 0, regiones)

    # 4. Textos con los IDs (en la primera celda de cada región)
    dibujar_ids(archivo, regiones)

    # 5. Cierre
    IO.puts(archivo, "</svg>")
    File.close(archivo)
  end

  # Recorremos la matriz recursivamente para dibujar rectángulos
  defp dibujar_casillas(_archivo, matriz, _paleta, fila, _col, _regiones) when fila >= length(matriz), do: :ok

  defp dibujar_casillas(archivo, matriz, paleta, fila, col, regiones) when col >= length(hd(matriz)) do
    dibujar_casillas(archivo, matriz, paleta, fila + 1, 0, regiones)
  end

  defp dibujar_casillas(archivo, matriz, paleta, fila, col, regiones) do
    simbolo = Enum.at(Enum.at(matriz, fila), col)
    color = buscar_color(paleta, simbolo)
    x = col * 40
    y = fila * 40

    # Rectángulo con borde negro
    IO.puts(archivo, ~s(  <rect x="#{x}" y="#{y}" width="40" height="40" fill="#{color}" stroke="#000000" stroke-width="1"/>))

    dibujar_casillas(archivo, matriz, paleta, fila, col + 1, regiones)
  end

  # Dibujar los textos de ID
  defp dibujar_ids(archivo, regiones) do
    Enum.each(regiones, fn region ->
      # Tomamos la primera celda (que ya sabemos que es la de menor fila y columna por cómo encontramos la región)
      {f, c} = region.desde
      x = c * 40 + 20 # Centro X
      y = f * 40 + 25 # Centro Y (un poco abajo para que se vea bien)

      texto_escapado = escapar_xml(Integer.to_string(region.id))

      IO.puts(archivo, ~s(  <text x="#{x}" y="#{y}" font-family="Arial" font-size="16" fill="black" text-anchor="middle" font-weight="bold">#{texto_escapado}</text>))
    end)
  end

  # Helpers
  defp buscar_color(paleta, simbolo) do
    case Enum.find(paleta, fn c -> c.simbolo == simbolo end) do
      nil -> "#FFFFFF" # Blanco por defecto si no lo encuentra (no debería pasar por validación)
      color -> color.hex
    end
  end

  # Escapar caracteres especiales de XML
  defp escapar_xml(texto) do
    texto
    |> String.replace("&", "&amp;")
    |> String.replace("<", "&lt;")
    |> String.replace(">", "&gt;")
    |> String.replace("\"", "&quot;")
    |> String.replace("'", "&apos;")
  end
end
