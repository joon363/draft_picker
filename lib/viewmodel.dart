import 'package:flutter/material.dart';
import 'model.dart';
import 'api_service.dart';

class InterviewViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Candidate> _candidates = [];
  Candidate? _selectedCandidate;
  bool _isLoading = true;

  List<Candidate> get candidates => _candidates;
  Candidate? get selectedCandidate => _selectedCandidate;
  bool get isLoading => _isLoading;

  InterviewViewModel() {
    _initData();
  }

  Future<void> _initData() async {
    _candidates = await _apiService.fetchInitialCandidates();
    _isLoading = false;
    notifyListeners();

    _apiService.connectSocket();
    _apiService.assignmentStream.listen((statusList) {
      _updateAssignments(statusList);
    });
  }

  void _updateAssignments(List<AssignmentStatus> statusList) {
    bool needUpdate = false;
    for (var status in statusList) {
      try {
        final candidate = _candidates.firstWhere((c) => c.name == status.name);
        candidate.assigned = status.assigned;
        needUpdate = true;
      } catch (e) {
        // ignore
      }
    }
    if (needUpdate) notifyListeners();
  }

  void selectCandidate(Candidate candidate) {
    _selectedCandidate = candidate;
    notifyListeners();
  }

  void clearSelection() {
    _selectedCandidate = null;
    notifyListeners();
  }

  void toggleAssignment(String department, String status) {
    if (_selectedCandidate == null) return;
    _apiService.toggleAssignment(_selectedCandidate!.name, department, status);
  }

  // 특정 국, 특정 상태(옵션)의 지원자 반환
  List<Candidate> getCandidatesByDept(String deptName) {
    return _candidates.where((c) => c.assigned.containsKey(deptName)).toList();
  }

  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }
}