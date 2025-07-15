import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:ultralytics_yolo_example/presentation/viewmodel/clinics_viewmodel.dart';
// import 'package:url_launcher/url_launcher.dart'; // 전화 걸기, 길 찾기 등을 위해 나중에 필요할 수 있습니다.

class ClinicsMapScreen extends StatefulWidget {
  const ClinicsMapScreen({super.key});

  @override
  State<ClinicsMapScreen> createState() => _ClinicsMapScreenState();
}

class _ClinicsMapScreenState extends State<ClinicsMapScreen> {
  final MapController _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ClinicsViewModel>(context);

    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '오류: ${viewModel.errorMessage}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => viewModel.fetchClinics(),
                child: const Text('다시 불러오기'),
              ),
            ],
          ),
        ),
      );
    }

    if (viewModel.clinics.isEmpty) {
      return const Center(child: Text('주변 치과 정보가 없습니다.'));
    }

    final markers = viewModel.clinics.map((clinic) {
      return Marker(
        width: 80,
        height: 80,
        point: LatLng(clinic.lat, clinic.lng),
        child: GestureDetector(
          onTap: () {
            // 마커 클릭 시 해당 치과로 지도 이동 및 목록 스크롤 (선택 사항)
            _mapController.move(LatLng(clinic.lat, clinic.lng), _mapController.zoom);
            // TODO: 나중에 목록에서 해당 항목으로 스크롤하는 로직 추가
            _showClinicDetails(context, clinic); // 상세 정보 표시
          },
          child: Column(
            children: [
              const Icon(Icons.location_on, color: Colors.red, size: 40),
              Text(
                clinic.name,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  shadows: [
                    Shadow(
                      blurRadius: 2.0,
                      color: Colors.white,
                      offset: Offset(1.0, 1.0),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }).toList();

    final initialCenter = markers.isNotEmpty
        ? markers.first.point
        : const LatLng(37.5665, 126.9780); // 서울 시청 기본 좌표

    return Scaffold(
      appBar: AppBar(
        title: const Text("주변 치과"), // 앱바 제목 변경
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // 지도 섹션
          Expanded(
            flex: 2, // 지도가 화면의 2/3 차지
            child: FlutterMap(
              mapController: _mapController, // MapController 연결
              options: MapOptions(
                center: initialCenter,
                zoom: 13.0,
                interactiveFlags: InteractiveFlag.all,
                onTap: (_, latlng) {
                  // 지도 빈 공간 탭 시 특정 동작 (예: 현재 선택된 마커 해제)
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                  userAgentPackageName: 'com.example.toothapp',
                ),
                MarkerLayer(markers: markers),
              ],
            ),
          ),
          // 목록 섹션
          Expanded(
            flex: 1, // 목록이 화면의 1/3 차지
            child: Container(
              color: Colors.white,
              child: ListView.builder(
                itemCount: viewModel.clinics.length,
                itemBuilder: (context, index) {
                  final clinic = viewModel.clinics[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    child: ListTile(
                      title: Text(clinic.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(clinic.address),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        _mapController.move(LatLng(clinic.lat, clinic.lng), 15.0); // 탭 시 해당 치과로 지도 확대 이동
                        _showClinicDetails(context, clinic); // 상세 정보 표시
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 치과 상세 정보를 보여주는 함수
  void _showClinicDetails(BuildContext context, Clinic clinic) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // 내용이 길어질 경우 스크롤 가능하게
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext bc) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      clinic.name,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 10),
              Text('주소: ${clinic.address}', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 5),
              Text('전화: ${clinic.phone}', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // TODO: 나중에 카카오톡 API 연동 (길 찾기, 공유 등)
                  _buildActionButton(
                    icon: Icons.call,
                    label: '전화 걸기',
                    onPressed: () {
                      // launchUrl(Uri.parse('tel:${clinic.phone}')); // url_launcher 필요
                      debugPrint('Call ${clinic.phone}');
                      Navigator.pop(context);
                    },
                  ),
                  _buildActionButton(
                    icon: Icons.directions,
                    label: '길 찾기',
                    onPressed: () {
                      // launchUrl(Uri.parse('https://map.kakao.com/link/to/${clinic.name},${clinic.lat},${clinic.lng}')); // 카카오맵 링크
                      debugPrint('Find directions to ${clinic.name}');
                      Navigator.pop(context);
                    },
                  ),
                  _buildActionButton(
                    icon: Icons.share,
                    label: '공유하기',
                    onPressed: () {
                      // Share.share('치과 정보: ${clinic.name}, ${clinic.address}'); // share_plus 필요
                      debugPrint('Share ${clinic.name}');
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButton({required IconData icon, required String label, required VoidCallback onPressed}) {
    return Column(
      children: [
        InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(icon, size: 30, color: Theme.of(context).primaryColor),
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
