enum ExploreTab {
  project,
  competition,
  people;

  bool get isProject => this == ExploreTab.project;
  bool get isCompetition => this == ExploreTab.competition;
  bool get isPeople => this == ExploreTab.people;
}
