defmodule Moba.Accounts.Query.UserQuery do
  @moduledoc """
  Query functions for retrieving Users
  """

  alias Moba.Accounts
  alias Accounts.Schema.User

  import Ecto.Query

  @current_ranking_date Moba.current_ranking_date()
  @maximum_points_difference Moba.maximum_points_difference()

  def load(queryable \\ User) do
    queryable
  end

  def new_users(query \\ User, since_hours_ago \\ 24) do
    ago = Timex.now() |> Timex.shift(hours: -since_hours_ago)

    from(user in non_bots(query), where: user.inserted_at > ^ago, order_by: [desc: user.inserted_at])
  end

  def bots(query \\ User) do
    from(user in query, where: user.is_bot == true)
  end

  def non_bots(query \\ User) do
    from(user in query, where: user.is_bot == false)
  end

  def non_guests(query \\ User) do
    from(user in query, where: user.is_guest == false)
  end

  def guests(query \\ User) do
    from(user in query, where: user.is_guest == true)
  end

  def online_users(query \\ User, hours_ago \\ 1) do
    ago = Timex.now() |> Timex.shift(hours: -hours_ago)

    from(u in non_bots(query), where: u.last_online_at > ^ago)
  end

  def order_by_online(query) do
    from(u in query, order_by: [desc: u.last_online_at])
  end

  def online_before(query, days_ago) do
    ago = Timex.now() |> Timex.shift(days: -days_ago)

    from(u in query, where: u.last_online_at < ^ago)
  end

  def by_user(query \\ User, user) do
    from(u in query, where: u.id == ^user.id)
  end

  def with_status(query \\ User, status) do
    from(u in query, where: u.status == ^status)
  end

  def with_ids(query, ids) do
    from user in query, where: user.id in ^ids
  end

  def exclude_ids(query, ids) do
    from user in query, where: user.id not in ^ids
  end

  def ranking(limit) do
    from(user in User,
      where: not is_nil(user.ranking),
      order_by: [asc: user.ranking],
      limit: ^limit
    )
  end

  def eligible_for_ranking(limit) do
    from(u in User,
      order_by: [desc: [u.season_points, u.level, u.experience]],
      where: u.is_bot == false,
      where: u.is_guest == false,
      where: u.last_online_at > ^@current_ranking_date,
      limit: ^limit
    )
  end

  def by_ranking(query, min, max) do
    from user in query,
      where: user.ranking >= ^min,
      where: user.ranking <= ^max,
      order_by: [asc: user.ranking]
  end

  def by_level(query, level) do
    from user in query, where: user.level == ^level
  end

  def by_season_points do
    from(u in User, order_by: [desc: u.season_points])
  end

  def by_bot_tier(query, tier) do
    from(u in query, where: u.bot_tier == ^tier)
  end

  def eligible_arena_bots do
    from(u in by_season_points(), where: u.is_bot == true)
  end

  def bot_opponents(season_tier) do
    from bot in bots(),
      where: bot.season_tier <= ^season_tier + 1,
      order_by: [desc: bot.season_points]
  end

  def normal_opponents(season_tier, user_points) do
    from user in available_opponents(),
      where: user.season_tier <= ^season_tier,
      where: user.season_points > (^user_points - @maximum_points_difference),
      order_by: [desc: user.season_points]
  end

  def elite_opponents(season_tier, user_points) do
    from user in available_opponents(),
      where: user.season_tier >= ^season_tier,
      where: user.season_points < (^user_points + @maximum_points_difference),
      order_by: [asc: user.season_points]
  end

  def limit_by(query, limit) do
    from u in query, limit: ^limit
  end

  def random(query) do
    from user in query,
      order_by: fragment("RANDOM()")
  end

  def skynet_bot(timestamp) do
    base = bots() |> random() |> limit_by(1)

    from bot in base,
      where: is_nil(bot.last_online_at) or bot.last_online_at < ^timestamp
  end

  def available_opponents(query \\ User) do
    from user in non_guests(query), where: user.season_points > 0
  end

  def auto_matchmaking do
    base = non_bots() |> available_opponents() |> online_before(7) |> random() |> limit_by(1)

    from user in base, where: user.last_online_at > ^@current_ranking_date
  end
end
