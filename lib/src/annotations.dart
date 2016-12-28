class View {
  final String constructorName;
  const View({this.constructorName});
}

class Inject {
  final String name;
  const Inject([this.name]);
}

class Param extends Inject {
  final String name;
  const Param([this.name]);
}

class Prop extends Inject {
  final String name;
  const Prop([this.name]);
}