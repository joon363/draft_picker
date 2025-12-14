import 'package:flutter/material.dart';
import 'model.dart';
import 'api_service.dart';
import 'dart:async';

class InterviewViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Candidate> _candidates = [];
  Candidate? _selectedCandidate;
  bool _isLoading = true;

  // ApiService의 ValueNotifier를 구독하여 상태를 받아옴
  SocketStatus _socketStatus = SocketStatus.disconnected;

  // --- [새로 추가된 필터 및 검색 상태] ---
  String? _filterDept; // null은 '전체'를 의미
  String _searchTerm = '';

  String? get filterDept => _filterDept;
  String get searchTerm => _searchTerm;

  // 필터링된 지원자 목록을 반환하는 Getter
  List<Candidate> get filteredCandidates {
    var list = _candidates;

    // 1. 지원국 필터 적용
    if (_filterDept != null && _filterDept != '전체') {
      list = list.where((c) => c.appliedList.contains(_filterDept!)).toList();
    }

    // 2. 이름 검색 필터 적용
    if (_searchTerm.isNotEmpty) {
      final term = _searchTerm.toLowerCase();
      list = list.where((c) => c.name.toLowerCase().contains(term)).toList();
    }

    return list;
  }
  // ------------------------------------

  List<Candidate> get candidates => _candidates;
  Candidate? get selectedCandidate => _selectedCandidate;
  bool get isLoading => _isLoading;

  // 외부에서 웹소켓 상태를 가져갈 수 있도록 Getter 추가
  SocketStatus get socketStatus => _socketStatus;

  InterviewViewModel() {
    // 1. 초기 데이터 로드 및 웹소켓 연결 시작
    _initData();

    // 2. 웹소켓 상태 변화를 구독 (addListener는 void 반환이므로 변수에 할당하지 않음)
    _apiService.socketStatus.addListener(_onSocketStatusChanged);
  }

  // 상태 변경 리스너
  void _onSocketStatusChanged() {
    _socketStatus = _apiService.socketStatus.value;
    notifyListeners();
  }

  Future<void> _initData() async {
    _candidates = await _apiService.fetchInitialCandidates();
    _isLoading = false;
    notifyListeners();

    // 웹소켓 연결 및 스트림 구독 시작
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

  // --- [새로 추가된 필터/검색 설정 메소드] ---
  void setFilterDepartment(String? dept) {
    _filterDept = dept;
    notifyListeners();
  }

  void setSearchTerm(String term) {
    _searchTerm = term.trim();
    notifyListeners();
  }
  // ----------------------------------------

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
    // ValueNotifier 리스너 해제
    _apiService.socketStatus.removeListener(_onSocketStatusChanged);
    _apiService.dispose();
    super.dispose();
  }
}