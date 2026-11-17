defmodule Ticketing.Outbox.CanonicalJSONTest do
  use ExUnit.Case, async: true

  alias Ticketing.Outbox.CanonicalJSON

  @contract_path Path.expand(
                   "../../../../authority/contracts/SEC-1/extracted/SEC-1_Contract_v3.5.0.json",
                   __DIR__
                 )
  @vectors @contract_path
           |> File.read!()
           |> Jason.decode!()
           |> get_in(["crypto_primitives", "canonical_json", "conformance_vectors"])

  test "matches the installed SEC-1 JCS vectors byte-for-byte and by SHA-256" do
    assert Enum.map(@vectors, & &1["id"]) ==
             Enum.map(1..10, &"JCS-#{String.pad_leading(to_string(&1), 4, "0")}")

    Enum.each(@vectors, fn vector ->
      input = Jason.decode!(vector["input_json_text"])

      assert {:ok, canonical_json} = CanonicalJSON.encode(input)
      assert canonical_json == vector["expected_canonical_json"], vector["id"]

      assert Base.url_encode64(canonical_json, padding: false) ==
               vector["expected_utf8_bytes_b64url"],
             vector["id"]

      assert :crypto.hash(:sha256, canonical_json)
             |> Base.encode16(case: :lower) == vector["expected_sha256_hex"],
             vector["id"]
    end)
  end

  test "rejects terms outside the JSON value model" do
    assert {:error, :unsupported_value} = CanonicalJSON.encode(%{value: :not_json})
    assert {:error, :unsupported_value} = CanonicalJSON.encode([:valid_prefix | :improper_tail])
  end

  test "formats binary64 numbers at ECMAScript notation boundaries" do
    assert {:ok, "0"} = CanonicalJSON.encode(-0.0)
    assert {:ok, "1.5"} = CanonicalJSON.encode(1.5)
    assert {:ok, "100"} = CanonicalJSON.encode(100.0)
    assert {:ok, "0.000001"} = CanonicalJSON.encode(1.0e-6)
    assert {:ok, "1e-7"} = CanonicalJSON.encode(1.0e-7)
    assert {:ok, "100000000000000000000"} = CanonicalJSON.encode(1.0e20)
    assert {:ok, "1e+21"} = CanonicalJSON.encode(1.0e21)
    assert {:ok, "9007199254740992"} = CanonicalJSON.encode(9_007_199_254_740_993)
  end
end
