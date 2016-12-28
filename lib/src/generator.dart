import 'dart:async';
import 'package:analyzer/analyzer.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:code_builder/code_builder.dart';
import 'package:source_gen/source_gen.dart';
import 'annotations.dart';
import 'package:source_gen/src/annotation.dart';
import 'util.dart';

final RegExp _template = new RegExp(r'Template$');

class AngelTemplateGenerator extends GeneratorForAnnotation<View> {
  const AngelTemplateGenerator();

  @override
  Future<String> generateForAnnotatedElement(
      Element element, View annotation, BuildStep buildStep) async {
    if (element is ClassElement) {
      if (!element.allSupertypes
          .any((type) => type.displayName == 'Template')) {
        throw new InvalidGenerationSourceError(
            'Views must implement Template.');
      }

      var className = element.type.name;
      var templateName =
          snake(className.replaceAll(_template, '')).toLowerCase();

      var fn = new MethodBuilder(templateName,
          returnType: new TypeBuilder('Future'))
        ..addPositional(parameter('req', [new TypeBuilder('RequestContext')]))
        ..addPositional(parameter('res', [new TypeBuilder('ResponseContext')]));

      Map<String, FieldElement> fields = element.fields
          .fold(<String, FieldElement>{},
              (Map<String, FieldElement> map, FieldElement field) {
        map[field.name] = field;
        return map;
      });

      // Collect inputs
      for (var name in fields.keys) {
        var field = fields[name];

        if (field.getter != null) {
          var type = field.type;

          for (var metadata in field.metadata) {
            var isInject = matchAnnotation(Inject, metadata);
            var isParam = matchAnnotation(Param, metadata);
            var isProp = matchAnnotation(Prop, metadata);
            String propertyName =
                metadata.constantValue.getField('name')?.toStringValue() ??
                    name;

            if (isInject) {
              if (type.name == 'RequestContext') {
                fn.addStatement(varField(name,
                    type: new TypeBuilder('RequestContext'),
                    value: reference('req')));
                continue;
              } else if (type.name == 'ResponseContext') {
                fn.addStatement(varField(name,
                    type: new TypeBuilder('ResponseContext'),
                    value: reference('res')));
                continue;
              }

              var injectedName =
                  metadata.constantValue.getField('name')?.toStringValue();

              if (injectedName == null) {
                fn.addStatement(varField(name,
                    type: new TypeBuilder(type.name),
                    value: reference('_getInjected')
                        .call([reference(type.name), reference('req')])));
              } else {
                fn.addStatement(varField(name,
                    type: new TypeBuilder(type.name),
                    value: reference('_getProp').call([
                      literal(propertyName),
                      reference('req').property('injections')
                    ])));
              }
            } else if (isParam) {
              fn.addStatement(varField(name,
                  type: new TypeBuilder(type.name),
                  value: reference('_getProp').call([
                    literal(propertyName),
                    reference('req').property('params')
                  ])));
            } else if (isProp) {
              fn.addStatement(varField(name,
                  type: new TypeBuilder(type.name),
                  value: reference('req').property(propertyName)));
            }
          }
        }
      }

      // Now, let's collect constructor params
      ConstructorElement constructor = element.constructors.firstWhere(
          (constructor) => constructor.name == annotation.constructorName,
          orElse: () => element.unnamedConstructor);

      List<String> positional = [], named = [];

      if (constructor != null) {
        for (var param in constructor.parameters) {
          if (param.parameterKind == ParameterKind.REQUIRED ||
              param.parameterKind == ParameterKind.POSITIONAL) {
            positional.add(param.name);
          } else if (param.parameterKind == ParameterKind.NAMED) {
            named.add(param.name);
          }
        }
      }

      // Next, instantiate template
      var res = reference('res');
      List<ExpressionBuilder> positionalArgs =
          positional.map(reference).toList();
      Map<String, ExpressionBuilder> namedArgs = {};

      named.forEach((arg) {
        namedArgs[arg] = reference(arg);
      });

      if (constructor?.name?.isNotEmpty != true) {
        fn.addStatement(varField(r'$$render',
            value: new TypeBuilder(element.name)
                .newInstance(positionalArgs, namedArgs)));
      } else {
        fn.addStatement(varField(r'$$render',
            value: new TypeBuilder(element.name).namedNewInstance(
                constructor.name, positionalArgs, namedArgs)));
      }

      fn
        ..addStatement(reference('ContentType')
            .property('HTML')
            .asAssign('contentType', target: res))
        ..addStatement(
            reference(r'$$render').invoke('render', []).invoke('then', [
          reference('_endWrite').call([res])
        ]).asReturn());

      return _getProp + prettyToSource(fn.buildAst());
    } else {
      throw new InvalidGenerationSourceError(
          'Cannot generate a view from a(n) ${element.runtimeType}.');
    }
  }
}

const String _getProp = '''
_getProp(String name, Map map) => map[name];

_getInjected(Type type, RequestContext req) {
  return req.injections[type] ?? req.app.container.make(type);
}

_endWrite(ResponseContext res) {
  return (content) async {
    res..write(content)..end();
    return false;
  };
}
''';
