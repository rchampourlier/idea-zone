# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     IdeaZone.Repo.insert!(%SomeModel{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias IdeaZone.Repo
alias IdeaZone.Comment
alias IdeaZone.Content
alias IdeaZone.ContentType
alias IdeaZone.Vote

Repo.insert! %ContentType{label: "Question"}
Repo.insert! %ContentType{label: "Idea"}
Repo.insert! %ContentType{label: "Problem"}

Repo.insert! %Content{
  label: "A simple question",
  description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etsi qui potest intellegi aut cogitari esse aliquod animal, quod se oderit? Habent enim et bene longam et satis litigiosam disputationem. Quod idem cum vestri faciant, non satis magnam tribuunt inventoribus gratiam. Nihil ad rem! Ne sit sane; Non quam nostram quidem, inquit Pomponius iocans; Qui-vere falsone, quaerere mittimus-dicitur oculis se privasse; Duo Reges: constructio interrete.",
  language: "en",
  status: "in_progress",
  type_id: 1
}
Repo.insert! %Comment{
  text: "A comment to say this is an excellent question. Or idea.",
  content_id: 1
}
Repo.insert! %Comment{
  text: "Another comment. So short :(",
  content_id: 1
}
Repo.insert! %Vote{
  user_session_token: "0123456789",
  content_id: 1,
  vote_type: "against"
}
Repo.insert! %Vote{
  user_session_token: "1234567890",
  content_id: 1,
  vote_type: "for"
}
Repo.insert! %Vote{
  user_session_token: "2345678901",
  content_id: 1,
  vote_type: "for"
}

Repo.insert! %Content{
  label: "A problem",
  description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etsi qui potest intellegi aut cogitari esse aliquod animal, quod se oderit? Habent enim et bene longam et satis litigiosam disputationem. Quod idem cum vestri faciant, non satis magnam tribuunt inventoribus gratiam. Nihil ad rem! Ne sit sane; Non quam nostram quidem, inquit Pomponius iocans; Qui-vere falsone, quaerere mittimus-dicitur oculis se privasse; Duo Reges: constructio interrete.",
  official_answer: "Official answer from officials: \"There is no problem!\"",
  language: "en",
  status: "solved",
  type_id: 2
}
Repo.insert! %Comment{
  text: "I don't like that either",
  content_id: 2
}
Repo.insert! %Comment{
  text: "I support this problem.",
  content_id: 2
}
Repo.insert! %Vote{
  user_session_token: "0123456789",
  content_id: 2,
  vote_type: "for"
}
