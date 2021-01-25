defmodule ExTypeStruct.MixProject do
  use Mix.Project

  @github_url "https://github.com/gyson/ex_type_struct"

  def project do
    [
      app: :ex_type_struct,
      version: "0.1.0",
      description: "A simple and concise way to annotate structs with type info.",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),

      # for docs
      name: "ExTypeStruct",
      source_url: @github_url,
      homepage_url: @github_url,
      docs: [
        main: "README",
        extras: ["README.md"]
      ]
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
      {:ex_doc, "~> 0.23", only: :dev, runtime: false}
    ]
  end

  defp package do
    %{
      licenses: ["MIT"],
      links: %{"GitHub" => @github_url}
    }
  end
end
