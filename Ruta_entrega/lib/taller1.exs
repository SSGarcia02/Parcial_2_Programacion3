defmodule Taller1 do
  @dir Path.expand(Path.join(__DIR__, ".."))
  @tramos_csv      Path.join(@dir, "tramos.csv")
  @consultas_txt   Path.join(@dir, "consultas.txt")
  @errores_txt     Path.join(@dir, "errores_tramos.txt")
  @depuracion_txt  Path.join(@dir, "depuracion_tramos.txt")
  @alcance_txt     Path.join(@dir, "alcance_centros.txt")
  @itinerarios_txt Path.join(@dir, "itinerarios.txt")

  def main do
    case verificar_entradas() do
      :ok ->
        IO.puts("Entradas OK. Procesando...")

        # Limpiamos los archivos de salida al inicio de la ejecución (Requisito 4)
        limpiar_salidas()

        # PASO 3: Lectura perezosa
        stream = Archivos.leer_tramos(@tramos_csv)
        {validos_parse, errores} = Enum.split_with(stream, fn {_n, _t, res} -> match?({:ok, _}, res) end)

        errores_limpios = Enum.map(errores, fn {n, texto, {:error, motivo}} -> {n, texto, motivo} end)
        Archivos.escribir_errores(errores_limpios, @errores_txt)

        # PASO 4: Depuración recursiva
        {validos_dep, descartes} = Depuracion.depurar(validos_parse)
        Archivos.escribir_descartes(descartes, @depuracion_txt)

        # PASO 5: Construir el grafo
        grafo = Grafo.construir(validos_dep)

        IO.puts("Grafo construido con #{length(validos_dep)} tramos.")
        IO.puts("----------------------------------------")

        # PASO 6: Procesar consultas
        consultas_stream = Archivos.leer_consultas(@consultas_txt)
        consultas = Enum.to_list(consultas_stream)

        Enum.each(consultas, fn
          {n, {origen, destino}} ->
            procesar_consulta(grafo, origen, destino, n)
          {n, :error} ->
            IO.puts(:standard_error, "Consulta en línea #{n} tiene formato inválido.")
        end)

        IO.puts("Proceso terminado. Revisa los archivos generados.")

      {:error, ruta} ->
        IO.puts(:standard_error, "Falta el archivo requerido: #{ruta}")
    end
  end

  defp procesar_consulta(grafo, origen, destino, _n) do
    IO.puts("Consulta: #{origen} -> #{destino}")

    if not Grafo.existe_centro?(grafo, origen) do
      IO.puts("  El centro de origen '#{origen}' no existe en la red.")
    else
      # PASO 6: Alcance
      {estados, paso_estabilizacion} = Alcance.calcular(grafo, origen)

      # Escribir alcance en el archivo (Requisito 4: a medida que se produce)
      escribir_alcance_txt(origen, destino, estados, paso_estabilizacion)

      # Verificar si el destino es alcanzable
      conjunto_final = elem(List.last(estados), 1)
      if MapSet.member?(conjunto_final, destino) do
        IO.puts("  ✅ El destino '#{destino}' es alcanzable. Buscando itinerarios...")

        # PASO 7: Búsqueda de itinerarios
        itinerarios = Busqueda.encontrar_itinerarios(grafo, origen, destino)

        if itinerarios == [] do
          IO.puts("  No se encontraron itinerarios.")
          escribir_itinerarios_vacio(origen, destino)
        else
          # Calcular criterios
          {g_tramos, g_tiempo, g_costo} = Busqueda.calcular_criterios(itinerarios)

          # Escribir itinerarios en el archivo (Requisito 4)
          escribir_itinerarios_txt(origen, destino, itinerarios, g_tramos, g_tiempo, g_costo)

          # Mostrar resumen en pantalla (Requisito 5: solo el total)
          IO.puts("  Total: #{length(itinerarios)} itinerarios")
        end
      else
        IO.puts("  ❌ El destino '#{destino}' NO es alcanzable. (Sin itinerarios)")
        # El enunciado dice "indiquen «sin itinerarios» y omitan la búsqueda"
        escribir_itinerarios_vacio(origen, destino)
      end
    end
    IO.puts("")
  end

  # ---------------------------------------------------------
  # Escritura por flujo (Requisito 4)
  # ---------------------------------------------------------

  defp limpiar_salidas do
    # Reemplazamos los archivos creándolos vacíos al inicio
    File.write!(@errores_txt, "")
    File.write!(@depuracion_txt, "")
    File.write!(@alcance_txt, "")
    File.write!(@itinerarios_txt, "")
  end

  defp escribir_alcance_txt(origen, destino, estados, paso_estab) do
    # Escribimos el bloque de esta consulta
    File.write!(@alcance_txt, "=== Alcance desde #{origen} (consulta #{origen} -> #{destino}) ===\n", [:append])

    Enum.each(estados, fn {paso, conjunto} ->
      lista = MapSet.to_list(conjunto) |> Enum.sort()
      File.write!(@alcance_txt, "Paso #{paso}: #{inspect(lista)}\n", [:append])
    end)

    File.write!(@alcance_txt, "Se estabiliza en el paso #{paso_estab}\n\n", [:append])
  end

  defp escribir_itinerarios_txt(origen, destino, itinerarios, g_tramos, g_tiempo, g_costo) do
    # Escribimos el bloque
    File.write!(@itinerarios_txt, "=== #{origen} -> #{destino} ===\n", [:append])

    # Escribimos cada itinerario
    Enum.with_index(itinerarios, 1)
    |> Enum.each(fn {it, idx} ->
      centros_str = Enum.join(it.centros, " -> ")
      tramos_count = length(it.centros) - 1
      linea = "Itinerario #{idx}: #{centros_str} | tramos: #{tramos_count} | #{it.minutos} min | costo: #{it.costo}\n"
      File.write!(@itinerarios_txt, linea, [:append])
    end)

    # Total y criterios
    File.write!(@itinerarios_txt, "Total: #{length(itinerarios)} itinerarios\n", [:append])
    File.write!(@itinerarios_txt, "Menos tramos: #{formatear_indices(g_tramos)}\n", [:append])
    File.write!(@itinerarios_txt, "Menor tiempo: #{formatear_indices(g_tiempo)}\n", [:append])
    File.write!(@itinerarios_txt, "Menor costo: #{formatear_indices(g_costo)}\n\n", [:append])
  end

  defp escribir_itinerarios_vacio(origen, destino) do
    File.write!(@itinerarios_txt, "=== #{origen} -> #{destino} ===\n", [:append])
    File.write!(@itinerarios_txt, "Sin itinerarios\n\n", [:append])
  end

  # Formatea la lista de índices como "1, 3"
  defp formatear_indices(lista) do
    Enum.join(lista, ", ")
  end

  defp verificar_entradas do
    cond do
      not File.exists?(@tramos_csv)    -> {:error, @tramos_csv}
      not File.exists?(@consultas_txt) -> {:error, @consultas_txt}
      true                             -> :ok
    end
  end
end
