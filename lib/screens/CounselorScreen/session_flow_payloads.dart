import '../../api/consultation_model.dart';

class SummaryReviewRoutePayload {
  const SummaryReviewRoutePayload({
    required this.clientName,
    required this.summary,
  });

  final String clientName;
  final SummaryResponse summary;
}

class ImageGenerationRequest {
  const ImageGenerationRequest({
    required this.sessionId,
    required this.clientName,
    this.isRegeneration = false,
  });

  final int sessionId;
  final String clientName;
  final bool isRegeneration;
}

class ImageReviewRoutePayload {
  const ImageReviewRoutePayload({
    required this.sessionId,
    required this.clientName,
    required this.album,
    required this.canRegenerate,
  });

  final int sessionId;
  final String clientName;
  final AlbumOut album;
  final bool canRegenerate;
}

class SessionCompleteRoutePayload {
  const SessionCompleteRoutePayload({
    required this.sessionId,
    required this.clientName,
    required this.album,
  });

  final int sessionId;
  final String clientName;
  final AlbumOut album;
}

enum SessionEndConfirmationMode { recording, existingSession }

class SessionEndConfirmationRequest {
  const SessionEndConfirmationRequest({
    required this.clientName,
    required this.mode,
  });

  final String clientName;
  final SessionEndConfirmationMode mode;
}
