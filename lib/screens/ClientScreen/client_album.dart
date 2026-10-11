import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../navigation/prototype_routes.dart';

import '../../api/api_service.dart';
import '../../api/client_session.dart';
import '../../api/consultation_model.dart';
import '../../widgets/device_clock.dart';

class ClientalbumWidget extends StatefulWidget {
  const ClientalbumWidget({super.key});

  @override
  State<ClientalbumWidget> createState() => _ClientalbumWidgetState();
}

class _ClientalbumWidgetState extends State<ClientalbumWidget> {
  final ApiService _apiService = ApiService();
  late Future<AlbumListResponse> _albumsFuture;
  @override
  void initState() {
    super.initState();
    _albumsFuture = _loadAlbums();
  }

  Future<AlbumListResponse> _loadAlbums() {
    final clientId = ClientSession.clientId;
    if (clientId == null) {
      return Future.error(StateError('로그인한 클라이언트 정보가 없습니다. 다시 로그인해 주세요.'));
    }
    return _apiService.getAlbumList();
  }

  void _reloadAlbums() {
    setState(() => _albumsFuture = _loadAlbums());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF9F5),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Row(
                children: [
                  const DeviceClock(color: Color(0xFF1A2B49)),
                  const Spacer(),
                  _statusIcon('asset/images/vector14.svg', 20),
                  const SizedBox(width: 6),
                  _statusIcon('asset/images/vector15.svg', 20),
                  const SizedBox(width: 6),
                  _statusIcon('asset/images/vector16.svg', 28),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '앨범',
                  style: TextStyle(
                    color: Color(0xFF1A2B49),
                    fontFamily: 'GowunBatang',
                    fontSize: 22,
                  ),
                ),
              ),
            ),
            Expanded(
              child: FutureBuilder<AlbumListResponse>(
                future: _albumsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return _MessageView(
                      message: '앨범을 불러오지 못했습니다.\n${snapshot.error}',
                      actionLabel: '다시 시도',
                      onAction: _reloadAlbums,
                    );
                  }

                  final albums = snapshot.data?.items ?? const <AlbumCardOut>[];
                  if (albums.isEmpty) {
                    return const _MessageView(message: '아직 저장된 앨범이 없습니다.');
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      _reloadAlbums();
                      await _albumsFuture;
                    },
                    child: GridView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.83,
                          ),
                      itemCount: albums.length,
                      itemBuilder: (context, index) => _AlbumCard(
                        album: albums[index],
                        apiService: _apiService,
                        onTap: () => openPrototypeRoute(
                          context,
                          PrototypeRoutes.clientSummary,
                          payload: albums[index].sessionId,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Color(0xFFEAEFF2))),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _navigationItem(Icons.home_outlined, '홈', false),
              _navigationItem(Icons.photo_album_outlined, '앨범', true),
              _navigationItem(Icons.settings_outlined, '설정', false),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusIcon(String asset, double width) {
    return SvgPicture.asset(asset, width: width, height: 20);
  }

  Widget _navigationItem(IconData icon, String label, bool selected) {
    final route = selected
        ? null
        : switch (label) {
            '홈' => PrototypeRoutes.clientHome,
            '앨범' => PrototypeRoutes.clientAlbum,
            '설정' => PrototypeRoutes.clientSettings,
            _ => null,
          };
    final item = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 24,
          color: selected ? const Color(0xFFFF6B53) : const Color(0xFF7D879C),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: selected ? const Color(0xFFFF6B53) : const Color(0xFF7D879C),
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
              route: route,
              transition: FlowTransition.fade,
              child: item,
            ),
    );
  }
}

class _AlbumCard extends StatelessWidget {
  const _AlbumCard({
    required this.album,
    required this.apiService,
    required this.onTap,
  });

  final AlbumCardOut album;
  final ApiService apiService;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final imageUrl = album.imageUrl.trim();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
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
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: imageUrl.isEmpty
                    ? const _AlbumImagePlaceholder()
                    : Image.network(
                        apiService.resolveUrl(imageUrl),
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const _AlbumImagePlaceholder(),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              album.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF1A2B49),
                fontFamily: 'GowunBatang',
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatDate(album),
              style: const TextStyle(
                color: Color(0xFF7D879C),
                fontFamily: 'GowunBatang',
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(AlbumCardOut album) {
    if (album.dateLabel.isNotEmpty) return album.dateLabel;
    final createdAt = album.createdAt;
    if (createdAt == null) return '날짜 정보 없음';
    return '${createdAt.month}월 ${createdAt.day}일';
  }
}

class _AlbumImagePlaceholder extends StatelessWidget {
  const _AlbumImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFEF3C7),
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_not_supported_outlined,
        color: Color(0xFF7D879C),
        size: 32,
      ),
    );
  }
}

class _MessageView extends StatelessWidget {
  const _MessageView({required this.message, this.actionLabel, this.onAction});

  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF526176),
                fontFamily: 'GowunBatang',
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 12),
              TextButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
