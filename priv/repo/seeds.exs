alias AccTournament.Repo

alias AccTournament.Levels.{MapPool, Category, BeatMap}

Repo.insert!(%MapPool{
  id: 1,
  name: "Qualifiers",
  icon_id: "quali"
})

Repo.insert!(%Category{
  id: 1,
  name: "True Acc"
})

Repo.insert!(%Category{
  id: 2,
  name: "Standard Acc"
})

Repo.insert!(%Category{
  id: 3,
  name: "Tech Acc"
})

Repo.insert!(%BeatMap{
  name: "Reality Check Through The Skull",
  artist: "DM Dokuro",
  mapper: "rickput",
  beatsaver_id: "25f",
  hash: "AD6C9F88D63259A95E39397C31BE2981C4BEB744",
  difficulty: 9,
  max_score: 1_388_395,
  category_id: 1,
  map_pool_id: 1,
  map_type: "Standard"
})

Repo.insert!(%BeatMap{
  name: "Falling",
  artist: "INTERSECTION",
  mapper: "nolan121405",
  beatsaver_id: "16858",
  hash: "19AF73336A1C2FE788FF3DF0D93DB6E0BEAA0640",
  difficulty: 1,
  max_score: 387_435,
  category_id: 2,
  map_pool_id: 1,
  map_type: "Standard"
})
