import 'package:build_runner/build_runner.dart';
import 'package:angel_template/angel_template.dart';
import 'package:source_gen/builder.dart';
import 'package:source_gen/generators/json_serializable_generator.dart';

final PhaseGroup phases = new PhaseGroup.singleAction(
    new GeneratorBuilder(const [
      const AngelTemplateGenerator(),
      const JsonSerializableGenerator()
    ]),
    new InputSet('example', const ['models/*.dart', 'views/*.dart']));