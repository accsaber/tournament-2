defmodule AccTournament.Qualifiers.AttemptWeighting do
  alias AccTournament.Repo
  alias AccTournament.Qualifiers.Attempt
  alias AccTournament.Levels.BeatMap
  use Oban.Worker

  def calculate_ap(accuracy, complexity) do
    cond do
      accuracy < 0 ->
        0

      accuracy > 100 ->
        1

      accuracy > 99.979 ->
        ((accuracy - 99.979) * 1.0573552615477281e-14 + 1) * (complexity + 18) * 61

      accuracy > 99.88 ->
        ((accuracy - 99.88) * 1.2016839751126442 + 0.8810332864638437) * (complexity + 18) * 61

      accuracy > 99.759 ->
        ((accuracy - 99.759) * 0.6047637181761618 + 0.8078568765645311) * (complexity + 18) * 61

      accuracy > 99.638 ->
        ((accuracy - 99.638) * 0.44523226593911813 + 0.7539837723859) * (complexity + 18) * 61

      accuracy > 99.519 ->
        ((accuracy - 99.519) * 0.35595808908355897 + 0.7116247597849565) * (complexity + 18) * 61

      accuracy > 99.398 ->
        ((accuracy - 99.398) * 0.29646767026937176 + 0.6757521716823598) * (complexity + 18) * 61

      accuracy > 99.277 ->
        ((accuracy - 99.277) * 0.2519596082622097 + 0.6452650590826337) * (complexity + 18) * 61

      accuracy > 99.157 ->
        ((accuracy - 99.157) * 0.22126016617414843 + 0.6187138391417348) * (complexity + 18) * 61

      accuracy > 99.036 ->
        ((accuracy - 99.036) * 0.19456164754764677 + 0.5951718797884705) * (complexity + 18) * 61

      accuracy > 98.915 ->
        ((accuracy - 98.915) * 0.1729521114793958 + 0.574244674299462) * (complexity + 18) * 61

      accuracy > 98.794 ->
        ((accuracy - 98.794) * 0.15748423303059558 + 0.555189082102763) * (complexity + 18) * 61

      accuracy > 98.675 ->
        ((accuracy - 98.675) * 0.14363221138457732 + 0.5380968489479963) * (complexity + 18) * 61

      accuracy > 98.553 ->
        ((accuracy - 98.553) * 0.1316025097051364 + 0.5220413427639696) * (complexity + 18) * 61

      accuracy > 98.433 ->
        ((accuracy - 98.433) * 0.12171602783320246 + 0.5074354194239865) * (complexity + 18) * 61

      accuracy > 98.312 ->
        ((accuracy - 98.312) * 0.11343110862480281 + 0.4937102552803843) * (complexity + 18) * 61

      accuracy > 98.193 ->
        ((accuracy - 98.193) * 0.10616293884948316 + 0.48107686555729584) * (complexity + 18) * 61

      accuracy > 98.071 ->
        ((accuracy - 98.071) * 0.09941629590296633 + 0.46894807745713396) * (complexity + 18) * 61

      accuracy > 97.951 ->
        ((accuracy - 97.951) * 0.09381002898952362 + 0.4576908739783907) * (complexity + 18) * 61

      accuracy > 97.83 ->
        ((accuracy - 97.83) * 0.08886447814724878 + 0.44693827212257403) * (complexity + 18) * 61

      accuracy > 97.71 ->
        ((accuracy - 97.71) * 0.08471190881857533 + 0.4367728430643446) * (complexity + 18) * 61

      accuracy > 97.59 ->
        ((accuracy - 97.59) * 0.08142435279042781 + 0.42700192072949406) * (complexity + 18) * 61

      accuracy > 97.468 ->
        ((accuracy - 97.468) * 0.07700626853603469 + 0.41760715596809783) * (complexity + 18) * 61

      accuracy > 97.348 ->
        ((accuracy - 97.348) * 0.07454342156869201 + 0.40866194537985445) * (complexity + 18) * 61

      accuracy > 97.228 ->
        ((accuracy - 97.228) * 0.07202041345406794 + 0.400019495765367) * (complexity + 18) * 61

      accuracy > 97.107 ->
        ((accuracy - 97.107) * 0.06907469248475659 + 0.3916614579747108) * (complexity + 18) * 61

      accuracy > 96.986 ->
        ((accuracy - 96.986) * 0.06687582741115491 + 0.3835694828579614) * (complexity + 18) * 61

      accuracy > 96.865 ->
        ((accuracy - 96.865) * 0.06490443113825661 + 0.37571604669023173) * (complexity + 18) * 61

      accuracy > 96.745 ->
        ((accuracy - 96.745) * 0.06353393161393914 + 0.36809197489655965) * (complexity + 18) * 61

      accuracy > 96.624 ->
        ((accuracy - 96.624) * 0.061264930326765256 + 0.3606789183270205) * (complexity + 18) * 61

      accuracy > 96.505 ->
        ((accuracy - 96.505) * 0.06052135584375013 + 0.35347687698161423) * (complexity + 18) * 61

      accuracy > 96.384 ->
        ((accuracy - 96.384) * 0.05861112765172669 + 0.3463849305357556) * (complexity + 18) * 61

      accuracy > 96.262 ->
        ((accuracy - 96.262) * 0.05722829136320526 + 0.33940307898944455) * (complexity + 18) * 61

      accuracy > 96.143 ->
        ((accuracy - 96.143) * 0.05658939514562126 + 0.33266894096711563) * (complexity + 18) * 61

      accuracy > 96.022 ->
        ((accuracy - 96.022) * 0.05542656444166482 + 0.3259623266696737) * (complexity + 18) * 61

      accuracy > 95.902 ->
        ((accuracy - 95.902) * 0.05451226623434275 + 0.31942085472155307) * (complexity + 18) * 61

      accuracy > 95.78 ->
        ((accuracy - 95.78) * 0.05339301822322665 + 0.3129069064983194) * (complexity + 18) * 61

      accuracy > 95.66 ->
        ((accuracy - 95.66) * 0.052983170407286236 + 0.30654892604944484) * (complexity + 18) * 61

      accuracy > 95.54 ->
        ((accuracy - 95.54) * 0.05221862249376647 + 0.30028269135019336) * (complexity + 18) * 61

      accuracy > 95.419 ->
        ((accuracy - 95.419) * 0.0515595948294562 + 0.2940439803758287) * (complexity + 18) * 61

      accuracy > 95.298 ->
        ((accuracy - 95.298) * 0.05087718842730763 + 0.2878878405761247) * (complexity + 18) * 61

      accuracy > 95.177 ->
        ((accuracy - 95.177) * 0.05057389669301623 + 0.28176839907627) * (complexity + 18) * 61

      accuracy > 95.057 ->
        ((accuracy - 95.057) * 0.05023079791859568 + 0.2757407033260383) * (complexity + 18) * 61

      accuracy > 94.936 ->
        ((accuracy - 94.936) * 0.049588198556565294 + 0.2697405313006934) * (complexity + 18) * 61

      accuracy > 94.816 ->
        ((accuracy - 94.816) * 0.04961915958778107 + 0.26378623215016017) * (complexity + 18) * 61

      accuracy > 94.696 ->
        ((accuracy - 94.696) * 0.04893106646560359 + 0.2579145041742875) * (complexity + 18) * 61

      accuracy > 94.575 ->
        ((accuracy - 94.575) * 0.048981615087988775 + 0.2519877287486411) * (complexity + 18) * 61

      accuracy > 94.455 ->
        ((accuracy - 94.455) * 0.04862524730019335 + 0.2461526990726177) * (complexity + 18) * 61

      accuracy > 94.334 ->
        ((accuracy - 94.334) * 0.04852667748654666 + 0.2402809710967451) * (complexity + 18) * 61

      accuracy > 94.213 ->
        ((accuracy - 94.213) * 0.04814756281869433 + 0.234455115995684) * (complexity + 18) * 61

      accuracy > 94.093 ->
        ((accuracy - 94.093) * 0.048472337717488344 + 0.22863843546958518) * (complexity + 18) *
          61

      accuracy > 93.972 ->
        ((accuracy - 93.972) * 0.04822338575225575 + 0.22280340579356178) * (complexity + 18) * 61

      accuracy > 93.852 ->
        ((accuracy - 93.852) * 0.04809006376073129 + 0.2170325981422745) * (complexity + 18) * 61

      accuracy > 93.731 ->
        ((accuracy - 93.731) * 0.04822338575225598 + 0.21119756846625107) * (complexity + 18) * 61

      accuracy > 93.61 ->
        ((accuracy - 93.61) * 0.04814756281868868 + 0.20537171336518997) * (complexity + 18) * 61

      accuracy > 93.49 ->
        ((accuracy - 93.49) * 0.04862524730019335 + 0.19953668368916655) * (complexity + 18) * 61

      true ->
        accuracy * 0.00213926623 * (complexity + 18) * 61
    end
  end

  @impl Oban.Worker
  def perform(%Oban.Job{
        args: %{"map_id" => map_id}
      }) do
    import Ecto.Query, only: [from: 2, where: 2]

    {:ok, %{attempts: attempts, map: map}} =
      Ecto.Multi.new()
      |> Ecto.Multi.all(
        :attempts,
        from(a in Attempt, where: not is_nil(a.score), where: a.map_id == ^map_id)
      )
      |> Ecto.Multi.one(:map, BeatMap |> where(id: ^map_id))
      |> Repo.transaction()

    attempts =
      Repo.transaction(fn ->
        for attempt <- attempts do
          acc = attempt.score / map.max_score * 100

          attempt
          |> Attempt.weight_changeset(%{weight: calculate_ap(acc, map.complexity)})
          |> Repo.update()
        end
      end)

    Phoenix.PubSub.broadcast(AccTournament.PubSub, "new_scores", {:new_scores, map.id})

    AccTournament.Qualifiers.PlayerWeighting.new(%{}) |> Oban.insert()

    {:ok, attempts}
  end
end
