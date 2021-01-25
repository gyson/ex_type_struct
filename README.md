# ExTypeStruct

A simple and concise way to annotate structs (or exceptions) with type info.

## Installation

The package can be installed by adding `ex_type_struct` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_type_struct, "~> 0.1"}
  ]
end
```

## Usage

```elixir
defmodule MyStruct do

  use ExTypeStruct do
    # this is a required field
    required_field :: required_field_type()

    # this is an optional field
    optional_field :: optional_field_type() \\ default_value()

    # ^^^ required and optional fields are distinguished by if they have default value.
  end

end
```

- Use `do ... end` block to contain a list of required / optional fields
- Required fields must have form `field_name :: field_type`.
- Required fields would be added to `@enforce_keys` automatically.
- Optional fields must have form `field_name :: field_type \\ default_value`.
- Optional fields won't be added to `@enforce_keys`.

Note: do `use ExTypeStruct.Exception do ... end` if it's for exception.

## Example

### No fields

```elixir
defmodule MyStruct do
  use ExTypeStruct do
  end
end

# above code would be compiled / transformed to following code:

defmodule MyStruct do
  @enforce_keys []

  defstruct []

  @type t() :: %__MODULE__{}
end
```

### Only required fields

```elixir
defmodule MyStruct do
  use ExTypeStruct do
    name :: String.t()
    age :: integer()
  end
end

# above code would be compiled / transformed to following code:

defmodule MyStruct do
  @enforce_keys [:name, :age]

  defstruct [name: nil, age: nil]

  @type t() :: %__MODULE__{
    name: String.t(),
    age: integer()
  }
end
```

### Only optional fields

```elixir
defmodule MyStruct do
  use ExTypeStruct do
    name :: String.t() \\ "Hello"
    age :: integer() \\ 123
  end
end

# above code would be compiled / transformed to following code:

defmodule MyStruct do
  @enforce_keys []

  defstruct [name: "Hello", age: 123]

  @type t() :: %__MODULE__{
    name: String.t(),
    age: integer()
  }
end
```

### Mixed required and optional fields

```elixir
defmodule MyStruct do
  use ExTypeStruct do
    name :: String.t()
    age :: integer() \\ 123
  end
end

# above code would be compiled / transformed to following code:

defmodule MyStruct do
  @enforce_keys [:name]

  defstruct [name: nil, age: 123]

  @type t() :: %__MODULE__{
    name: String.t(),
    age: integer()
  }
end
```

### Use opaque type

By putting custom type attribute as first expr in do block, it would override default `@type t()` type attribute.

```elixir
defmodule MyStruct do
  use ExTypeStruct do
    @opaque t()

    name :: String.t()
    age :: integer() \\ 123
  end
end

# above code would be compiled / transformed to following code:

defmodule MyStruct do
  @enforce_keys [:name]

  defstruct [name: nil, age: 123]

  @opaque t() :: %__MODULE__{
    name: String.t(),
    age: integer()
  }
end
```

### Use a different type name

By putting custom type attribute as first expr in do block, it would override default `@type t()` type attribute.

```elixir
defmodule MyStruct do
  use ExTypeStruct do
    @type t_alias()

    name :: String.t()
    age :: integer() \\ 123
  end
end

# above code would be compiled / transformed to following code:

defmodule MyStruct do
  @enforce_keys [:name]

  defstruct [name: nil, age: 123]

  @type t_alias() :: %__MODULE__{
    name: String.t(),
    age: integer()
  }
end
```

### Type with parameters

By putting custom type attribute as first expr in do block, it would override default `@type t()` type attribute.

```elixir
defmodule MyStruct do
  use ExTypeStruct do
    @type t(x, y)

    name :: x
    age :: y \\ 123
  end
end

# above code would be compiled / transformed to following code:

defmodule MyStruct do
  @enforce_keys [:name]

  defstruct [name: nil, age: 123]

  @type t(x, y) :: %__MODULE__{
    name: x,
    age: y
  }
end
```

### Support `@typedoc` and `@derive`

Nothing special. Just like regular `defstruct` use case.

```elixir
defmodule MyStruct do

  @typedoc "this is type doc"

  @drive [MyProtocol]

  use ExTypeStruct do
    name :: String.t()
    age :: integer() \\ 123
  end
end

# above code would be compiled / transformed to following code:

defmodule MyStruct do

  @typedoc "this is type doc"

  @drive [MyProtocol]

  @enforce_keys [:name]

  defstruct [name: nil, age: 123]

  @type t() :: %__MODULE__{
    name: String.t(),
    age: integer()
  }
end
```

### Support exception

```elixir
defmodule MyException do
  use ExTypeStruct.Exception do
    message :: String.t()
  end
end

# above code would be compiled / transformed to following code:

defmodule MyException do
  @enforce_keys [:message]

  defexception [message: nil]

  @type t :: %__MODULE__{
    message: String.t()
  }
end
```

## License

MIT
