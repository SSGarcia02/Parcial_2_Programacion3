defmodule Reportes do
  # Escribe el CSV de regiones
  def escribir_csv(regiones, ruta) do
    {:ok, archivo} = File.open(ruta, [:write, :utf8])

    # Encabezado
    IO.puts(archivo, "id;simbolo;area;perimetro;desde;hasta")

    # Escribir cada región por flujo
    Enum.each(regiones, fn r ->
      linea = "#{r.id};#{r.simbolo};#{r.area};#{r.perimetro};#{formatear_coord(r.desde)};#{formatear_coord(r.hasta)}"
      IO.puts(archivo, linea)
    end)

    File.close(archivo)
  end

  # Formatea las tuplas {f,c} como "{f,c}"
  defp formatear_coord({f, c}), do: "{#{f},#{c}}"

  # Calcula los máximos y genera el resumen
  def generar_resumen(regiones, ruta_txt) do
    total = length(regiones)

    # Buscar área máxima y perímetro máximo
    max_area = Enum.max_by(regiones, & &1.area).area
    max_perim = Enum.max_by(regiones, & &1.perimetro).perimetro

    # Filtrar los que empatan
    regiones_max_area = Enum.filter(regiones, & &1.area == max_area)
    regiones_max_perim = Enum.filter(regiones, & &1.perimetro == max_perim)

    # Abrir archivo para escribir
    {:ok, archivo} = File.open(ruta_txt, [:write, :utf8])

    # Escribir en pantalla y en archivo (función auxiliar)
    escribir_linea(archivo, "=== RESUMEN DE REGIONES ===")
    escribir_linea(archivo, "Total de regiones: #{total}")

    escribir_linea(archivo, "\nMayor área (#{max_area}):")
    Enum.each(regiones_max_area, fn r ->
      escribir_linea(archivo, " - Región #{r.id} (Símbolo: #{r.simbolo})")
    end)

    escribir_linea(archivo, "\nMayor perímetro (#{max_perim}):")
    Enum.each(regiones_max_perim, fn r ->
      escribir_linea(archivo, " - Región #{r.id} (Símbolo: #{r.simbolo})")
    end)

    File.close(archivo)
  end

  # Escribe en el archivo y en la consola al mismo tiempo
  defp escribir_linea(archivo, texto) do
    IO.puts(texto)        # Consola
    IO.puts(archivo, texto) # Archivo
  end

    # Escribe los errores de validación en el archivo especificado
  def escribir_errores_validacion(errores, ruta) do
    {:ok, archivo} = File.open(ruta, [:write, :utf8])

    IO.puts(archivo, "=== REPORTE DE ERRORES DE VALIDACIÓN ===")
    IO.puts(archivo, "Se encontraron #{length(errores)} problema(s):\n")

    Enum.each(errores, fn error ->
      IO.puts(archivo, "- #{error}")
    end)

    File.close(archivo)
  end
end
