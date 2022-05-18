defmodule GenReport do
  alias GenReport.Parser

  def build(filename) do
    filename
    |> Parser.parse_file()
    |> Enum.reduce(report_acc(), &sum_values(&1, &2))
  end

  def build, do: {:error, "Insira o nome de um arquivo"}

  def build_from_many(filenames) do
    result =
      filenames
      |> Task.async_stream(&build/1)
      |> Enum.reduce(report_acc(), fn {:ok, result}, report -> sum_reports(report, result) end)

    {:ok, result}
  end

  def build_from_many, do: {:error, "Insira o nome dos arquivos"}

  defp sum_values([name, hours, _day, month, year], %{
         "all_hours" => all_hours,
         "hours_per_month" => hours_per_month,
         "hours_per_year" => hours_per_year
       }) do
    all_hours = Map.put(all_hours, name, sum(all_hours[name], hours))

    hours_per_month =
      Map.put(hours_per_month, name, sum_hours_by(hours_per_month[name], hours, month))

    hours_per_year =
      Map.put(hours_per_year, name, sum_hours_by(hours_per_year[name], hours, year))

    build_report(all_hours, hours_per_month, hours_per_year)
  end

  defp sum_reports(
         %{
           "all_hours" => all_hours1,
           "hours_per_month" => hours_per_month1,
           "hours_per_year" => hours_per_year1
         },
         %{
           "all_hours" => all_hours2,
           "hours_per_month" => hours_per_month2,
           "hours_per_year" => hours_per_year2
         }
       ) do
    all_hours = merge_maps(all_hours1, all_hours2)
    hours_per_month = merge_maps_of_maps(hours_per_month1, hours_per_month2)
    hours_per_year = merge_maps_of_maps(hours_per_year1, hours_per_year2)

    build_report(all_hours, hours_per_month, hours_per_year)
  end

  defp sum(nil, new), do: new
  defp sum(previous, new), do: previous + new

  defp sum_hours_by(nil, hours, by), do: %{by => hours}

  defp sum_hours_by(previous, hours, by) do
    merge_maps(previous, %{by => hours})
  end

  defp merge_maps_of_maps(map1, map2) do
    Map.merge(map1, map2, fn _key, value1, value2 -> merge_maps(value1, value2) end)
  end

  defp merge_maps(map1, map2) do
    Map.merge(map1, map2, fn _key, value1, value2 -> value1 + value2 end)
  end

  def report_acc do
    all_hours = %{}
    hours_per_month = %{}
    hours_per_year = %{}

    build_report(all_hours, hours_per_month, hours_per_year)
  end

  defp build_report(all_hours, hours_per_month, hours_per_year) do
    %{
      "all_hours" => all_hours,
      "hours_per_month" => hours_per_month,
      "hours_per_year" => hours_per_year
    }
  end
end
