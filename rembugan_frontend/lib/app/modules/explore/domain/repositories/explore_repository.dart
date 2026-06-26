import '../entities/competition.dart';
import '../entities/explore_person.dart';
import '../entities/project.dart';

abstract class ExploreRepository {
  Future<({List<Project> projects, int total})> getProjects({int page = 1, int limit = 15});
  Future<List<Competition>> getCompetitions();
  Future<List<ExplorePerson>> getRecommendedPeople();
  Future<List<ExplorePerson>> searchPeople(String query);
  Future<List<String>> getMyOfferingsSkills();
  Future<void> applyToProject(int projectId);
}
