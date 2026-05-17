import '../entities/competition.dart';
import '../entities/project.dart';

abstract class ExploreRepository {
  List<Project> getProjects();
  List<Competition> getCompetitions();
}
