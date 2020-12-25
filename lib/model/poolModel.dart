class Pool {
  String value;
  List<String> votes;
  Pool({this.value, this.votes});

  toJson() {
    return {'value': value, 'votes': votes};
  }
}
