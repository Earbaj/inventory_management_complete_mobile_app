
abstract class LanguageEvent {
  const LanguageEvent();
}

class LoadSavedLanguageEvent extends LanguageEvent {
  const LoadSavedLanguageEvent();
}

class ChangeLanguageEvent extends LanguageEvent {
  final String languageCode;
  const ChangeLanguageEvent(this.languageCode);
}
