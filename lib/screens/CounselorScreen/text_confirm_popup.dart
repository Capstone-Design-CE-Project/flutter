import 'package:flutter/material.dart';

import '../../api/api_service.dart';
import '../../navigation/prototype_routes.dart';
import 'session_flow_payloads.dart';

class TextConfirmPopup extends StatefulWidget {
  const TextConfirmPopup({super.key, this.routePayload});

  final SummaryReviewRoutePayload? routePayload;

  @override
  State<TextConfirmPopup> createState() => _TextConfirmPopupState();
}

class _TextConfirmPopupState extends State<TextConfirmPopup> {
  final ApiService _apiService = ApiService();
  late final TextEditingController _summaryController;
  String? _error;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _summaryController = TextEditingController(
      text: widget.routePayload?.summary.summary ?? '',
    );
  }

  @override
  void dispose() {
    _summaryController.dispose();
    super.dispose();
  }

  Future<void> _saveSummary() async {
    if (_isSaving) return;
    final routePayload = widget.routePayload;
    final summary = _summaryController.text.trim();
    if (routePayload == null || routePayload.summary.sessionId <= 0) {
      setState(() => _error = '요약을 저장할 상담 정보를 찾을 수 없습니다.');
      return;
    }
    if (summary.isEmpty) {
      setState(() => _error = '요약 내용을 입력해 주세요.');
      return;
    }

    setState(() {
      _isSaving = true;
      _error = null;
    });

    try {
      final updatedSummary = await _apiService.updateSessionSummary(
        routePayload.summary.sessionId,
        summary: summary,
      );
      if (!mounted) return;

      Navigator.of(context).pushReplacementNamed(
        PrototypeRoutes.summaryReview,
        arguments: PrototypeRouteArguments(
          transition: FlowTransition.fade,
          payload: SummaryReviewRoutePayload(
            clientName: routePayload.clientName,
            summary: updatedSummary,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF9F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFCF9F5),
        foregroundColor: const Color(0xFF1A2B49),
        centerTitle: true,
        title: const Text(
          '초기 요약본 수정',
          style: TextStyle(
            color: Color(0xFF1A2B49),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF1EC),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '상담 요약 내용을 확인하고 필요한 부분을 수정해 주세요.',
                      style: TextStyle(
                        color: Color(0xFF7D879C),
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: TextField(
                      controller: _summaryController,
                      expands: true,
                      minLines: null,
                      maxLines: null,
                      textAlignVertical: TextAlignVertical.top,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                        hintText: '요약 내용을 입력해 주세요.',
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.all(16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Color(0xFFEAEFF2),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Color(0xFFEAEFF2),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Color(0xFFFF6B53),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _error!,
                      style: const TextStyle(color: Color(0xFFB42318)),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isSaving
                              ? null
                              : () => Navigator.of(context).maybePop(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF1A2B49),
                            side: const BorderSide(
                              color: Color(0xFF1A2B49),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('취소'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: _isSaving ? null : _saveSummary,
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFFF6B53),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text(_isSaving ? '저장 중...' : '수정 내용 저장'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
