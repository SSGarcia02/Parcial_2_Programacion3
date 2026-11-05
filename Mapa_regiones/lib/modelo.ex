defmodule Modelo do
  defmodule Color do
    @enforce_keys [:simbolo, :nombre, :hex]
    defstruct [:simbolo, :nombre, :hex]
  end

  defmodule Region do
    @enforce_keys [:id, :simbolo, :celdas, :area, :perimetro, :desde, :hasta]
    defstruct [:id, :simbolo, :celdas, :area, :perimetro, :desde, :hasta]
  end
end
