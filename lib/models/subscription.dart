class Subscription {
  final String name;
  final String desc;
  final List<dynamic> plans;
  Subscription(this.name, this.desc, this.plans);
  factory Subscription.fromJson(
      {required name,
      required String desc,
      required List<dynamic> plans}) {
    return Subscription(name, desc, plans);
  }
}
