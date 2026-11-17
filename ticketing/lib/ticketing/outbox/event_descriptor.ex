defmodule Ticketing.Outbox.EventDescriptor do
  @moduledoc """
  Validates an internal event descriptor against an EVT-1 registry entry and
  derives the canonical dedupe and ordering identities.

  This module defines no production descriptors or delivery handlers. Callers
  supply the installed EVT-1 registry when registering a descriptor.
  """

  alias Ticketing.Outbox.CanonicalJSON

  @registry_sha_pattern "^[0-9a-f]{64}$"
  @registry_sha_regex ~r/\A[0-9a-f]{64}\z/
  @enforce_keys [
    :event_type,
    :registry_source,
    :topic,
    :required_data_keys,
    :required_extensions,
    :context_rules,
    :dedupe_key_fields,
    :dedupe_window_seconds,
    :ordering_key_fields,
    :ordering_mode
  ]
  defstruct @enforce_keys

  @descriptor_keys [
    :event_type,
    :registry_source,
    :topic,
    :required_data_keys,
    :dedupe_key_fields,
    :dedupe_window_seconds,
    :ordering_key_fields,
    :ordering_mode
  ]

  @type t :: %__MODULE__{
          event_type: binary(),
          registry_source: binary(),
          topic: binary(),
          required_data_keys: [binary()],
          required_extensions: [binary()],
          context_rules: %{optional(binary()) => map()},
          dedupe_key_fields: [binary()],
          dedupe_window_seconds: pos_integer(),
          ordering_key_fields: [binary()],
          ordering_mode: :monotonic
        }

  @doc "Validates static descriptor facts against the supplied EVT-1 contract."
  @spec register(map(), map()) :: {:ok, t()} | {:error, :EVT_INVALID_TYPE}
  def register(descriptor, evt1) when is_map(descriptor) and is_map(evt1) do
    event_type = attribute(descriptor, :event_type)
    event_types = Map.get(evt1, "event_types", %{})

    with :ok <- validate_descriptor_shape(descriptor),
         type when is_binary(type) <- event_type,
         registry_entry when is_map(registry_entry) <- Map.get(event_types, type),
         :ok <- validate_descriptor(descriptor, type, registry_entry, evt1),
         {:ok, registered} <- build_descriptor(descriptor, type, registry_entry, evt1) do
      {:ok, registered}
    else
      _ -> {:error, :EVT_INVALID_TYPE}
    end
  end

  def register(_descriptor, _evt1), do: {:error, :EVT_INVALID_TYPE}

  @doc "Returns lowercase SHA-256 dedupe and ordering identities for an event."
  @spec digests(t(), map(), map()) ::
          {:ok, %{dedupe_key_sha256: binary(), ordering_key_sha256: binary()}}
          | {:error, :EVT_CONTEXT_MISSING | :ERR_VALIDATION}
  def digests(%__MODULE__{} = descriptor, context, payload)
      when is_map(context) and is_map(payload) do
    with :ok <- validate_context(descriptor, context),
         :ok <- validate_payload(descriptor, payload),
         {:ok, ordered_dedupe_fields} <-
           ordered_values(descriptor.dedupe_key_fields, context, payload),
         {:ok, ordered_fields} <- ordered_values(descriptor.ordering_key_fields, context, payload),
         {:ok, dedupe_key_sha256} <-
           hash(%{
             "event_type" => descriptor.event_type,
             "ordered_dedupe_fields" => ordered_dedupe_fields
           }),
         {:ok, ordering_key_sha256} <- hash(%{"ordered_fields" => ordered_fields}) do
      {:ok, %{dedupe_key_sha256: dedupe_key_sha256, ordering_key_sha256: ordering_key_sha256}}
    end
  end

  def digests(%__MODULE__{}, _context, _payload), do: {:error, :EVT_CONTEXT_MISSING}

  defp validate_descriptor(descriptor, event_type, registry_entry, evt1) do
    with :ok <- validate_registry_metadata(descriptor, event_type, registry_entry),
         :ok <- validate_required_data(descriptor, registry_entry),
         :ok <- validate_dedupe(descriptor, registry_entry),
         :ok <- validate_ordering(descriptor, registry_entry),
         :ok <- validate_registry_envelope(evt1) do
      :ok
    else
      _ -> {:error, :EVT_INVALID_TYPE}
    end
  end

  defp validate_registry_metadata(descriptor, event_type, registry_entry) do
    source = get_in(registry_entry, ["schema_governance", "source"])
    topic = Map.get(registry_entry, "topic")

    if attribute(descriptor, :event_type) == event_type and
         attribute(descriptor, :registry_source) == source and is_binary(source) and
         attribute(descriptor, :topic) == topic and is_binary(topic) do
      :ok
    else
      {:error, :EVT_INVALID_TYPE}
    end
  end

  defp validate_required_data(descriptor, registry_entry) do
    required_data_keys = Map.get(registry_entry, "required_data_keys")

    if attribute(descriptor, :required_data_keys) == required_data_keys and
         valid_field_list?(required_data_keys) do
      :ok
    else
      {:error, :EVT_INVALID_TYPE}
    end
  end

  defp validate_dedupe(descriptor, registry_entry) do
    idempotency = Map.get(registry_entry, "idempotency", %{})
    fields = Map.get(idempotency, "dedupe_key")
    window_days = Map.get(idempotency, "dedupe_window_days")

    if attribute(descriptor, :dedupe_key_fields) == fields and valid_field_list?(fields) and
         is_integer(window_days) and window_days > 0 and
         attribute(descriptor, :dedupe_window_seconds) == window_days * 86_400 do
      :ok
    else
      {:error, :EVT_INVALID_TYPE}
    end
  end

  defp validate_ordering(descriptor, registry_entry) do
    ordering = Map.get(registry_entry, "ordering", %{})
    fields = Map.get(ordering, "ordering_key") || Map.get(ordering, "key")

    if attribute(descriptor, :ordering_key_fields) == fields and valid_field_list?(fields) and
         Map.get(ordering, "monotonic_within_key") == true and
         attribute(descriptor, :ordering_mode) in [:monotonic, "monotonic"] do
      :ok
    else
      {:error, :EVT_INVALID_TYPE}
    end
  end

  defp validate_registry_envelope(evt1) do
    if valid_registry_envelope?(evt1), do: :ok, else: {:error, :EVT_INVALID_TYPE}
  end

  defp build_descriptor(descriptor, event_type, registry_entry, evt1) do
    global_extensions = get_in(evt1, ["event_envelope", "extensions", "required"]) || []

    required_extensions =
      (Map.get(registry_entry, "required_extensions", []) ++ global_extensions)
      |> Enum.uniq()

    context_rules = get_in(evt1, ["event_envelope", "extensions", "field_rules"]) || %{}

    {:ok,
     %__MODULE__{
       event_type: event_type,
       registry_source: attribute(descriptor, :registry_source),
       topic: attribute(descriptor, :topic),
       required_data_keys: attribute(descriptor, :required_data_keys),
       required_extensions: required_extensions,
       context_rules: context_rules,
       dedupe_key_fields: attribute(descriptor, :dedupe_key_fields),
       dedupe_window_seconds: attribute(descriptor, :dedupe_window_seconds),
       ordering_key_fields: attribute(descriptor, :ordering_key_fields),
       ordering_mode: :monotonic
     }}
  end

  defp valid_registry_envelope?(evt1) do
    is_list(get_in(evt1, ["event_envelope", "extensions", "required"])) and
      is_map(get_in(evt1, ["event_envelope", "extensions", "field_rules"]))
  end

  defp validate_descriptor_shape(descriptor) do
    string_keys = Enum.map(@descriptor_keys, &Atom.to_string/1)

    allowed_keys? =
      Enum.all?(Map.keys(descriptor), fn key -> key in @descriptor_keys or key in string_keys end)

    duplicate_aliases? =
      Enum.any?(@descriptor_keys, fn key ->
        Map.has_key?(descriptor, key) and Map.has_key?(descriptor, Atom.to_string(key))
      end)

    if allowed_keys? and not duplicate_aliases?, do: :ok, else: {:error, :EVT_INVALID_TYPE}
  end

  defp valid_field_list?(fields) do
    is_list(fields) and fields != [] and Enum.all?(fields, &(is_binary(&1) and &1 != "")) and
      length(fields) == length(Enum.uniq(fields))
  end

  defp validate_context(descriptor, context) do
    if Enum.all?(descriptor.required_extensions, &valid_context_field?(&1, descriptor, context)) do
      :ok
    else
      {:error, :EVT_CONTEXT_MISSING}
    end
  end

  defp valid_context_field?(field, descriptor, context) do
    case fetch_field(context, field) do
      {:ok, value} -> valid_context_value?(value, Map.get(descriptor.context_rules, field, %{}))
      :error -> false
    end
  end

  defp valid_context_value?(value, rule) do
    valid_context_type?(value, rule) and valid_context_length?(value, rule) and
      valid_context_pattern?(value, rule)
  end

  defp valid_context_type?(value, rule) do
    case Map.get(rule, "type") do
      "string" -> is_binary(value)
      _ -> true
    end
  end

  defp valid_context_length?(value, rule) do
    case {Map.get(rule, "min_length"), value} do
      {min_length, value} when is_integer(min_length) and is_binary(value) ->
        String.valid?(value) and String.length(value) >= min_length

      {min_length, value} when is_integer(min_length) ->
        min_length == 0 and value != nil

      _ ->
        true
    end
  end

  defp valid_context_pattern?(value, rule) do
    case Map.get(rule, "pattern") do
      @registry_sha_pattern when is_binary(value) ->
        Regex.match?(@registry_sha_regex, value)

      pattern when is_binary(pattern) ->
        false

      _ ->
        true
    end
  end

  defp validate_payload(descriptor, payload) do
    if Enum.all?(descriptor.required_data_keys, &match?({:ok, _}, fetch_field(payload, &1))) do
      :ok
    else
      {:error, :ERR_VALIDATION}
    end
  end

  defp ordered_values(fields, context, payload) do
    Enum.reduce_while(fields, {:ok, []}, fn field, {:ok, values} ->
      case ordered_value(field, context, payload) do
        {:ok, value} ->
          {:cont, {:ok, [[field, value] | values]}}

        :error ->
          {:halt, {:error, :ERR_VALIDATION}}
      end
    end)
    |> case do
      {:ok, values} -> {:ok, Enum.reverse(values)}
      error -> error
    end
  end

  defp ordered_value(field, context, payload) do
    case fetch_field(context, field) do
      {:ok, value} -> {:ok, value}
      :error -> fetch_field(payload, field)
    end
  end

  defp hash(value) do
    case CanonicalJSON.encode(value) do
      {:ok, canonical_json} ->
        {:ok, :crypto.hash(:sha256, canonical_json) |> Base.encode16(case: :lower)}

      {:error, :unsupported_value} ->
        {:error, :ERR_VALIDATION}
    end
  end

  defp fetch_field(map, field) do
    matches =
      Enum.filter(map, fn {key, _value} ->
        key == field or (is_atom(key) and Atom.to_string(key) == field)
      end)

    case matches do
      [{_key, value}] -> {:ok, value}
      _ -> :error
    end
  end

  defp attribute(descriptor, key) do
    case Map.fetch(descriptor, key) do
      {:ok, value} -> value
      :error -> Map.get(descriptor, Atom.to_string(key))
    end
  end
end
