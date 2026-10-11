import 'package:flutter/material.dart';

import '../../api/api_service.dart';
import '../../api/consultation_model.dart';
import '../../navigation/prototype_routes.dart';

class SessionStartPopupV3 extends StatefulWidget {
  const SessionStartPopupV3({super.key, this.clientId});

  final int? clientId;

  @override
  State<SessionStartPopupV3> createState() => _SessionStartPopupV3State();
}

class _SessionStartPopupV3State extends State<SessionStartPopupV3> {
  final ApiService _apiService = ApiService();
  late Future<ClientDetail> _clientFuture;

  @override
  void initState() {
    super.initState();
    _clientFuture = _loadClient();
  }

  Future<ClientDetail> _loadClient() {
    final clientId = widget.clientId;
    if (clientId == null || clientId <= 0) {
      return Future.error(StateError('선택한 내담자 정보가 없습니다. 내담자 목록에서 다시 선택해 주세요.'));
    }
    return _apiService.getClientDetail(clientId);
  }

  void _retry() {
    setState(() => _clientFuture = _loadClient());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF9F5),
      body: SafeArea(
        child: SizedBox.expand(
          child: DecoratedBox(
            decoration: const BoxDecoration(color: Color(0x72111827)),
            child: Center(
              child: FutureBuilder<ClientDetail>(
                future: _clientFuture,
                builder: (context, snapshot) {
                  return Container(
                    width: 320,
                    margin: const EdgeInsets.all(20),
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x1A111827),
                          blurRadius: 32,
                          offset: Offset(0, 12),
                        ),
                      ],
                    ),
                    child: switch (snapshot.connectionState) {
                      ConnectionState.waiting => const SizedBox(
                        height: 180,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      _ when snapshot.hasError => _SessionStartError(
                        detail: snapshot.error.toString().replaceFirst(
                          'Exception: ',
                          '',
                        ),
                        onRetry: _retry,
                        onBack: () => Navigator.of(context).maybePop(),
                      ),
                      _ => _SessionStartConfirmation(
                        client: snapshot.data!,
                        onConfirm: () => openPrototypeRoute(
                          context,
                          PrototypeRoutes.recording,
                          payload: widget.clientId,
                        ),
                        onCancel: () => Navigator.of(context).pop(),
                      ),
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SessionStartConfirmation extends StatelessWidget {
  const _SessionStartConfirmation({
    required this.client,
    required this.onConfirm,
    required this.onCancel,
  });

  final ClientDetail client;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0x1FFF6B53),
            borderRadius: BorderRadius.circular(28),
          ),
          child: const Icon(Icons.mic_none, color: Color(0xFFFF6B53), size: 28),
        ),
        const SizedBox(height: 24),
        const Text(
          '상담 시작 확인',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF1A2B49),
            fontFamily: 'GowunBatang',
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${client.name}님의 상담을 지금부터 시작하겠습니까?',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF7D879C),
            fontFamily: 'GowunBatang',
            fontSize: 14,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),
        _SessionStartButton(
          label: '네, 시작합니다',
          primary: true,
          onPressed: onConfirm,
        ),
        const SizedBox(height: 8),
        _SessionStartButton(
          label: '아니요, 돌아가기',
          primary: false,
          onPressed: onCancel,
        ),
      ],
    );
  }
}

class _SessionStartButton extends StatelessWidget {
  const _SessionStartButton({
    required this.label,
    required this.primary,
    required this.onPressed,
  });

  final String label;
  final bool primary;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: primary ? const Color(0xFFFF6B53) : Colors.white,
          foregroundColor: primary ? Colors.white : const Color(0xFF1A2B49),
          side: BorderSide(
            color: primary ? const Color(0xFFFF6B53) : const Color(0xFF1A2B49),
            width: primary ? 0 : 1.5,
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: 'GowunBatang',
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _SessionStartError extends StatelessWidget {
  const _SessionStartError({
    required this.detail,
    required this.onRetry,
    required this.onBack,
  });

  final String detail;
  final VoidCallback onRetry;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.error_outline, color: Color(0xFFFF6B53), size: 36),
        const SizedBox(height: 12),
        const Text(
          '내담자 정보를 불러오지 못했습니다.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF1A2B49),
            fontFamily: 'GowunBatang',
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          detail,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFF7D879C), fontSize: 12),
        ),
        const SizedBox(height: 16),
        _SessionStartButton(label: '다시 시도', primary: true, onPressed: onRetry),
        const SizedBox(height: 8),
        _SessionStartButton(label: '돌아가기', primary: false, onPressed: onBack),
      ],
    );
  }
}
