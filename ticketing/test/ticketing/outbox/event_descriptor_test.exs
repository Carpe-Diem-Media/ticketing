defmodule Ticketing.Outbox.EventDescriptorTest do
  use ExUnit.Case, async: true

  alias Ticketing.Outbox.EventDescriptor

  @published_type "ticketing.event.published.v1"
  @archived_type "ticketing.event.archived.v1"
  @evt1_path Path.expand(
               "../../../../authority/contracts/EVT-1/extracted/EVT-1_Contract_v3.0.0.json",
               __DIR__
             )
  @evt1 @evt1_path |> File.read!() |> Jason.decode!()
  @registry %{
    "event_types" => Map.take(@evt1["event_types"], [@published_type, @archived_type]),
    "event_envelope" => @evt1["event_envelope"]
  }
  @context %{
    "org_id" => "org_00000000000000000000000001",
    "trace_id" => "trace-0001",
    "request_id" => "request-0001",
    "registry_version_sha" => String.duplicate("a", 64)
  }

  test "registers a static descriptor only when it matches EVT-1" do
    assert {:ok, descriptor} = EventDescriptor.register(descriptor(@published_type), @registry)

    assert descriptor.event_type == @published_type
    assert descriptor.registry_source == "derived_from_ash_resource"
    assert descriptor.topic == "ticketing.event"
    assert descriptor.dedupe_window_seconds == 45 * 24 * 60 * 60
    assert descriptor.ordering_mode == :monotonic
  end

  test "rejects unknown event types with the canonical EVT error" do
    invalid = Map.put(descriptor(@published_type), :event_type, "ticketing.unknown.v1")

    assert {:error, :EVT_INVALID_TYPE} = EventDescriptor.register(invalid, @registry)
  end

  test "rejects registry facts that differ from EVT-1" do
    descriptor = descriptor(@published_type)

    invalid_descriptors = [
      Map.put(descriptor, :registry_source, "explicit_json_schema"),
      Map.put(descriptor, :topic, "ticketing.other"),
      Map.update!(descriptor, :required_data_keys, &Enum.drop(&1, -1)),
      Map.update!(descriptor, :dedupe_key_fields, &Enum.reverse/1),
      Map.update!(descriptor, :dedupe_window_seconds, &(&1 + 1)),
      Map.update!(descriptor, :ordering_key_fields, &Enum.reverse/1)
    ]

    assert Enum.all?(invalid_descriptors, fn invalid ->
             EventDescriptor.register(invalid, @registry) == {:error, :EVT_INVALID_TYPE}
           end)
  end

  test "rejects an unsupported ordering mode during registration" do
    invalid = Map.put(descriptor(@published_type), :ordering_mode, :lexicographic)

    assert {:error, :EVT_INVALID_TYPE} = EventDescriptor.register(invalid, @registry)
  end

  test "does not accept extra static fields such as production handlers" do
    invalid = Map.put(descriptor(@published_type), :handler, fn _event -> :ok end)

    assert {:error, :EVT_INVALID_TYPE} = EventDescriptor.register(invalid, @registry)
  end

  test "requires canonical envelope context and all required payload fields" do
    assert {:ok, descriptor} = EventDescriptor.register(descriptor(@published_type), @registry)
    payload = %{"event_id" => "event-0001", "version" => 1}

    assert {:error, :EVT_CONTEXT_MISSING} =
             EventDescriptor.digests(descriptor, Map.delete(@context, "trace_id"), payload)

    invalid_registry_sha =
      Map.put(@context, "registry_version_sha", String.duplicate("a", 64) <> "\n")

    assert {:error, :EVT_CONTEXT_MISSING} =
             EventDescriptor.digests(descriptor, invalid_registry_sha, payload)

    assert {:error, :ERR_VALIDATION} =
             EventDescriptor.digests(descriptor, @context, %{"event_id" => "event-0001"})
  end

  test "binds dedupe digests to the event type and shares ordering streams across types" do
    assert {:ok, published} = EventDescriptor.register(descriptor(@published_type), @registry)
    assert {:ok, archived} = EventDescriptor.register(descriptor(@archived_type), @registry)

    published_payload = %{"event_id" => "event-0001", "version" => 3}

    archived_payload = %{
      "event_id" => "event-0001",
      "archived_at_utc" => "2026-11-17T00:00:00Z",
      "version" => 3
    }

    assert {:ok, published_hashes} =
             EventDescriptor.digests(published, @context, published_payload)

    assert {:ok, archived_hashes} = EventDescriptor.digests(archived, @context, archived_payload)

    assert published_hashes.dedupe_key_sha256 ==
             "e5295f8338a829f60514a4faf1f144de02af721e72f731caeb9ce82457b87f95"

    assert published_hashes.ordering_key_sha256 ==
             "8bb940f8b835fc1034c8888c7305bf0b49dcdd9f83ba8bacfce3e07042bd25bc"

    refute published_hashes.dedupe_key_sha256 == archived_hashes.dedupe_key_sha256
    assert published_hashes.ordering_key_sha256 == archived_hashes.ordering_key_sha256

    reordered_context = Map.new(Enum.reverse(Map.to_list(@context)))
    reordered_payload = Map.new(Enum.reverse(Map.to_list(published_payload)))

    assert {:ok, ^published_hashes} =
             EventDescriptor.digests(published, reordered_context, reordered_payload)
  end

  defp descriptor(event_type) do
    entry = @registry["event_types"][event_type]
    ordering = entry["ordering"]

    %{
      event_type: event_type,
      registry_source: entry["schema_governance"]["source"],
      topic: entry["topic"],
      required_data_keys: entry["required_data_keys"],
      dedupe_key_fields: entry["idempotency"]["dedupe_key"],
      dedupe_window_seconds: entry["idempotency"]["dedupe_window_days"] * 24 * 60 * 60,
      ordering_key_fields: ordering["ordering_key"] || ordering["key"],
      ordering_mode: :monotonic
    }
  end
end
