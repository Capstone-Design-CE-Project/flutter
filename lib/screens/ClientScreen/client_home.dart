import 'package:flutter/material.dart';

import '../../navigation/prototype_routes.dart';
import '../../widgets/device_clock.dart';

class ClienthomeWidget extends StatelessWidget {
  const ClienthomeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 10, 24, 4),
              child: Row(
                children: [
                  const DeviceClock(color: _navy, fontSize: 12),
                  const Spacer(),
                  const Icon(Icons.signal_cellular_alt, size: 14, color: _navy),
                  const SizedBox(width: 4),
                  const Icon(Icons.wifi, size: 14, color: _navy),
                  const SizedBox(width: 4),
                  const Icon(Icons.battery_full, size: 16, color: _navy),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 12, 24, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '나의 다이어리',
                  style: TextStyle(
                    color: _navy,
                    fontFamily: 'GowunBatang',
                    fontSize: 22,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _MemoryAlbumCard(),
                    const SizedBox(height: 20),
                    _NextAppointmentCard(),
                    const SizedBox(height: 20),
                    _DailySuggestionCard(),
                  ],
                ),
              ),
            ),
            const _ClientBottomNavigation(selected: _ClientTab.home),
          ],
        ),
      ),
    );
  }
}

class _MemoryAlbumCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: SizedBox(
        height: 210,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'asset/images/Heroalbumcard.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const ColoredBox(
                color: Color(0xFF68768A),
              ),
            ),
            const ColoredBox(color: Color(0x661A2B49)),
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '기억 속 쉼터',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'GowunBatang',
                      fontSize: 24,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '소중히 보관된 지난 추억들을 둘러보세요',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'GowunBatang',
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FlowAction(
                    route: PrototypeRoutes.clientAlbum,
                    transition: FlowTransition.fade,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B53),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 9,
                        ),
                        child: Text(
                          '앨범 보기 ›',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'GowunBatang',
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NextAppointmentCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FlowAction(
      route: PrototypeRoutes.clientSummary,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A1A2B49),
              offset: Offset(0, 8),
              blurRadius: 24,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.event_available, size: 20, color: _coral),
                SizedBox(width: 8),
                Text(
                  '다음 상담 약속',
                  style: TextStyle(
                    color: _coral,
                    fontFamily: 'GowunBatang',
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Text(
              '4월 25일 오후 3시',
              style: TextStyle(
                color: _navy,
                fontFamily: 'GowunBatang',
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              '담당 상담사: 김철수 원장',
              style: TextStyle(
                color: Color(0xFF344B6E),
                fontFamily: 'GowunBatang',
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3F0),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '준비물: 어린시절 가족 사진',
                style: TextStyle(
                  color: _coral,
                  fontFamily: 'GowunBatang',
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DailySuggestionCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3F0),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.spa_outlined, size: 24, color: _coral),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '오늘의 마음 다스림',
                  style: TextStyle(
                    color: _navy,
                    fontFamily: 'GowunBatang',
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '한 잔의 따뜻한 보리차와 함께 편안한 호흡으로 오늘 하루를 차분히 시작해 보세요.',
                  style: TextStyle(
                    color: Color(0xFF344B6E),
                    fontFamily: 'GowunBatang',
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum _ClientTab { home, album, settings }

class _ClientBottomNavigation extends StatelessWidget {
  const _ClientBottomNavigation({required this.selected});

  final _ClientTab selected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFEAEFF2))),
        ),
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            _NavigationItem(
              icon: Icons.home_outlined,
              label: '홈',
              selected: selected == _ClientTab.home,
              route: selected == _ClientTab.home
                  ? null
                  : PrototypeRoutes.clientHome,
            ),
            _NavigationItem(
              icon: Icons.photo_album_outlined,
              label: '앨범',
              selected: selected == _ClientTab.album,
              route: PrototypeRoutes.clientAlbum,
            ),
            _NavigationItem(
              icon: Icons.settings_outlined,
              label: '설정',
              selected: selected == _ClientTab.settings,
              route: PrototypeRoutes.clientSettings,
            ),
          ],
        ),
      ),
    );
  }
}

class _NavigationItem extends StatelessWidget {
  const _NavigationItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.route,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final String? route;

  @override
  Widget build(BuildContext context) {
    final item = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 22, color: selected ? _coral : _muted),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: selected ? _coral : _muted,
            fontFamily: 'GowunBatang',
            fontSize: 13,
          ),
        ),
      ],
    );

    return Expanded(
      child: route == null
          ? item
          : FlowAction(
              route: route!,
              transition: FlowTransition.fade,
              child: item,
            ),
    );
  }
}

const _coral = Color(0xFFFF6B53);
const _navy = Color(0xFF1A2B49);
const _muted = Color(0xFF7D879C);
const _background = Color(0xFFFCF9F5);
