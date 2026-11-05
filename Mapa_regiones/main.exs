Code.require_file("lib/modelo.ex", __DIR__)
Code.require_file("lib/archivos.ex", __DIR__)
Code.require_file("lib/validador.ex", __DIR__)
Code.require_file("lib/regiones.ex", __DIR__)
Code.require_file("lib/reportes.ex", __DIR__)
Code.require_file("lib/svg.ex", __DIR__)

defmodule Main do
  def iniciar do
    with {:ok, matriz} <- Archivos.leer_mapa("mapa.txt"),
         {:ok, paleta} <- Archivos.leer_paleta("paleta.csv") do

      errores = Validador.validar_mapa(matriz, paleta)

      if errores == [] do
        IO.puts("✅ Validación exitosa. Calculando regiones...\n")

        regiones = Regiones.encontrar_todas(matriz)

        # 1. Generar CSV
        Reportes.escribir_csv(regiones, "regiones.csv")
        IO.puts("✅ Archivo regiones.csv generado.")

        # 2. Generar Resumen (pantalla y TXT)
        IO.puts("") # Salto de línea
        Reportes.generar_resumen(regiones, "resumen_regiones.txt")
        IO.puts("\n✅ Archivo resumen_regiones.txt generado.")

        # 3. Generar SVG
        Svg.generar(matriz, paleta, regiones, "mapa_regiones.svg")
        IO.puts("✅ Archivo mapa_regiones.svg generado.")

      else
        IO.puts("❌ Errores de validación encontrados. Revise validacion_mapa.txt")
        # ¡NUEVA LÍNEA! Guardar los errores en el archivo
        Reportes.escribir_errores_validacion(errores, "validacion_mapa.txt")
      end
    else
      {:error, motivo} -> IO.puts(:standard_error, motivo)
    end
  end
end

Main.iniciar()
