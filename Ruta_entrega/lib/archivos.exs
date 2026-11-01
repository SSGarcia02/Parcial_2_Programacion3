defmodule Archivos do
  @moduledoc """
  Módulo encargado de la lectura y escritura por flujo (Requisitos 1, 2, 3, 4, 6).
  """

  @doc """
  Lee un archivo CSV de tramos en flujo, filtrando líneas vacías y comentarios.
  Devuelve un Stream de tuplas {n, linea_original, resultado_parseo}.
  """
  def leer_tramos(ruta) do
    ruta
    |> File.stream!()
    # 1. Asignar número de línea física (ANTES de filtrar)
    |> Stream.with_index(1)
    # 2. Filtrar líneas vacías y comentarios
    |> Stream.reject(fn {linea, _n} ->
      linea_limpia = String.trim(linea)
      linea_limpia == "" or String.starts_with?(linea_limpia, "#")
    end)
    # 3. Parsear cada línea conservando su número y texto original
    |> Stream.map(fn {linea, n} ->
      {n, String.trim(linea), Tramo.parse(linea)}
    end)
  end

  @doc """
  Escribe las líneas de error en el archivo de salida por flujo.
  Recibe el stream de errores y la ruta de destino.
  """
  def escribir_errores(stream_errores, ruta_salida) do
    stream_errores
    |> Stream.map(fn {n, texto, motivo} ->
      "Línea #{n}: #{texto} | #{motivo}\n"
    end)
    # Usamos File.stream! con :append para no borrar lo que ya está (aunque esté vacío)
    |> Enum.into(File.stream!(ruta_salida, [:append]))
  end

  @doc """
  Escribe las líneas de descarte en el archivo de salida por flujo.
  Recibe la lista de descartes y la ruta de destino.
  """
  def escribir_descartes(descartes, ruta_salida) do
    descartes
    |> Stream.map(fn {n, texto, motivo} ->
      "Línea #{n}: #{texto} | #{motivo}\n"
    end)
    |> Enum.into(File.stream!(ruta_salida, [:append]))
  end

    @doc """
  Lee un archivo de consultas en flujo.
  Devuelve un Stream de tuplas {n, {origen, destino}} o {n, :error}.
  """
  def leer_consultas(ruta) do
    ruta
    |> File.stream!()
    |> Stream.with_index(1)
    |> Stream.reject(fn {linea, _n} ->
      linea_limpia = String.trim(linea)
      linea_limpia == "" or String.starts_with?(linea_limpia, "#")
    end)
    |> Stream.map(fn {linea, n} ->
      case String.split(String.trim(linea), ",") do
        [origen, destino] -> {n, {String.trim(origen), String.trim(destino)}}
        _                 -> {n, :error}
      end
    end)
  end
end
