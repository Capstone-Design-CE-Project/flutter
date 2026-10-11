typedef JsonMap = Map<String, dynamic>;

int? _parseInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.toInt();
  return int.tryParse(value.toString());
}

bool _parseBool(dynamic value) {
  if (value == null) return false;
  if (value is bool) return value;
  return value.toString() == 'true';
}

String? _parseString(dynamic value) {
  if (value == null) return null;
  return value.toString();
}

DateTime? _parseDateTime(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  return DateTime.tryParse(value.toString());
}

List<String> _parseStringList(dynamic value) {
  if (value == null) return <String>[];
  if (value is List) {
    return value.map((e) => e.toString()).toList();
  }
  if (value is String) {
    return value.isEmpty
        ? <String>[]
        : value
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();
  }
  return <String>[];
}

List<T> _parseList<T>(dynamic value, T Function(JsonMap json) mapper) {
  if (value is! List) return <T>[];
  return value
      .whereType<Map>()
      .map((item) => mapper(Map<String, dynamic>.from(item)))
      .toList();
}

class CounselorOut {
  CounselorOut({
    required this.id,
    required this.loginId,
    required this.name,
    this.email,
    this.phone,
    this.profileImageUrl,
    this.createdAt,
  });

  final int id;
  final String loginId;
  final String name;
  final String? email;
  final String? phone;
  final String? profileImageUrl;
  final DateTime? createdAt;

  factory CounselorOut.fromJson(JsonMap json) {
    return CounselorOut(
      id: _parseInt(json['id']) ?? 0,
      loginId: _parseString(json['login_id']) ?? '',
      name: _parseString(json['name']) ?? '',
      email: _parseString(json['email']),
      phone: _parseString(json['phone']),
      profileImageUrl: _parseString(json['profile_image_url']),
      createdAt: _parseDateTime(json['created_at']),
    );
  }

  JsonMap toJson() => {
    'id': id,
    'login_id': loginId,
    'name': name,
    if (email != null) 'email': email,
    if (phone != null) 'phone': phone,
    if (profileImageUrl != null) 'profile_image_url': profileImageUrl,
    if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
  };
}

class ClientBrief {
  ClientBrief({
    required this.id,
    required this.name,
    this.age,
    this.gender,
    this.cognitiveStage,
    this.memberCode,
    this.profileImageUrl,
    this.lastVisitAt,
  });

  final int id;
  final String name;
  final int? age;
  final String? gender;
  final String? cognitiveStage;
  final String? memberCode;
  final String? profileImageUrl;
  final DateTime? lastVisitAt;

  factory ClientBrief.fromJson(JsonMap json) {
    return ClientBrief(
      id: _parseInt(json['id']) ?? 0,
      name: _parseString(json['name']) ?? '',
      age: _parseInt(json['age']),
      gender: _parseString(json['gender']),
      cognitiveStage: _parseString(json['cognitive_stage']),
      memberCode: _parseString(json['member_code']),
      profileImageUrl: _parseString(json['profile_image_url']),
      lastVisitAt: _parseDateTime(json['last_visit_at']),
    );
  }

  JsonMap toJson() => {
    'id': id,
    'name': name,
    if (age != null) 'age': age,
    if (gender != null) 'gender': gender,
    if (cognitiveStage != null) 'cognitive_stage': cognitiveStage,
    if (memberCode != null) 'member_code': memberCode,
    if (profileImageUrl != null) 'profile_image_url': profileImageUrl,
    if (lastVisitAt != null) 'last_visit_at': lastVisitAt!.toIso8601String(),
  };
}

class ClientDetail extends ClientBrief {
  ClientDetail({
    required super.id,
    required super.name,
    super.age,
    super.gender,
    super.cognitiveStage,
    super.memberCode,
    super.profileImageUrl,
    super.lastVisitAt,
    this.phone,
    this.memo,
    this.loginId,
    this.hasPin = false,
    this.isActive = true,
    this.createdAt,
    this.sessionCount = 0,
    this.nextAppointment,
  });

  final String? phone;
  final String? memo;
  final String? loginId;
  final bool hasPin;
  final bool isActive;
  final DateTime? createdAt;
  final int sessionCount;
  final AppointmentOut? nextAppointment;

  factory ClientDetail.fromJson(JsonMap json) {
    return ClientDetail(
      id: _parseInt(json['id']) ?? 0,
      name: _parseString(json['name']) ?? '',
      age: _parseInt(json['age']),
      gender: _parseString(json['gender']),
      cognitiveStage: _parseString(json['cognitive_stage']),
      memberCode: _parseString(json['member_code']),
      profileImageUrl: _parseString(json['profile_image_url']),
      lastVisitAt: _parseDateTime(json['last_visit_at']),
      phone: _parseString(json['phone']),
      memo: _parseString(json['memo']),
      loginId: _parseString(json['login_id']),
      hasPin: _parseBool(json['has_pin']),
      isActive: _parseBool(json['is_active']),
      createdAt: _parseDateTime(json['created_at']),
      sessionCount: _parseInt(json['session_count']) ?? 0,
      nextAppointment: json['next_appointment'] == null
          ? null
          : AppointmentOut.fromJson(
              Map<String, dynamic>.from(json['next_appointment']),
            ),
    );
  }

  @override
  JsonMap toJson() => {
    ...super.toJson(),
    if (phone != null) 'phone': phone,
    if (memo != null) 'memo': memo,
    if (loginId != null) 'login_id': loginId,
    'has_pin': hasPin,
    'is_active': isActive,
    if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    'session_count': sessionCount,
    if (nextAppointment != null) 'next_appointment': nextAppointment!.toJson(),
  };
}

class ClientListResponse {
  ClientListResponse({required this.total, required this.items});

  final int total;
  final List<ClientBrief> items;

  factory ClientListResponse.fromJson(JsonMap json) {
    return ClientListResponse(
      total: _parseInt(json['total']) ?? 0,
      items: _parseList<ClientBrief>(json['items'], ClientBrief.fromJson),
    );
  }

  JsonMap toJson() => {
    'total': total,
    'items': items.map((e) => e.toJson()).toList(),
  };
}

class AppointmentOut {
  AppointmentOut({
    required this.id,
    required this.clientId,
    this.clientName,
    required this.scheduledAt,
    required this.durationMinutes,
    this.purpose,
    this.place,
    this.memo,
    required this.status,
  });

  final int id;
  final int clientId;
  final String? clientName;
  final DateTime scheduledAt;
  final int durationMinutes;
  final String? purpose;
  final String? place;
  final String? memo;
  final String status;

  factory AppointmentOut.fromJson(JsonMap json) {
    return AppointmentOut(
      id: _parseInt(json['id']) ?? 0,
      clientId: _parseInt(json['client_id']) ?? 0,
      clientName: _parseString(json['client_name']),
      scheduledAt: _parseDateTime(json['scheduled_at']) ?? DateTime.now(),
      durationMinutes: _parseInt(json['duration_minutes']) ?? 60,
      purpose: _parseString(json['purpose']),
      place: _parseString(json['place']),
      memo: _parseString(json['memo']),
      status: _parseString(json['status']) ?? 'scheduled',
    );
  }

  JsonMap toJson() => {
    'id': id,
    'client_id': clientId,
    if (clientName != null) 'client_name': clientName,
    'scheduled_at': scheduledAt.toIso8601String(),
    'duration_minutes': durationMinutes,
    if (purpose != null) 'purpose': purpose,
    if (place != null) 'place': place,
    if (memo != null) 'memo': memo,
    'status': status,
  };
}

class CalendarDay {
  CalendarDay({
    required this.date,
    required this.count,
    required this.appointments,
  });

  final String date;
  final int count;
  final List<AppointmentOut> appointments;

  factory CalendarDay.fromJson(JsonMap json) {
    return CalendarDay(
      date: _parseString(json['date']) ?? '',
      count: _parseInt(json['count']) ?? 0,
      appointments: _parseList<AppointmentOut>(
        json['appointments'],
        AppointmentOut.fromJson,
      ),
    );
  }

  JsonMap toJson() => {
    'date': date,
    'count': count,
    'appointments': appointments.map((e) => e.toJson()).toList(),
  };
}

class CalendarMonthResponse {
  CalendarMonthResponse({
    required this.year,
    required this.month,
    required this.total,
    required this.days,
  });

  final int year;
  final int month;
  final int total;
  final List<CalendarDay> days;

  factory CalendarMonthResponse.fromJson(JsonMap json) {
    return CalendarMonthResponse(
      year: _parseInt(json['year']) ?? DateTime.now().year,
      month: _parseInt(json['month']) ?? DateTime.now().month,
      total: _parseInt(json['total']) ?? 0,
      days: _parseList<CalendarDay>(json['days'], CalendarDay.fromJson),
    );
  }

  JsonMap toJson() => {
    'year': year,
    'month': month,
    'total': total,
    'days': days.map((e) => e.toJson()).toList(),
  };
}

class QaLogOut {
  QaLogOut({
    required this.id,
    required this.type,
    required this.speaker,
    required this.text,
    required this.orderIndex,
    this.spokenAtMs,
  });

  final int id;
  final String type;
  final String speaker;
  final String text;
  final int orderIndex;
  final int? spokenAtMs;

  factory QaLogOut.fromJson(JsonMap json) {
    return QaLogOut(
      id: _parseInt(json['id']) ?? 0,
      type: _parseString(json['type']) ?? 'Q',
      speaker: _parseString(json['speaker']) ?? '',
      text: _parseString(json['text']) ?? '',
      orderIndex: _parseInt(json['order_index']) ?? 0,
      spokenAtMs: _parseInt(json['spoken_at_ms']),
    );
  }

  JsonMap toJson() => {
    'id': id,
    'type': type,
    'speaker': speaker,
    'text': text,
    'order_index': orderIndex,
    if (spokenAtMs != null) 'spoken_at_ms': spokenAtMs,
  };
}

class AlbumOut {
  AlbumOut({
    required this.id,
    this.albumId,
    required this.sessionId,
    this.title,
    required this.imageUrl,
    this.prompt,
    this.scene,
    this.isSelected = false,
    this.createdAt,
  });

  final int id;
  final int? albumId;
  final int sessionId;
  final String? title;
  final String imageUrl;
  final String? prompt;
  final String? scene;
  final bool isSelected;
  final DateTime? createdAt;

  factory AlbumOut.fromJson(JsonMap json) {
    return AlbumOut(
      id: _parseInt(json['id']) ?? 0,
      albumId: _parseInt(json['album_id']) ?? _parseInt(json['id']),
      sessionId: _parseInt(json['session_id']) ?? 0,
      title: _parseString(json['title']),
      imageUrl: _parseString(json['image_url']) ?? '',
      prompt: _parseString(json['prompt']),
      scene: _parseString(json['scene']),
      isSelected: _parseBool(json['is_selected']),
      createdAt: _parseDateTime(json['created_at']),
    );
  }

  JsonMap toJson() => {
    'id': id,
    'album_id': albumId ?? id,
    'session_id': sessionId,
    if (title != null) 'title': title,
    'image_url': imageUrl,
    if (prompt != null) 'prompt': prompt,
    if (scene != null) 'scene': scene,
    'is_selected': isSelected,
    if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
  };
}

class SessionBrief {
  SessionBrief({
    required this.id,
    required this.sessionId,
    required this.userId,
    this.clientName,
    this.title,
    required this.status,
    this.durationSeconds = 0,
    this.referenceCode,
    this.thumbnailUrl,
    this.createdAt,
  });

  final int id;
  final int sessionId;
  final int userId;
  final String? clientName;
  final String? title;
  final String status;
  final int durationSeconds;
  final String? referenceCode;
  final String? thumbnailUrl;
  final DateTime? createdAt;

  factory SessionBrief.fromJson(JsonMap json) {
    return SessionBrief(
      id: _parseInt(json['id']) ?? 0,
      sessionId: _parseInt(json['session_id']) ?? _parseInt(json['id']) ?? 0,
      userId: _parseInt(json['user_id']) ?? 0,
      clientName: _parseString(json['client_name']),
      title: _parseString(json['title']),
      status: _parseString(json['status']) ?? 'pending',
      durationSeconds: _parseInt(json['duration_seconds']) ?? 0,
      referenceCode: _parseString(json['reference_code']),
      thumbnailUrl: _parseString(json['thumbnail_url']),
      createdAt: _parseDateTime(json['created_at']),
    );
  }

  JsonMap toJson() => {
    'id': id,
    'session_id': sessionId,
    'user_id': userId,
    if (clientName != null) 'client_name': clientName,
    if (title != null) 'title': title,
    'status': status,
    'duration_seconds': durationSeconds,
    if (referenceCode != null) 'reference_code': referenceCode,
    if (thumbnailUrl != null) 'thumbnail_url': thumbnailUrl,
    if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
  };
}

class SessionDetail extends SessionBrief {
  SessionDetail({
    required super.id,
    required super.sessionId,
    required super.userId,
    super.clientName,
    super.title,
    required super.status,
    super.durationSeconds,
    super.referenceCode,
    super.thumbnailUrl,
    super.createdAt,
    this.counselorId,
    this.summary,
    this.keywords = const <String>[],
    this.transcript,
    this.startedAt,
    this.endedAt,
    this.qaLogs = const <QaLogOut>[],
    this.albums = const <AlbumOut>[],
  });

  final int? counselorId;
  final String? summary;
  final List<String> keywords;
  final String? transcript;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final List<QaLogOut> qaLogs;
  final List<AlbumOut> albums;

  factory SessionDetail.fromJson(JsonMap json) {
    return SessionDetail(
      id: _parseInt(json['id']) ?? 0,
      sessionId: _parseInt(json['session_id']) ?? _parseInt(json['id']) ?? 0,
      userId: _parseInt(json['user_id']) ?? 0,
      clientName: _parseString(json['client_name']),
      title: _parseString(json['title']),
      status: _parseString(json['status']) ?? 'pending',
      durationSeconds: _parseInt(json['duration_seconds']) ?? 0,
      referenceCode: _parseString(json['reference_code']),
      thumbnailUrl: _parseString(json['thumbnail_url']),
      createdAt: _parseDateTime(json['created_at']),
      counselorId: _parseInt(json['counselor_id']),
      summary: _parseString(json['summary']),
      keywords: _parseStringList(json['keywords']),
      transcript: _parseString(json['transcript']),
      startedAt: _parseDateTime(json['started_at']),
      endedAt: _parseDateTime(json['ended_at']),
      qaLogs: _parseList<QaLogOut>(json['qa_logs'], QaLogOut.fromJson),
      albums: _parseList<AlbumOut>(json['albums'], AlbumOut.fromJson),
    );
  }

  @override
  JsonMap toJson() => {
    ...super.toJson(),
    if (counselorId != null) 'counselor_id': counselorId,
    if (summary != null) 'summary': summary,
    'keywords': keywords,
    if (transcript != null) 'transcript': transcript,
    if (startedAt != null) 'started_at': startedAt!.toIso8601String(),
    if (endedAt != null) 'ended_at': endedAt!.toIso8601String(),
    'qa_logs': qaLogs.map((e) => e.toJson()).toList(),
    'albums': albums.map((e) => e.toJson()).toList(),
  };
}

class SessionListResponse {
  SessionListResponse({required this.total, required this.items});

  final int total;
  final List<SessionBrief> items;

  factory SessionListResponse.fromJson(JsonMap json) {
    return SessionListResponse(
      total: _parseInt(json['total']) ?? 0,
      items: _parseList<SessionBrief>(json['items'], SessionBrief.fromJson),
    );
  }

  JsonMap toJson() => {
    'total': total,
    'items': items.map((e) => e.toJson()).toList(),
  };
}

class TranscriptResponse {
  TranscriptResponse({
    required this.sessionId,
    required this.status,
    this.transcript,
    this.lines = const <QaLogOut>[],
  });

  final int sessionId;
  final String status;
  final String? transcript;
  final List<QaLogOut> lines;

  factory TranscriptResponse.fromJson(JsonMap json) {
    return TranscriptResponse(
      sessionId: _parseInt(json['session_id']) ?? 0,
      status: _parseString(json['status']) ?? 'pending',
      transcript: _parseString(json['transcript']),
      lines: _parseList<QaLogOut>(json['lines'], QaLogOut.fromJson),
    );
  }

  JsonMap toJson() => {
    'session_id': sessionId,
    'status': status,
    if (transcript != null) 'transcript': transcript,
    'lines': lines.map((e) => e.toJson()).toList(),
  };
}

class SummaryResponse {
  SummaryResponse({
    required this.sessionId,
    this.title,
    required this.summary,
    this.keywords = const <String>[],
    required this.generatedBy,
  });

  final int sessionId;
  final String? title;
  final String summary;
  final List<String> keywords;
  final String generatedBy;

  factory SummaryResponse.fromJson(JsonMap json) {
    return SummaryResponse(
      sessionId: _parseInt(json['session_id']) ?? 0,
      title: _parseString(json['title']),
      summary: _parseString(json['summary']) ?? '',
      keywords: _parseStringList(json['keywords']),
      generatedBy: _parseString(json['generated_by']) ?? 'openai',
    );
  }

  JsonMap toJson() => {
    'session_id': sessionId,
    if (title != null) 'title': title,
    'summary': summary,
    'keywords': keywords,
    'generated_by': generatedBy,
  };
}

class SessionCompleteResponse {
  SessionCompleteResponse({
    required this.sessionId,
    required this.status,
    required this.referenceCode,
    this.recordedAt,
    this.selectedAlbum,
  });

  final int sessionId;
  final String status;
  final String referenceCode;
  final DateTime? recordedAt;
  final AlbumOut? selectedAlbum;

  factory SessionCompleteResponse.fromJson(JsonMap json) {
    return SessionCompleteResponse(
      sessionId: _parseInt(json['session_id']) ?? 0,
      status: _parseString(json['status']) ?? 'completed',
      referenceCode: _parseString(json['reference_code']) ?? '',
      recordedAt: _parseDateTime(json['recorded_at']),
      selectedAlbum: json['selected_album'] == null
          ? null
          : AlbumOut.fromJson(
              Map<String, dynamic>.from(json['selected_album']),
            ),
    );
  }

  JsonMap toJson() => {
    'session_id': sessionId,
    'status': status,
    'reference_code': referenceCode,
    if (recordedAt != null) 'recorded_at': recordedAt!.toIso8601String(),
    if (selectedAlbum != null) 'selected_album': selectedAlbum!.toJson(),
  };
}

class RecordingUploadResponse {
  RecordingUploadResponse({
    required this.sessionId,
    required this.status,
    required this.transcript,
    this.lines = const <QaLogOut>[],
    this.durationSeconds = 0,
    required this.sttEngine,
    this.morphSaved = 0,
  });

  final int sessionId;
  final String status;
  final String transcript;
  final List<QaLogOut> lines;
  final int durationSeconds;
  final String sttEngine;
  final int morphSaved;

  factory RecordingUploadResponse.fromJson(JsonMap json) {
    return RecordingUploadResponse(
      sessionId: _parseInt(json['session_id']) ?? 0,
      status: _parseString(json['status']) ?? 'success',
      transcript: _parseString(json['transcript']) ?? '',
      lines: _parseList<QaLogOut>(json['lines'], QaLogOut.fromJson),
      durationSeconds: _parseInt(json['duration_seconds']) ?? 0,
      sttEngine: _parseString(json['stt_engine']) ?? 'clova',
      morphSaved: _parseInt(json['morph_saved']) ?? 0,
    );
  }

  JsonMap toJson() => {
    'session_id': sessionId,
    'status': status,
    'transcript': transcript,
    'lines': lines.map((e) => e.toJson()).toList(),
    'duration_seconds': durationSeconds,
    'stt_engine': sttEngine,
    'morph_saved': morphSaved,
  };
}

class ClientHomeResponse {
  ClientHomeResponse({
    required this.clientId,
    required this.name,
    this.featured,
    this.featuredCaption,
    this.nextAppointment,
    required this.dailyTip,
    this.albumCount = 0,
  });

  final int clientId;
  final String name;
  final AlbumOut? featured;
  final String? featuredCaption;
  final AppointmentOut? nextAppointment;
  final String dailyTip;
  final int albumCount;

  factory ClientHomeResponse.fromJson(JsonMap json) {
    return ClientHomeResponse(
      clientId: _parseInt(json['client_id']) ?? 0,
      name: _parseString(json['name']) ?? '',
      featured: json['featured'] == null
          ? null
          : AlbumOut.fromJson(Map<String, dynamic>.from(json['featured'])),
      featuredCaption: _parseString(json['featured_caption']),
      nextAppointment: json['next_appointment'] == null
          ? null
          : AppointmentOut.fromJson(
              Map<String, dynamic>.from(json['next_appointment']),
            ),
      dailyTip: _parseString(json['daily_tip']) ?? '',
      albumCount: _parseInt(json['album_count']) ?? 0,
    );
  }

  JsonMap toJson() => {
    'client_id': clientId,
    'name': name,
    if (featured != null) 'featured': featured!.toJson(),
    if (featuredCaption != null) 'featured_caption': featuredCaption,
    if (nextAppointment != null) 'next_appointment': nextAppointment!.toJson(),
    'daily_tip': dailyTip,
    'album_count': albumCount,
  };
}

class AlbumCardOut {
  AlbumCardOut({
    required this.id,
    required this.sessionId,
    required this.title,
    required this.imageUrl,
    this.createdAt,
    required this.dateLabel,
  });

  final int id;
  final int sessionId;
  final String title;
  final String imageUrl;
  final DateTime? createdAt;
  final String dateLabel;

  factory AlbumCardOut.fromJson(JsonMap json) {
    return AlbumCardOut(
      id: _parseInt(json['id']) ?? 0,
      sessionId: _parseInt(json['session_id']) ?? 0,
      title: _parseString(json['title']) ?? '',
      imageUrl: _parseString(json['image_url']) ?? '',
      createdAt: _parseDateTime(json['created_at']),
      dateLabel: _parseString(json['date_label']) ?? '',
    );
  }

  JsonMap toJson() => {
    'id': id,
    'session_id': sessionId,
    'title': title,
    'image_url': imageUrl,
    if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    'date_label': dateLabel,
  };
}

class AlbumListResponse {
  AlbumListResponse({required this.total, required this.items});

  final int total;
  final List<AlbumCardOut> items;

  factory AlbumListResponse.fromJson(JsonMap json) {
    return AlbumListResponse(
      total: _parseInt(json['total']) ?? 0,
      items: _parseList<AlbumCardOut>(json['items'], AlbumCardOut.fromJson),
    );
  }

  JsonMap toJson() => {
    'total': total,
    'items': items.map((e) => e.toJson()).toList(),
  };
}

class ClientSummaryResponse {
  ClientSummaryResponse({
    required this.sessionId,
    this.title,
    this.summary,
    this.imageUrl,
    this.sessionDate,
    required this.dateLabel,
  });

  final int sessionId;
  final String? title;
  final String? summary;
  final String? imageUrl;
  final DateTime? sessionDate;
  final String dateLabel;

  factory ClientSummaryResponse.fromJson(JsonMap json) {
    return ClientSummaryResponse(
      sessionId: _parseInt(json['session_id']) ?? 0,
      title: _parseString(json['title']),
      summary: _parseString(json['summary']),
      imageUrl: _parseString(json['image_url']),
      sessionDate: _parseDateTime(json['session_date']),
      dateLabel: _parseString(json['date_label']) ?? '',
    );
  }

  JsonMap toJson() => {
    'session_id': sessionId,
    if (title != null) 'title': title,
    if (summary != null) 'summary': summary,
    if (imageUrl != null) 'image_url': imageUrl,
    if (sessionDate != null) 'session_date': sessionDate!.toIso8601String(),
    'date_label': dateLabel,
  };
}

class SettingOut {
  SettingOut({
    required this.userId,
    required this.fontScale,
    required this.highContrast,
    required this.hapticFeedback,
    required this.showHelpTips,
  });

  final int userId;
  final String fontScale;
  final bool highContrast;
  final bool hapticFeedback;
  final bool showHelpTips;

  factory SettingOut.fromJson(JsonMap json) {
    return SettingOut(
      userId: _parseInt(json['user_id']) ?? 0,
      fontScale: _parseString(json['font_scale']) ?? 'large',
      highContrast: _parseBool(json['high_contrast']),
      hapticFeedback: _parseBool(json['haptic_feedback']),
      showHelpTips: _parseBool(json['show_help_tips']),
    );
  }

  JsonMap toJson() => {
    'user_id': userId,
    'font_scale': fontScale,
    'high_contrast': highContrast,
    'haptic_feedback': hapticFeedback,
    'show_help_tips': showHelpTips,
  };
}

class SettingUpdate {
  SettingUpdate({
    this.fontScale,
    this.highContrast,
    this.hapticFeedback,
    this.showHelpTips,
  });

  final String? fontScale;
  final bool? highContrast;
  final bool? hapticFeedback;
  final bool? showHelpTips;

  JsonMap toJson() => {
    if (fontScale != null) 'font_scale': fontScale,
    if (highContrast != null) 'high_contrast': highContrast,
    if (hapticFeedback != null) 'haptic_feedback': hapticFeedback,
    if (showHelpTips != null) 'show_help_tips': showHelpTips,
  };
}

class DashboardCard {
  DashboardCard({required this.key, required this.label, required this.value});

  final String key;
  final String label;
  final String value;

  factory DashboardCard.fromJson(JsonMap json) {
    return DashboardCard(
      key: _parseString(json['key']) ?? '',
      label: _parseString(json['label']) ?? '',
      value: _parseString(json['value']) ?? '',
    );
  }

  JsonMap toJson() => {'key': key, 'label': label, 'value': value};
}

class DashboardResponse {
  DashboardResponse({
    required this.counselorName,
    required this.greeting,
    required this.todayAppointmentCount,
    required this.clientCount,
    this.nextAppointment,
    required this.completedReportCount,
    required this.unreadNotificationCount,
    this.cards = const <DashboardCard>[],
  });

  final String counselorName;
  final String greeting;
  final int todayAppointmentCount;
  final int clientCount;
  final AppointmentOut? nextAppointment;
  final int completedReportCount;
  final int unreadNotificationCount;
  final List<DashboardCard> cards;

  factory DashboardResponse.fromJson(JsonMap json) {
    return DashboardResponse(
      counselorName: _parseString(json['counselor_name']) ?? '',
      greeting: _parseString(json['greeting']) ?? '',
      todayAppointmentCount: _parseInt(json['today_appointment_count']) ?? 0,
      clientCount: _parseInt(json['client_count']) ?? 0,
      nextAppointment: json['next_appointment'] == null
          ? null
          : AppointmentOut.fromJson(
              Map<String, dynamic>.from(json['next_appointment']),
            ),
      completedReportCount: _parseInt(json['completed_report_count']) ?? 0,
      unreadNotificationCount:
          _parseInt(json['unread_notification_count']) ?? 0,
      cards: _parseList<DashboardCard>(json['cards'], DashboardCard.fromJson),
    );
  }

  JsonMap toJson() => {
    'counselor_name': counselorName,
    'greeting': greeting,
    'today_appointment_count': todayAppointmentCount,
    'client_count': clientCount,
    if (nextAppointment != null) 'next_appointment': nextAppointment!.toJson(),
    'completed_report_count': completedReportCount,
    'unread_notification_count': unreadNotificationCount,
    'cards': cards.map((e) => e.toJson()).toList(),
  };
}

class NotificationOut {
  NotificationOut({
    required this.id,
    required this.type,
    required this.title,
    this.body,
    this.linkSessionId,
    required this.isRead,
    this.createdAt,
  });

  final int id;
  final String type;
  final String title;
  final String? body;
  final int? linkSessionId;
  final bool isRead;
  final DateTime? createdAt;

  factory NotificationOut.fromJson(JsonMap json) {
    return NotificationOut(
      id: _parseInt(json['id']) ?? 0,
      type: _parseString(json['type']) ?? 'info',
      title: _parseString(json['title']) ?? '',
      body: _parseString(json['body']),
      linkSessionId: _parseInt(json['link_session_id']),
      isRead: _parseBool(json['is_read']),
      createdAt: _parseDateTime(json['created_at']),
    );
  }

  JsonMap toJson() => {
    'id': id,
    'type': type,
    'title': title,
    if (body != null) 'body': body,
    if (linkSessionId != null) 'link_session_id': linkSessionId,
    'is_read': isRead,
    if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
  };
}

class NotificationListResponse {
  NotificationListResponse({
    required this.total,
    required this.unread,
    required this.items,
  });

  final int total;
  final int unread;
  final List<NotificationOut> items;

  factory NotificationListResponse.fromJson(JsonMap json) {
    return NotificationListResponse(
      total: _parseInt(json['total']) ?? 0,
      unread: _parseInt(json['unread']) ?? 0,
      items: _parseList<NotificationOut>(
        json['items'],
        NotificationOut.fromJson,
      ),
    );
  }

  JsonMap toJson() => {
    'total': total,
    'unread': unread,
    'items': items.map((e) => e.toJson()).toList(),
  };
}

class MessageResponse {
  MessageResponse({required this.message});

  final String message;

  factory MessageResponse.fromJson(JsonMap json) {
    return MessageResponse(message: _parseString(json['message']) ?? '');
  }

  JsonMap toJson() => {'message': message};
}

class ConsultationSession {
  ConsultationSession({
    required this.sessionId,
    required this.userId,
    required this.createdAt,
    this.summary,
    required this.albums,
  });

  final int sessionId;
  final int userId;
  final DateTime? createdAt;
  final String? summary;
  final List<AlbumImage> albums;

  factory ConsultationSession.fromJson(JsonMap json) {
    final rawAlbums = json['albums'];
    final albumList = rawAlbums is List ? rawAlbums : <dynamic>[];

    return ConsultationSession(
      sessionId: _parseInt(json['session_id']) ?? _parseInt(json['id']) ?? 0,
      userId: _parseInt(json['user_id']) ?? 0,
      createdAt: _parseDateTime(json['created_at']),
      summary: _parseString(json['summary']),
      albums: albumList
          .map((item) => AlbumImage.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
    );
  }

  int get dDay {
    if (createdAt == null) return 0;
    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    final target = DateTime(createdAt!.year, createdAt!.month, createdAt!.day);
    return today.difference(target).inDays;
  }
}

class AlbumImage {
  AlbumImage({
    required this.id,
    required this.sessionId,
    required this.imageUrl,
    required this.createdAt,
  });

  final int id;
  final int sessionId;
  final String imageUrl;
  final DateTime? createdAt;

  factory AlbumImage.fromJson(JsonMap json) {
    return AlbumImage(
      id: _parseInt(json['id']) ?? 0,
      sessionId: _parseInt(json['session_id']) ?? 0,
      imageUrl:
          _parseString(json['image_url']) ?? _parseString(json['url']) ?? '',
      createdAt: _parseDateTime(json['created_at']),
    );
  }
}
