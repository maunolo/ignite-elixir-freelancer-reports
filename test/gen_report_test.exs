defmodule GenReportTest do
  use ExUnit.Case

  alias GenReport
  alias GenReport.Support.ReportFixture

  @filename "gen_report.csv"
  @filenames ["part_1.csv", "part_2.csv", "part_3.csv"]

  describe "build/1" do
    test "When passing file name return a report" do
      response = GenReport.build(@filename)

      assert response == ReportFixture.build()
    end

    test "When no filename was given, returns an error" do
      response = GenReport.build()

      assert response == {:error, "Insira o nome de um arquivo"}
    end
  end

  describe "build_from_many/1" do
    test "When passing file names return a report" do
      response = GenReport.build_from_many(@filenames)

      assert response == {:ok, ReportFixture.build()}
    end

    test "When no filenames was given, returns an error" do
      response = GenReport.build_from_many()

      assert response == {:error, "Insira o nome dos arquivos"}
    end
  end
end
