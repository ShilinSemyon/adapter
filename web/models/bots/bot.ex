defmodule Adapter.Bots.Bot do
  @moduledoc """
    The Bots schema and validation
  """

  use Adapter.Web, :model
  alias Adapter.Bots
  alias Adapter.Bots.Bot

  schema "bots" do
    field :uid, :string
    field :token, :string
    field :state, :string

    belongs_to :messenger, Adapter.Messengers.Messenger

    timestamps()
  end

  @doc false
  def changeset(bot, attrs) do
    bot
    |> cast(attrs, [:uid, :token, :state])
    |> validate_required([:uid, :token])
    |> validate_unique_record(:uid)
    |> validate_unique_record(:token)
  end

  def validate_unique_record(changeset, field, _opts \\ []) do
    validate_change(changeset, field, fn f, value ->
      case Bots.get_by_bot(%{f => "#{value}"}) do
        %Bot{} -> ["#{f}": {"#{f} not unique", []}]
        _ -> []
      end
    end)
  end
end
