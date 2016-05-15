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
  description: "What about IdeaZone? Is this an usefool tool? Do you find it sufficient for your needs? What could be improved? Do not hesitate to make it better by adding comments and vote for this question!",
  language: "en",
  status: "in_progress",
  type_id: 1
}
Repo.insert! %Comment{
  text: "I do not know if IdeaZone is a great idea, but this question is!",
  content_id: 1
}
Repo.insert! %Comment{
  text: "That's an useless comment.",
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
  label: "Une idée !",
  description: "Multilingue ! IdeaZone devrait être traduit dans d'autres langues et devrait pouvoir gérer du contenu dans d'autres langues également. La recherche plein texte devrait également gérer correctement les langues, car elle ne peut pas être efficace sans cela.",
  official_answer: "IdeaZone est pour l'instant en anglais dans l'interface et sait gérer du contenu en Français pour ce qui est de la recherche plein texte. Des textes en anglais pourraient également être gérer, mais il manque à ce jour la fonctionnalité pour permettre de détecter (ou d'indiquer) que le texte n'est pas en Français. Tout nouveau contenu sera considéré comme étant en Français pour le moment (cf. attribut \"language\" du modèle \"Content\").",
  language: "fr",
  status: "solved",
  type_id: 2
}
Repo.insert! %Comment{
  text: "C'est dommage !",
  content_id: 2
}
Repo.insert! %Comment{
  text: "Il faudrait un système de détection de la langue du texte pour améliorer la recherche !",
  content_id: 2
}
Repo.insert! %Vote{
  user_session_token: "0123456789",
  content_id: 2,
  vote_type: "for"
}

Repo.insert! %Content{
  label: "A problematic problem",
  description: "This is a problem. A big one.",
  language: "en",
  status: "new",
  type_id: 3
}
