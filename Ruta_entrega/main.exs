for archivo <- [
      "lib/tramo.exs",
      "lib/itinerario.exs",
      "lib/depuracion.exs",
      "lib/grafo.exs",
      "lib/alcance.exs",
      "lib/busqueda.exs",
      "lib/archivos.exs",
      "lib/taller1.exs"
    ] do
  Code.require_file(archivo)

  
end

Taller1.main()
