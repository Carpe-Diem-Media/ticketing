defmodule Ticketing.Outbox.CanonicalJSON do
  @moduledoc """
  Encodes JSON values as RFC 8785 canonical JSON for internal outbox identities.

  Map keys use UTF-16 code-unit ordering, arrays retain their input order, and
  numbers follow ECMAScript serialization rules. Values outside the JSON data
  model return `{:error, :unsupported_value}`.
  """

  @number_pattern ~r/\A(?<sign>-?)(?<integer>\d+)(?:\.(?<fraction>\d+))?(?:[eE](?<exponent>[+-]?\d+))?\z/

  @type json_value ::
          nil
          | boolean()
          | number()
          | binary()
          | [json_value()]
          | %{optional(binary()) => json_value()}

  @doc "Returns the canonical UTF-8 JSON bytes for a JSON value."
  @spec encode(json_value()) :: {:ok, binary()} | {:error, :unsupported_value}
  def encode(value) do
    with {:ok, encoded} <- encode_value(value) do
      {:ok, IO.iodata_to_binary(encoded)}
    end
  end

  defp encode_value(nil), do: {:ok, "null"}
  defp encode_value(true), do: {:ok, "true"}
  defp encode_value(false), do: {:ok, "false"}

  defp encode_value(value) when is_integer(value), do: encode_integer(value)
  defp encode_value(value) when is_float(value), do: encode_float(value)
  defp encode_value(value) when is_binary(value), do: encode_string(value)

  defp encode_value(value) when is_list(value), do: encode_list(value)
  defp encode_value(value) when is_map(value), do: encode_object(value)
  defp encode_value(_value), do: {:error, :unsupported_value}

  defp encode_list(value) do
    if proper_list?(value), do: encode_proper_list(value), else: {:error, :unsupported_value}
  end

  defp encode_proper_list(value) do
    case Enum.reduce_while(value, {:ok, []}, &encode_list_item/2) do
      {:ok, encoded_items} ->
        {:ok, ["[", Enum.intersperse(Enum.reverse(encoded_items), ","), "]"]}

      error ->
        error
    end
  end

  defp encode_list_item(item, {:ok, encoded_items}) do
    case encode_value(item) do
      {:ok, encoded_item} -> {:cont, {:ok, [encoded_item | encoded_items]}}
      error -> {:halt, error}
    end
  end

  defp encode_object(value) do
    keys = Map.keys(value)

    if Enum.all?(keys, &(is_binary(&1) and String.valid?(&1))) do
      encode_object_pairs(value, Enum.sort_by(keys, &utf16_code_units/1))
    else
      {:error, :unsupported_value}
    end
  end

  defp encode_object_pairs(value, keys) do
    case Enum.reduce_while(keys, {:ok, []}, fn key, acc -> encode_object_pair(value, key, acc) end) do
      {:ok, encoded_pairs} ->
        {:ok, ["{", Enum.intersperse(Enum.reverse(encoded_pairs), ","), "}"]}

      error ->
        error
    end
  end

  defp encode_object_pair(value, key, {:ok, encoded_pairs}) do
    with {:ok, encoded_key} <- encode_string(key),
         {:ok, encoded_value} <- encode_value(Map.fetch!(value, key)) do
      {:cont, {:ok, [[encoded_key, ":", encoded_value] | encoded_pairs]}}
    else
      error -> {:halt, error}
    end
  end

  defp encode_integer(value)
       when value >= -9_007_199_254_740_992 and value <= 9_007_199_254_740_992,
       do: {:ok, Integer.to_string(value)}

  defp encode_integer(value) do
    value
    |> Kernel.*(1.0)
    |> encode_float()
  rescue
    ArithmeticError -> {:error, :unsupported_value}
  end

  defp encode_float(value) when value == 0.0, do: {:ok, "0"}

  defp encode_float(value) do
    value
    |> :erlang.float_to_binary([:short])
    |> ecmascript_number_string()
  rescue
    ArgumentError -> {:error, :unsupported_value}
  end

  defp ecmascript_number_string(representation) do
    case Regex.named_captures(@number_pattern, representation) do
      %{
        "sign" => sign,
        "integer" => integer_part,
        "fraction" => fraction_part,
        "exponent" => exponent_part
      } ->
        explicit_exponent = if exponent_part == "", do: 0, else: String.to_integer(exponent_part)
        decimal_exponent = explicit_exponent - byte_size(fraction_part)
        digits = String.trim_leading(integer_part <> fraction_part, "0")

        if digits == "" do
          {:ok, "0"}
        else
          {digits, decimal_exponent} = strip_trailing_zeroes(digits, decimal_exponent)
          {:ok, sign <> format_decimal(digits, decimal_exponent)}
        end

      _ ->
        {:error, :unsupported_value}
    end
  end

  defp strip_trailing_zeroes(digits, decimal_exponent) do
    trimmed = String.trim_trailing(digits, "0")
    removed = byte_size(digits) - byte_size(trimmed)

    if removed == 0 do
      {digits, decimal_exponent}
    else
      {trimmed, decimal_exponent + removed}
    end
  end

  defp format_decimal(digits, decimal_exponent) do
    digit_count = byte_size(digits)
    scientific_exponent = digit_count + decimal_exponent - 1

    if scientific_exponent < -6 or scientific_exponent >= 21 do
      format_scientific(digits, scientific_exponent)
    else
      format_fixed(digits, decimal_exponent)
    end
  end

  defp format_fixed(digits, decimal_exponent) do
    decimal_position = byte_size(digits) + decimal_exponent

    cond do
      decimal_position <= 0 ->
        "0." <> String.duplicate("0", -decimal_position) <> digits

      decimal_position >= byte_size(digits) ->
        digits <> String.duplicate("0", decimal_position - byte_size(digits))

      true ->
        whole = binary_part(digits, 0, decimal_position)
        fraction = binary_part(digits, decimal_position, byte_size(digits) - decimal_position)
        whole <> "." <> fraction
    end
  end

  defp format_scientific(digits, scientific_exponent) do
    first = binary_part(digits, 0, 1)
    rest = binary_part(digits, 1, byte_size(digits) - 1)
    mantissa = if rest == "", do: first, else: first <> "." <> rest

    exponent =
      if scientific_exponent >= 0, do: "+#{scientific_exponent}", else: "#{scientific_exponent}"

    mantissa <> "e" <> exponent
  end

  defp encode_string(value) when is_binary(value) do
    if String.valid?(value) do
      escaped = value |> String.to_charlist() |> Enum.map(&escape_codepoint/1)
      {:ok, ["\"", escaped, "\""]}
    else
      {:error, :unsupported_value}
    end
  end

  defp escape_codepoint(?\"), do: "\\\""
  defp escape_codepoint(?\\), do: "\\\\"
  defp escape_codepoint(?\b), do: "\\b"
  defp escape_codepoint(?\t), do: "\\t"
  defp escape_codepoint(?\n), do: "\\n"
  defp escape_codepoint(?\f), do: "\\f"
  defp escape_codepoint(?\r), do: "\\r"

  defp escape_codepoint(codepoint) when codepoint < 0x20 do
    "\\u" <> (codepoint |> Integer.to_string(16) |> String.pad_leading(4, "0"))
  end

  defp escape_codepoint(codepoint), do: <<codepoint::utf8>>

  defp utf16_code_units(value) do
    value
    |> String.to_charlist()
    |> Enum.flat_map(fn
      codepoint when codepoint <= 0xFFFF ->
        [codepoint]

      codepoint ->
        scalar = codepoint - 0x10000
        [0xD800 + div(scalar, 0x400), 0xDC00 + rem(scalar, 0x400)]
    end)
  end

  defp proper_list?([]), do: true
  defp proper_list?([_head | tail]), do: proper_list?(tail)
  defp proper_list?(_value), do: false
end
