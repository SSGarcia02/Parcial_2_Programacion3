defmodule Tramo do
  @moduledoc """
  Struct que representa un tramo dirigido entre dos centros de distribución.
  Cada tramo tiene un tiempo (minutos) y un costo, ambos enteros positivos.
  """
  @enforce_keys [:origen, :destino, :minutos, :costo]
  defstruct [:origen, :destino, :minutos, :costo]

  @doc """
  Convierte una línea cruda de CSV en un %Tramo{}.

  Formato esperado: origen,destino,minutos,costo
  - origen y destino: cadenas no vacías (sin espacios)
  - minutos y costo: enteros positivos

  Devuelve:
    {:ok, %Tramo{}}   si la línea es válida
    {:error, motivo}  si no lo es
  """
  def parse(linea) when is_binary(linea) do
    linea_limpia = String.trim(linea)

    cond do
      linea_limpia == "" ->
        {:error, :linea_vacia}

      String.starts_with?(linea_limpia, "#") ->
        {:error, :linea_comentario}

      true ->
        parse_campos(linea_limpia)
    end
  end

  defp parse_campos(linea) do
    case String.split(linea, ",") do
      [origen, destino, minutos_str, costo_str] ->
        with {:ok, origen}     <- validar_centro(origen),
             {:ok, destino}    <- validar_centro(destino),
             {:ok, minutos}    <- validar_entero_positivo(minutos_str),
             {:ok, costo}      <- validar_entero_positivo(costo_str) do
          {:ok, %Tramo{origen: origen, destino: destino,
                       minutos: minutos, costo: costo}}
        end

      _ ->
        {:error, :campos_incorrectos}
    end
  end

  defp validar_centro(str) do
    centro = String.trim(str)
    if centro == "", do: {:error, :campo_vacio}, else: {:ok, centro}
  end

  defp validar_entero_positivo(str) do
    case Integer.parse(String.trim(str)) do
      {n, ""} when n > 0 -> {:ok, n}
      {_n, ""}           -> {:error, :no_positivo}
      _                  -> {:error, :no_entero}
    end
  end
end
