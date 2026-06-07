// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'EventHub';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get register => 'إنشاء حساب';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get password => 'كلمة المرور';

  @override
  String get confirmPassword => 'تأكيد كلمة المرور';

  @override
  String get forgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get noAccount => 'ليس لديك حساب؟';

  @override
  String get haveAccount => 'لديك حساب بالفعل؟';

  @override
  String get createAccount => 'إنشاء حساب';

  @override
  String get fullName => 'الاسم الكامل';

  @override
  String get discoverEvents => 'اكتشف الفعاليات';

  @override
  String get organizeEvents => 'نظم الفعاليات';

  @override
  String get events => 'الفعاليات';

  @override
  String get tickets => 'التذاكر';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get settings => 'الإعدادات';

  @override
  String get darkMode => 'الوضع الليلي';

  @override
  String get language => 'اللغة';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get search => 'بحث';

  @override
  String get noEvents => 'لا توجد فعاليات';

  @override
  String get noTickets => 'لا توجد تذاكر';

  @override
  String get noNotifications => 'لا توجد إشعارات';

  @override
  String get free => 'مجاني';

  @override
  String get bookNow => 'احجز الآن';

  @override
  String get participants => 'المشاركون';

  @override
  String get category => 'التصنيف';

  @override
  String get location => 'المكان';

  @override
  String get date => 'التاريخ';

  @override
  String get description => 'الوصف';

  @override
  String get qrCode => 'رمز QR';

  @override
  String get scanQR => 'مسح QR';

  @override
  String get validTicket => 'تذكرة صالحة';

  @override
  String get invalidTicket => 'تذكرة غير صالحة';

  @override
  String get payment => 'الدفع';

  @override
  String get totalAmount => 'المبلغ الإجمالي';

  @override
  String get confirmBooking => 'تأكيد الحجز';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get loading => 'جار التحميل...';

  @override
  String get errorOccurred => 'حدث خطأ';

  @override
  String get noConnection => 'لا يوجد اتصال بالإنترنت';
}
