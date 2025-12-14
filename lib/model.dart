import 'dart:convert';

List<Candidate> candidateListFromJson(String str) =>
    List<Candidate>.from(json.decode(str).map((x) => Candidate.fromJson(x)));

List<AssignmentStatus> assignmentStatusListFromJson(String str) =>
    List<AssignmentStatus>.from(json.decode(str).map((x) => AssignmentStatus.fromJson(x)));

class Candidate {
  final String name;
  final String applied1;
  final String applied2;
  final String? applied3;
  final String comment;
  final String transcriptUrl;

  // Key: Department Name, Value: Status ("confirmed", "candidate")
  Map<String, String> assigned;

  Candidate({
    required this.name,
    required this.applied1,
    required this.applied2,
    this.applied3,
    required this.comment,
    required this.transcriptUrl,
    required this.assigned,
  });

  factory Candidate.fromJson(Map<String, dynamic> json) => Candidate(
    name: json["name"],
    applied1: json["applied1"],
    applied2: json["applied2"],
    applied3: json["applied3"],
    comment: json["comment"],
    transcriptUrl: json["transcript_url"] ?? "",
    assigned: Map<String, String>.from(json["assigned"]),
  );

  List<String> get appliedList {
    List<String> list = [applied1, applied2];
    if (applied3 != null) list.add(applied3!);
    return list;
  }
}

class AssignmentStatus {
  final String name;
  final Map<String, String> assigned;

  AssignmentStatus({required this.name, required this.assigned});

  factory AssignmentStatus.fromJson(Map<String, dynamic> json) => AssignmentStatus(
    name: json["name"],
    assigned: Map<String, String>.from(json["assigned"]),
  );
}