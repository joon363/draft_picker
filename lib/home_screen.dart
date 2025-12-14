import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'viewmodel.dart';
import 'model.dart';
import 'api_service.dart'; // SocketStatus를 사용하기 위해 import 추가

const Color backGroundDark = Color(0xFF080810);
const Color backGround = Color(0xFF151519);

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<InterviewViewModel>();

    if (viewModel.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: backGroundDark,
      // Stack을 사용하여 Row 위에 상태 표시 위젯을 띄웁니다.
      body: Stack(
        children: [
          Row(
            children: [
              Expanded(flex: 1, child: const LeftPanel()),
              const VerticalDivider(width: 1),
              Expanded(flex: 2, child: const MiddlePanel()),
              const VerticalDivider(width: 1),
              Expanded(flex: 1, child: const RightPanel()),
            ],
          ),
          // 웹소켓 상태 표시 위젯 (화면 맨 위에 위치)
          Positioned(
            top: 10,
            right: 10,
            child: _buildSocketStatusIndicator(viewModel.socketStatus),
          ),
        ],
      ),
    );
  }

  // 웹소켓 상태에 따라 다른 위젯을 반환하는 헬퍼 함수
  Widget _buildSocketStatusIndicator(SocketStatus status) {
    String text;
    Color color;
    IconData icon;

    switch (status) {
      case SocketStatus.connected:
        text = "연결됨";
        color = Colors.green.shade600;
        icon = Icons.check_circle_outline;
        break;
      case SocketStatus.connecting:
        text = "연결 중...";
        color = Colors.orange.shade600;
        icon = Icons.settings_ethernet;
        break;
      case SocketStatus.disconnected:
      default:
        text = "연결 끊김 (재시도 중)";
        color = Colors.red.shade600;
        icon = Icons.signal_wifi_off;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.5),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// --- 공통 상수 및 헬퍼 ---
const List<String> realDepartments = [
  "1. 사무총괄국",
  "2. 재정관리국",
  "3. 소통연결국",
  "4. 대외협력국",
  "5. 나눔복지국",
  "6. 문화기획국",
  "7. 비서실",
  "8. 미래전략실",
];

const List<String> specialDepartments = [
  "탈락",
  "보류",
];

const List<String> allDepartments = [
  "1. 사무총괄국",
  "2. 재정관리국",
  "3. 소통연결국",
  "4. 대외협력국",
  "5. 나눔복지국",
  "6. 문화기획국",
  "7. 비서실",
  "8. 미래전략실",
  "탈락",
  "보류",
];



Color getDeptColor(String dept) {
  final colors = [
    Colors.redAccent, Colors.orangeAccent, Colors.amber, Colors.green,
    Colors.teal, Colors.blue, Colors.indigo, Colors.purple,
    Colors.grey, Colors.blueGrey
  ];
  int index = allDepartments.indexOf(dept);
  if (index == -1) return Colors.black;
  return colors[index % colors.length];
}

Widget buildProfileImage(String name, {double size = 50, bool isSquare = true}) {
  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: Colors.grey[300],
      shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
      borderRadius: isSquare ? BorderRadius.circular(8) : null,
      image: DecorationImage(
        image: AssetImage('assets/images/$name.png'),
        fit: BoxFit.cover,
      ),
    ),
  );
}


// --- 왼쪽 패널 ---
class LeftPanel extends StatelessWidget {
  const LeftPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<InterviewViewModel>();
    final allDepts = [...realDepartments, ...specialDepartments];

    // 이 메서드 내부에 _buildMiniProfile을 정의하여 viewModel을 캡처합니다.
    Widget buildMiniProfile(Candidate c) {
      // 현재 선택된 지원자인지 확인
      final isSelected = viewModel.selectedCandidate?.name == c.name;

      return GestureDetector(
        onTap: () {
          // 지원자 선택 로직 호출
          context.read<InterviewViewModel>().selectCandidate(c);
        },
        child: Container(
          width: 70,
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.all(4), // 테두리 및 그림자 공간 확보
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            // 선택된 경우 파란색 테두리 추가
            border: Border.all(
              color: isSelected ? Colors.blue : Colors.transparent,
              width: 2,
            ),
            color: isSelected ? Colors.blue.withOpacity(0.15) : Colors.transparent, // 선택 배경색
          ),
          child: Column(
            children: [
              buildProfileImage(c.name, size: 42, isSquare: true), // 크기 약간 줄여서 공간 확보
              const SizedBox(height: 2),
              Text(c.name, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10)), // 폰트 크기 줄여서 공간 확보
            ],
          ),
        ),
      );
    }

    return Container(
      color: backGroundDark,
      child: ListView.builder(
        itemCount: allDepts.length,
        itemBuilder: (context, index) {
          final dept = allDepts[index];
          final candidates = viewModel.getCandidatesByDept(dept);

          // --- 새로운 로직: 국 전체 테두리 색상 결정 ---
          Color containerColor = backGround;
          bool hasConfirmedConflict = false;
          bool hasCandidateConflict = false;

          for (var candidate in candidates) {
            // 1. 중복 확정 체크 (빨간색)
            int confirmedInOtherDepts = candidate.assigned.values.where((s) => s == 'confirmed').length;
            if (candidate.assigned.containsKey(dept) && confirmedInOtherDepts >= 2) {
              hasConfirmedConflict = true;
              break;
            }
          }

          // 2. 중복 후보 체크 (주황색, 확정 충돌이 없을 경우에만)
          if (!hasConfirmedConflict) {
            for (var candidate in candidates) {
              int candidateInOtherDepts = candidate.assigned.values.where((s) => s == 'candidate').length;
              if (candidate.assigned.containsKey(dept) && candidateInOtherDepts >= 2) {
                hasCandidateConflict = true;
                break;
              }
            }
          }

          if (hasConfirmedConflict) {
            containerColor = Colors.red.withOpacity(0.4);
          } else if (hasCandidateConflict) {
            containerColor = Colors.orange.withOpacity(0.4);
          }
          // ----------------------------------------

          // 정렬 및 그룹화: 확정(confirmed) -> 구분선 -> 후보(candidate)
          final confirmedList = candidates.where((c) => c.assigned[dept] == "confirmed").toList();
          final candidateList = candidates.where((c) => c.assigned[dept] == "candidate").toList();

          return Container(
            height: 122,
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
                color: containerColor, // 결정된 배경색 적용
                borderRadius: BorderRadius.circular(12)
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dept,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      // 텍스트 색상도 강조
                      color: hasConfirmedConflict ? Colors.red.shade700 : (hasCandidateConflict ? Colors.orange.shade700 : Colors.white)
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      // 1. 확정 리스트
                      ...confirmedList.map((c) => buildMiniProfile(c)),

                      // 2. 검은색 구분선 (항상 존재)
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        width: 2,
                        color: Colors.white70,
                      ),

                      // 3. 후보 리스트
                      ...candidateList.map((c) => buildMiniProfile(c)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// --- 가운데 패널 ---
class MiddlePanel extends StatelessWidget {
  const MiddlePanel({super.key});

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $uri');
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<InterviewViewModel>();
    final candidate = viewModel.selectedCandidate;

    if (candidate == null) {
      return const Center(child: Text("지원자를 선택해 정보 보기"));
    }

    // 테두리 로직 계산
    int confirmedCount = 0;
    int candidateCount = 0;

    candidate.assigned.forEach((dept, status) {
      if (realDepartments.contains(dept)) {
        if (status == 'confirmed') confirmedCount++;
        if (status == 'candidate') candidateCount++;
      }
    });

    Color globalBorderColor = Colors.transparent;

    if (confirmedCount >= 2) {
      globalBorderColor = Colors.red;
    } else if (confirmedCount < 2 && candidateCount >= 2) { // 확정 충돌이 없을 때만 후보 충돌 검사
      globalBorderColor = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      //color: Colors.white,
      child: Column(
        // crossAxisAlignment: CrossAxisAlignment.stretch, // Column의 children이 stretch 되도록 설정
        // mainAxisAlignment: MainAxisAlignment.start,
        children: [
          buildProfileImage(candidate.name, size: 120, isSquare: true),
          Text(candidate.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),

          Wrap(
            spacing: 8,
            children: candidate.appliedList.map((dept) => Chip(
              label: Text(dept, style: const TextStyle(color: Colors.white)),
              backgroundColor: getDeptColor(dept),
            )).toList(),
          ),


          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("면접 코멘트", style: TextStyle(fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                onPressed: () {
                  if (candidate.transcriptUrl.isNotEmpty) {
                    _launchURL(candidate.transcriptUrl);
                  }
                },
                icon: const Icon(Icons.description, size: 16),
                label: const Text("속기록 보기"),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[800],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    textStyle: const TextStyle(fontSize: 12)
                ),
              )
            ],
          ),

          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: backGround,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!)
              ),
              child: SingleChildScrollView(
                child: SelectableText(candidate.comment, style: const TextStyle(fontSize: 16)),
              ),
            ),
          ),


          // 8개 국 버튼
          GridView.builder(
            itemCount: 8,
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 3.0,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemBuilder: (context, index) {
              return HoverDeptButton(
                deptName: realDepartments[index],
                candidate: candidate,
                globalBorderColor: globalBorderColor,
              );
            },
          ),

          // 탈락/보류 버튼 (단순 버튼)
          Row(
            children: [
              Expanded(child: SimpleDeptButton(deptName: "탈락", candidate: candidate)),
              const SizedBox(width: 10),
              Expanded(child: SimpleDeptButton(deptName: "보류", candidate: candidate)),
            ],
          )
        ],
      ),
    );
  }
}

// --- 마우스 호버 시 분리되는 버튼 (확정/후보) ---
class HoverDeptButton extends StatefulWidget {
  final String deptName;
  final Candidate candidate;
  final Color globalBorderColor;

  const HoverDeptButton({
    super.key,
    required this.deptName,
    required this.candidate,
    required this.globalBorderColor,
  });

  @override
  State<HoverDeptButton> createState() => _HoverDeptButtonState();
}

class _HoverDeptButtonState extends State<HoverDeptButton> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    String? currentStatus = widget.candidate.assigned[widget.deptName];
    bool isAssigned = currentStatus =="confirmed";
    bool isCandidate = currentStatus == "candidate";
    Color baseColor = getDeptColor(widget.deptName);

    Color borderColor = Colors.transparent;
    double borderWidth = 0.0;

    if (isAssigned || isCandidate) {
      borderWidth = 4.0;
      borderColor = widget.globalBorderColor == Colors.transparent
          ? isCandidate?Colors.white70:Colors.white
          : widget.globalBorderColor;
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: baseColor.withOpacity(isAssigned ? 1.0 : isCandidate? 0.7:0.5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor, width: borderWidth),
          boxShadow: isAssigned ? [const BoxShadow(blurRadius: 4, color: Colors.black26)] : null,
        ),
        clipBehavior: Clip.hardEdge,
        child: _isHovering
            ? Row(
          children: [
            _buildHalfButton("확정", "confirmed"),
            Container(width: 1, color: Colors.white30),
            _buildHalfButton("후보", "candidate"),
          ],
        )
            : Center(
          child: Text(
            isAssigned
                ? "${widget.deptName}\n확정"
                : isCandidate? "${widget.deptName}\n후보": widget.deptName,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isAssigned ? Colors.white : Colors.white70,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHalfButton(String label, String statusKey) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            context.read<InterviewViewModel>().toggleAssignment(widget.deptName, statusKey);
          },
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// --- 단순 버튼 (탈락/보류용) ---
class SimpleDeptButton extends StatelessWidget {
  final String deptName;
  final Candidate candidate;

  const SimpleDeptButton({
    super.key,
    required this.deptName,
    required this.candidate,
  });

  @override
  Widget build(BuildContext context) {
    bool isAssigned = candidate.assigned.containsKey(deptName);
    Color baseColor = Colors.grey;

    return GestureDetector(
      onTap: () {
        context.read<InterviewViewModel>().toggleAssignment(deptName, "confirmed");
      },
      child: Container(
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: baseColor.withOpacity(isAssigned ? 1.0 : 0.3),
          borderRadius: BorderRadius.circular(8),
          border: isAssigned ? Border.all(color: Colors.white, width: 4) : null,
        ),
        child: Text(
          deptName,
          style: TextStyle(
              color: isAssigned ? Colors.white : Colors.white70,
              fontWeight: FontWeight.bold
          ),
        ),
      ),
    );
  }
}

// --- 오른쪽 패널 ---
class RightPanel extends StatelessWidget {
  const RightPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<InterviewViewModel>();

    return Container(
      padding: const EdgeInsets.all(16),
      child: ListView.separated(
        itemCount: viewModel.candidates.length,
        separatorBuilder: (ctx, idx) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final candidate = viewModel.candidates[index];
          bool isSelected = viewModel.selectedCandidate?.name == candidate.name;

          return GestureDetector(
            onTap: () {
              // 클릭 시 해당 지원자를 선택합니다.
              isSelected ? viewModel.clearSelection() : viewModel.selectCandidate(candidate);
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: backGround,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: isSelected ? Colors.blue : Colors.grey[300]!,
                    width: isSelected ? 3.0 : 1.0
                ),
              ),
              child: Row(
                children: [
                  buildProfileImage(candidate.name, size: 50, isSquare: false),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(candidate.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: candidate.appliedList.map((d) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                                color: getDeptColor(d).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: getDeptColor(d), width: 0.5)
                            ),
                            child: Text(d, style: TextStyle(fontSize: 10, color: getDeptColor(d), fontWeight: FontWeight.bold)),
                          )).toList(),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}