// project_mobile_app/lib/config/ip.dart


// ถ้ามี api ใหม่ใช้ IP ใน dart ที่ไม่มีในนี้ สร้างใหม่ตรงนี้เท่านั้น

/// เปลี่ยนแค่ IP ตรงนี้เวลาเปลี่ยนเครื่อง
const String kServerIp = "192.168.1.4";
const String kServerPort = "3000";

/// Base host เช่น http://10.10.0.25:3000
String get kBaseHost => "http://$kServerIp:$kServerPort";

/// http://10.10.0.25 (ไม่มี port)
String get kBaseHost1 => "http://$kServerIp";

/// Base URL ของ /api/sport
String get kSportApiBaseUrl => "$kBaseHost/api/sport";

/// Base URL ของ /api/auth
String get kAuthApiBaseUrl => "$kBaseHost/api/auth";

/// api dashboard
String get kDashApiBaseUrl => "$kBaseHost/api/dashboard";

/// Base URL public สำหรับรูปภาพ
String get kImageBaseUrl => "$kBaseHost/";

/// Base URL ของ sport_borrow_api ใหม่
String get kSportBorrowApiBaseUrl => "$kBaseHost1/sport_borrow_api";
