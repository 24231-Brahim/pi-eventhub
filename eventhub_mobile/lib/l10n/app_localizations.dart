import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('fr')
  ];

  /// No description provided for @appTitle.
  ///
  /// In fr, this message translates to:
  /// **'EventHub'**
  String get appTitle;

  /// No description provided for @login.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter'**
  String get login;

  /// No description provided for @register.
  ///
  /// In fr, this message translates to:
  /// **'S\'inscrire'**
  String get register;

  /// No description provided for @email.
  ///
  /// In fr, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get password;

  /// No description provided for @name.
  ///
  /// In fr, this message translates to:
  /// **'Nom complet'**
  String get name;

  /// No description provided for @role.
  ///
  /// In fr, this message translates to:
  /// **'Rôle'**
  String get role;

  /// No description provided for @organizer.
  ///
  /// In fr, this message translates to:
  /// **'Organisateur'**
  String get organizer;

  /// No description provided for @guest.
  ///
  /// In fr, this message translates to:
  /// **'Invité'**
  String get guest;

  /// No description provided for @events.
  ///
  /// In fr, this message translates to:
  /// **'Événements'**
  String get events;

  /// No description provided for @myInvitations.
  ///
  /// In fr, this message translates to:
  /// **'Mes invitations'**
  String get myInvitations;

  /// No description provided for @addEvent.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un événement'**
  String get addEvent;

  /// No description provided for @editEvent.
  ///
  /// In fr, this message translates to:
  /// **'Modifier l\'événement'**
  String get editEvent;

  /// No description provided for @eventTitle.
  ///
  /// In fr, this message translates to:
  /// **'Titre de l\'événement'**
  String get eventTitle;

  /// No description provided for @description.
  ///
  /// In fr, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @date.
  ///
  /// In fr, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @location.
  ///
  /// In fr, this message translates to:
  /// **'Lieu'**
  String get location;

  /// No description provided for @category.
  ///
  /// In fr, this message translates to:
  /// **'Catégorie'**
  String get category;

  /// No description provided for @save.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get cancel;

  /// No description provided for @inviteGuest.
  ///
  /// In fr, this message translates to:
  /// **'Inviter un invité'**
  String get inviteGuest;

  /// No description provided for @guestEmail.
  ///
  /// In fr, this message translates to:
  /// **'Email de l\'invité'**
  String get guestEmail;

  /// No description provided for @invite.
  ///
  /// In fr, this message translates to:
  /// **'Inviter'**
  String get invite;

  /// No description provided for @scanQr.
  ///
  /// In fr, this message translates to:
  /// **'Scanner QR'**
  String get scanQr;

  /// No description provided for @myQrCode.
  ///
  /// In fr, this message translates to:
  /// **'Mon QR code'**
  String get myQrCode;

  /// No description provided for @verifyQr.
  ///
  /// In fr, this message translates to:
  /// **'Vérifier le code'**
  String get verifyQr;

  /// No description provided for @success.
  ///
  /// In fr, this message translates to:
  /// **'Succès'**
  String get success;

  /// No description provided for @error.
  ///
  /// In fr, this message translates to:
  /// **'Erreur'**
  String get error;

  /// No description provided for @loading.
  ///
  /// In fr, this message translates to:
  /// **'Chargement...'**
  String get loading;

  /// No description provided for @logout.
  ///
  /// In fr, this message translates to:
  /// **'Déconnexion'**
  String get logout;

  /// No description provided for @settings.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get language;

  /// No description provided for @arabic.
  ///
  /// In fr, this message translates to:
  /// **'Arabe'**
  String get arabic;

  /// No description provided for @french.
  ///
  /// In fr, this message translates to:
  /// **'Français'**
  String get french;

  /// No description provided for @noEvents.
  ///
  /// In fr, this message translates to:
  /// **'Aucun événement'**
  String get noEvents;

  /// No description provided for @noInvitations.
  ///
  /// In fr, this message translates to:
  /// **'Aucune invitation'**
  String get noInvitations;

  /// No description provided for @inviteSent.
  ///
  /// In fr, this message translates to:
  /// **'Invitation envoyée'**
  String get inviteSent;

  /// No description provided for @qrVerified.
  ///
  /// In fr, this message translates to:
  /// **'Vérifié avec succès ✅'**
  String get qrVerified;

  /// No description provided for @qrUsed.
  ///
  /// In fr, this message translates to:
  /// **'Code déjà utilisé ❌'**
  String get qrUsed;

  /// No description provided for @qrInvalid.
  ///
  /// In fr, this message translates to:
  /// **'Code invalide ❌'**
  String get qrInvalid;

  /// No description provided for @pending.
  ///
  /// In fr, this message translates to:
  /// **'En attente'**
  String get pending;

  /// No description provided for @used.
  ///
  /// In fr, this message translates to:
  /// **'Utilisé'**
  String get used;

  /// No description provided for @deleteEvent.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer l\'événement'**
  String get deleteEvent;

  /// No description provided for @confirmDelete.
  ///
  /// In fr, this message translates to:
  /// **'Voulez-vous supprimer cet événement ?'**
  String get confirmDelete;

  /// No description provided for @yes.
  ///
  /// In fr, this message translates to:
  /// **'Oui'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In fr, this message translates to:
  /// **'Non'**
  String get no;

  /// No description provided for @haveAccount.
  ///
  /// In fr, this message translates to:
  /// **'Vous avez déjà un compte ?'**
  String get haveAccount;

  /// No description provided for @noAccount.
  ///
  /// In fr, this message translates to:
  /// **'Pas encore de compte ?'**
  String get noAccount;

  /// No description provided for @selectDate.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionner une date'**
  String get selectDate;

  /// No description provided for @selectCategory.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionner une catégorie'**
  String get selectCategory;

  /// No description provided for @fieldRequired.
  ///
  /// In fr, this message translates to:
  /// **'Ce champ est requis'**
  String get fieldRequired;

  /// No description provided for @invalidEmail.
  ///
  /// In fr, this message translates to:
  /// **'Email invalide'**
  String get invalidEmail;

  /// No description provided for @passwordMin.
  ///
  /// In fr, this message translates to:
  /// **'Au moins 6 caractères'**
  String get passwordMin;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
