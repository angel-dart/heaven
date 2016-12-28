library angel_template;

import 'package:source_gen/builder.dart';

import 'src/generator.dart';

export 'src/annotations.dart';
export 'src/generator.dart';
export 'src/template.dart';

class AngelTemplateBuilder extends GeneratorBuilder {
  AngelTemplateBuilder() : super([new AngelTemplateGenerator()]);
}
