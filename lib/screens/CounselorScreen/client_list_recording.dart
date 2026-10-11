import 'dart:async';

import 'package:flutter/material.dart';

import '../../api/api_service.dart';
import '../../api/consultation_model.dart';
import '../../navigation/prototype_routes.dart';
import '../../widgets/device_clock.dart';

class ClientListRecordingV3 extends StatefulWidget {
  const ClientListRecordingV3({super.key});

  @override
  State<ClientListRecordingV3> createState() => _ClientListRecordingV3State();
}

class _ClientListRecordingV3State extends State<ClientListRecordingV3> {
  static const _pageSize = 50;

  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ClientBrief> _clients = [];
  Timer? _searchDebounce;

  int _offset = 0;
  int _requestGeneration = 0;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    _loadClients(reset: true);
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients ||
        _isLoading ||
        _isLoadingMore ||
        _error != null ||
        !_hasMore) {
      return;
    }
    if (_scrollController.position.extentAfter < 240) {
      _loadClients();
    }
  }

  void _onSearchChanged(String _) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(
      const Duration(milliseconds: 350),
      () => _loadClients(reset: true),
    );
  }

  Future<void> _loadClients({bool reset = false}) async {
    if (!reset && (_isLoading || _isLoadingMore)) return;

    if (reset) _requestGeneration++;
    final generation = _requestGeneration;
    final offset = reset ? 0 : _offset;
    setState(() {
      if (reset) {
        _isLoading = true;
        _clients.clear();
        _offset = 0;
        _hasMore = true;
      } else {
        _isLoadingMore = true;
      }
      _error = null;
    });

    try {
      final response = await _apiService.getClientList(
        query: _searchController.text.trim(),
        limit: _pageSize,
        offset: offset,
      );
      if (!mounted || generation != _requestGeneration) return;
      setState(() {
        _clients.addAll(response.items);
        _offset = offset + response.items.length;
        _hasMore = response.items.isNotEmpty && _offset < response.total;
      });
    } catch (error) {
      if (!mounted || generation != _requestGeneration) return;
      setState(() {
        _error = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted && generation == _requestGeneration) {
        setState(() {
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF9F5),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
              child: Row(
                children: [
                  const DeviceClock(
                    color: Color(0xFF1A2B49),
                    fontSize: 15,
                  ),
                  const Spacer(),
                  const Icon(Icons.signal_cellular_alt, size: 18),
                  const SizedBox(width: 6),
                  const Icon(Icons.wifi, size: 18),
                  const SizedBox(width: 6),
                  const Icon(Icons.battery_full, size: 20),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '상담할 내담자 선택',
                  style: TextStyle(
                    color: Color(0xFF1A2B49),
                    fontFamily: 'GowunBatang',
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: '이름 혹은 고유 인지번호 검색',
                  hintStyle: const TextStyle(
                    color: Color(0xFF7D879C),
                    fontFamily: 'GowunBatang',
                    fontSize: 14,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFF7D879C),
                  ),
                  suffixIcon: _searchController.text.isEmpty
                      ? null
                      : IconButton(
                          tooltip: '검색어 지우기',
                          onPressed: () {
                            _searchController.clear();
                            _onSearchChanged('');
                          },
                          icon: const Icon(Icons.close),
                        ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100),
                    borderSide: const BorderSide(color: Color(0xFFEAEFF2)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100),
                    borderSide: const BorderSide(color: Color(0xFFEAEFF2)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100),
                    borderSide: const BorderSide(
                      color: Color(0xFFFF6B53),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => _loadClients(reset: true),
                child: ListView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  children: [
                    if (_isLoading && _clients.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 56),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (_error != null && _clients.isEmpty)
                      _RecordingListMessage(
                        message: '내담자 목록을 불러오지 못했습니다.',
                        detail: _error,
                        actionLabel: '다시 시도',
                        onAction: () => _loadClients(reset: true),
                      )
                    else if (_clients.isEmpty)
                      _RecordingListMessage(
                        message: _searchController.text.trim().isEmpty
                            ? '등록된 내담자가 없습니다.'
                            : '검색 결과가 없습니다.',
                      )
                    else ...[
                      for (final client in _clients) ...[
                        _RecordingClientCard(
                          client: client,
                          onTap: () => openPrototypeRoute(
                            context,
                            PrototypeRoutes.sessionInfo,
                            payload: client.id,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      if (_isLoadingMore)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      if (_error != null)
                        _RecordingListMessage(
                          message: '목록을 더 불러오지 못했습니다.',
                          detail: _error,
                          actionLabel: '다시 시도',
                          onAction: _loadClients,
                        ),
                    ],
                  ],
                ),
              ),
            ),
            const _RecordingBottomNavigation(),
          ],
        ),
      ),
    );
  }
}

class _RecordingClientCard extends StatelessWidget {
  const _RecordingClientCard({required this.client, required this.onTap});

  final ClientBrief client;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final details = [
      if (client.age != null) '${client.age}세',
      if (client.gender?.isNotEmpty ?? false) client.gender!,
    ];
    final imageUrl = client.profileImageUrl?.trim();

    return Card(
      margin: EdgeInsets.zero,
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFEAEFF2)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _RecordingAvatar(imageUrl: imageUrl),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      client.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF1A2B49),
                        fontFamily: 'GowunBatang',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (details.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        details.join(' / '),
                        style: const TextStyle(
                          color: Color(0xFF344B6E),
                          fontFamily: 'GowunBatang',
                          fontSize: 14,
                        ),
                      ),
                    ],
                    if (client.cognitiveStage?.isNotEmpty ?? false) ...[
                      const SizedBox(height: 4),
                      Text(
                        '인지 단계: ${client.cognitiveStage}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFFFF6B53),
                          fontFamily: 'GowunBatang',
                          fontSize: 13,
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      '최근 면담: ${_formatVisit(client.lastVisitAt)}',
                      style: const TextStyle(
                        color: Color(0xFF7D879C),
                        fontFamily: 'GowunBatang',
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: Color(0xFF7D879C)),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecordingAvatar extends StatelessWidget {
  const _RecordingAvatar({this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          imageUrl!,
          width: 52,
          height: 52,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _placeholder(),
        ),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() => const CircleAvatar(
    radius: 26,
    backgroundColor: Color(0xFFFFF0EC),
    child: Icon(Icons.person, color: Color(0xFFFF6B53)),
  );
}

String _formatVisit(DateTime? date) {
  if (date == null) return '기록 없음';
  return '${date.year}년 ${date.month}월 ${date.day}일';
}

class _RecordingListMessage extends StatelessWidget {
  const _RecordingListMessage({
    required this.message,
    this.detail,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final String? detail;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Column(
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF1A2B49),
              fontFamily: 'GowunBatang',
              fontSize: 14,
            ),
          ),
          if (detail != null) ...[
            const SizedBox(height: 8),
            Text(
              detail!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF7D879C),
                fontSize: 12,
              ),
            ),
          ],
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 8),
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}

class _RecordingBottomNavigation extends StatelessWidget {
  const _RecordingBottomNavigation();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEAEFF2))),
      ),
      padding: const EdgeInsets.only(top: 10, bottom: 12),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _RecordingNavigationItem(label: '홈', icon: Icons.home_outlined),
          _RecordingNavigationItem(label: '면담자', icon: Icons.people_outline),
          _RecordingNavigationItem(
            label: '달력',
            icon: Icons.calendar_month_outlined,
          ),
        ],
      ),
    );
  }
}

class _RecordingNavigationItem extends StatelessWidget {
  const _RecordingNavigationItem({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 24, color: const Color(0xFF7D879C)),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF7D879C),
            fontFamily: 'GowunBatang',
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
