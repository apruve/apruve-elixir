defmodule Apruve.MixProject do
  use Mix.Project

  def project do
    [
      app: :apruve,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      name: "Apruve",
      source_url: "https://github.com/elixir-ecto/postgrex",
      description: description(),
      docs: docs(),
      package: package(),
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:hackney, "~> 1.6"},
      {:jason, "~> 1.1"},
      {:ex_doc, ">= 0.0.0", only: :dev},
      {:dialyxir, "~> 0.5", only: [:dev, :test], runtime: false}
    ]
  end

  defp docs do
    [
      logo: "logo.png",
      main: "Apruve"
    ]
  end

  defp description() do
    "The official Apruve plugin for Elixir"
  end

  defp package() do
    [
      licenses: ["Mozilla 2.0"],
      links: %{"GitHub" => "https://github.com/apruve/apruve-elixir"}
    ]
  end
end
