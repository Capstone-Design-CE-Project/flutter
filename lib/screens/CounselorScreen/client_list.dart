import 'dart:async';

import 'package:flutter/material.dart';

import '../../api/api_service.dart';
import '../../api/consultation_model.dart';
import '../../navigation/prototype_routes.dart';
import '../../widgets/device_clock.dart';

class ClientList extends StatefulWidget {
  const ClientList({super.key});

  @override
  State<ClientList> createState() => _ClientListState();
}

class _ClientListState extends State<ClientList> {
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
    _fetchClients(reset: true);
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
      _fetchClients();
    }
  }

  void _onSearchChanged(String _) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(
      const Duration(milliseconds: 350),
      () => _fetchClients(reset: true),
    );
  }

  Future<void> _openNewClientForm() async {
    // 라우트가 PageRouteBuilder<dynamic> 이라 pushNamed<String> 은 TypeError.
    final Object? popped = await Navigator.of(context).pushNamed(
      PrototypeRoutes.newClient,
      arguments: const PrototypeRouteArguments(
        transition: FlowTransition.slide,
      ),
    );
    final result = popped is String ? popped : null;
    if (!mounted || result == null) return;

    await _fetchClients(reset: true);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result)),
    );
  }

  Future<void> _fetchClients({bool reset = false}) async {
    if (!reset && (_isLoadingMore || _isLoading)) return;

    if (reset) _requestGeneration++;
    final requestGeneration = _requestGeneration;
    final requestOffset = reset ? 0 : _offset;
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
        offset: requestOffset,
      );
      if (!mounted || requestGeneration != _requestGeneration) return;
      setState(() {
        _clients.addAll(response.items);
        _offset = requestOffset + response.items.length;
        _hasMore = response.items.isNotEmpty && _offset < response.total;
      });
    } catch (error) {
      if (!mounted || requestGeneration != _requestGeneration) return;
      setState(() {
        _error = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted && requestGeneration == _requestGeneration) {
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
                  const DeviceClock(color: Color(0xFF1A2B49), fontSize: 15),
                  const Spacer(),
                  const Icon(Icons.signal_cellular_alt, size: 18),
                  const SizedBox(width: 6),
                  const Icon(Icons.wifi, size: 18),
                  const SizedBox(width: 6),
                  const Icon(Icons.battery_full, size: 20),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '면담자 관리',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: const Color(0xFF1A2B49),
                      fontFamily: 'GowunBatang',
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
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
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(100),
                        borderSide: const BorderSide(
                          color: Color(0xFFEAEFF2),
                          width: 1.5,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(100),
                        borderSide: const BorderSide(
                          color: Color(0xFFEAEFF2),
                          width: 1.5,
                        ),
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
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => _fetchClients(reset: true),
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
                      _ListMessage(
                        message: '내담자 목록을 불러오지 못했습니다.',
                        detail: _error,
                        actionLabel: '다시 시도',
                        onAction: () => _fetchClients(reset: true),
                      )
                    else if (_clients.isEmpty)
                      _ListMessage(
                        message: _searchController.text.trim().isEmpty
                            ? '등록된 내담자가 없습니다.'
                            : '검색 결과가 없습니다.',
                      )
                    else ...[
                      for (final client in _clients) ...[
                        _ClientCard(
                          client: client,
                          onTap: () => openPrototypeRoute(
                            context,
                            PrototypeRoutes.clientDetail,
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
                        _ListMessage(
                          message: '목록을 더 불러오지 못했습니다.',
                          detail: _error,
                          actionLabel: '다시 시도',
                          onAction: _fetchClients,
                        ),
                    ],
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: FilledButton.icon(
                        onPressed: _openNewClientForm,
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF52A87B),
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.person_add_alt_1),
                        label: const Text(
                          '새 내담자 추가하기',
                          style: TextStyle(
                            fontFamily: 'GowunBatang',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const _CounselorBottomNavigation(),
          ],
        ),
      ),
    );
  }
}

class _ClientCard extends StatelessWidget {
  const _ClientCard({required this.client, required this.onTap});

  final ClientBrief client;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final details = <String>[
      if (client.age != null) '${client.age}세',
      if (client.gender != null && client.gender!.isNotEmpty) client.gender!,
    ];
    final metadata = [
      if (details.isNotEmpty) details.join(' · '),
      if (client.memberCode?.isNotEmpty ?? false) '인지번호 ${client.memberCode}',
    ];

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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              _ClientAvatar(imageUrl: client.profileImageUrl),
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
                    const SizedBox(height: 3),
                    Text(
                      metadata.isEmpty ? '추가 정보 없음' : metadata.join('  |  '),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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

class _ClientAvatar extends StatelessWidget {
  const _ClientAvatar({this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl?.trim();
    if (url != null && url.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          url,
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

class _ListMessage extends StatelessWidget {
  const _ListMessage({
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
              fontSize: 15,
            ),
          ),
          if (detail != null) ...[
            const SizedBox(height: 8),
            Text(
              detail!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF7D879C), fontSize: 12),
            ),
          ],
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 12),
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}

class _CounselorBottomNavigation extends StatelessWidget {
  const _CounselorBottomNavigation();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEAEFF2))),
      ),
      padding: const EdgeInsets.only(top: 10, bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavigationItem(
            label: '홈',
            icon: Icons.home_outlined,
            route: PrototypeRoutes.dashboard,
          ),
          const _NavigationItem(
            label: '면담자',
            icon: Icons.people,
            selected: true,
          ),
          _NavigationItem(
            label: '달력',
            icon: Icons.calendar_month_outlined,
            route: PrototypeRoutes.calendar,
          ),
        ],
      ),
    );
  }
}

class _NavigationItem extends StatelessWidget {
  const _NavigationItem({
    required this.label,
    required this.icon,
    this.route,
    this.selected = false,
  });

  final String label;
  final IconData icon;
  final String? route;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final color = selected ? const Color(0xFFFF6B53) : const Color(0xFF7D879C);
    final child = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 24, color: color),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontFamily: 'GowunBatang',
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );

    if (route == null) return child;
    return InkWell(
      onTap: () =>
          openPrototypeRoute(context, route!, transition: FlowTransition.fade),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
        child: child,
      ),
    );
  }
}
