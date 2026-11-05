defmodule Archivos do
  # Lee el mapa como una lista de listas (matriz de símbolos)
  # Retorna {:ok, matriz} o {:error, motivo}
  def leer_mapa(ruta) do
    if File.exists?(ruta) do
      matriz =
        ruta
        |> File.stream!()
        |> Stream.with_index(1) # Conserva el número de línea original (inicia en 1)
        |> Stream.reject(fn {linea, _num} -> es_ignorada?(linea) end)
        |> Enum.map(fn {linea, _num} ->
          linea |> String.trim() |> String.split(" ")
        end)

      {:ok, matriz}
    else
      {:error, "Falta el archivo: #{ruta}"}
    end
  end

  # Función auxiliar para el Requisito 3
  defp es_ignorada?(linea) do
    limpia = String.trim(linea)
    limpia == "" or String.starts_with?(limpia, "#")
  end

    # Agrega esto dentro del módulo Archivos
  def leer_paleta(ruta) do
    if File.exists?(ruta) do
      paleta =
        ruta
        |> File.stream!()
        |> Stream.with_index(1)
        |> Stream.reject(fn {linea, _num} -> es_ignorada?(linea) end)
        |> Enum.map(fn {linea, _num} ->
          [simbolo, nombre, hex] = linea |> String.trim() |> String.split(",")
          %Modelo.Color{simbolo: simbolo, nombre: nombre, hex: hex}
        end)

      {:ok, paleta}
    else
      {:error, "Falta el archivo: #{ruta}"}
    end
  end
  # TODO: Implementar leer_paleta/1 con el mismo estilo (File.stream!)
end
