class WordsModel {
  final List<String> data;

  WordsModel(this.data);

  factory WordsModel.fromMap(Map<String, dynamic> map) =>
      WordsModel(List<String>.from(map["data"] as List));

  Map<String, dynamic> toMap() => {
        "data": data,
      };

  bool get isNotEmpty => data.isNotEmpty;
}
