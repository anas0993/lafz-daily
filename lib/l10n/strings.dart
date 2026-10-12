/// UI strings in English, Urdu, Arabic and Spanish.
/// The single app language setting switches both the UI and the puzzle
/// language, so every key below has all four translations, ordered
/// [en, ur, ar, es] (matching the order of [AppLang] values).
enum AppLang { en, ur, ar, es }

class S {
  S(this.lang);
  final AppLang lang;

  static const Map<String, List<String>> _t = {
    'tagline': [
      'A new word every day',
      'ہر روز ایک نیا لفظ',
      'كلمة جديدة كل يوم',
      'Una palabra nueva cada día'
    ],
    'playDaily': ['Play Daily', 'روزانہ کھیلیں', 'العب اليومية', 'Jugar diario'],
    'practice': ['Practice', 'مشق کریں', 'تدريب', 'Práctica'],
    'practiceSub': [
      'Unlimited random words',
      'لامحدود بے ترتیب الفاظ',
      'كلمات عشوائية بلا حدود',
      'Palabras aleatorias ilimitadas'
    ],
    'stats': ['Statistics', 'شماریات', 'الإحصائيات', 'Estadísticas'],
    'settings': ['Settings', 'ترتیبات', 'الإعدادات', 'Ajustes'],
    'howToPlay': ['How to Play', 'کھیلنے کا طریقہ', 'كيف تلعب', 'Cómo jugar'],
    'played': ['Played', 'کھیلے', 'لُعبت', 'Jugadas'],
    'winPct': ['Win %', 'جیت %', 'نسبة الفوز %', 'Victorias %'],
    'curStreak': [
      'Current Streak',
      'موجودہ سلسلہ',
      'السلسلة الحالية',
      'Racha actual'
    ],
    'maxStreak': [
      'Max Streak',
      'طویل ترین سلسلہ',
      'أطول سلسلة',
      'Mejor racha'
    ],
    'distribution': [
      'Guess Distribution',
      'اندازوں کی تقسیم',
      'توزيع المحاولات',
      'Distribución de intentos'
    ],
    'notInList': [
      'Not in word list',
      'یہ لفظ فہرست میں نہیں',
      'ليست في قائمة الكلمات',
      'No está en la lista'
    ],
    'notEnough': [
      'Not enough letters',
      'حروف مکمل کریں',
      'أكمل الحروف',
      'Faltan letras'
    ],
    'share': ['SHARE', 'شیئر کریں', 'مشاركة', 'COMPARTIR'],
    'nextIn': [
      'Next puzzle in',
      'اگلی پہیلی',
      'اللغز التالي خلال',
      'Próximo reto en'
    ],
    'hint': ['Hint', 'اشارہ', 'تلميح', 'Pista'],
    'hintsLeft': ['hints left', 'اشارے باقی', 'تلميحات متبقية', 'pistas restantes'],
    'watchAdHint': [
      'Watch ad for hint',
      'اشارے کے لیے اشتہار دیکھیں',
      'شاهد إعلانًا للحصول على تلميح',
      'Mira un anuncio para una pista'
    ],
    'noHints': [
      'No hints left today',
      'آج کوئی اشارہ باقی نہیں',
      'لا تلميحات متبقية اليوم',
      'Sin pistas hoy'
    ],
    'hintRevealed': [
      'Hint revealed!',
      'اشارہ مل گیا!',
      'تم كشف التلميح!',
      '¡Pista revelada!'
    ],
    'adLoading': [
      'Loading ad…',
      'اشتہار لوڈ ہو رہا ہے…',
      'جارٍ تحميل الإعلان…',
      'Cargando anuncio…'
    ],
    'adNotReady': [
      'Ad not ready, try again',
      'اشتہار تیار نہیں، دوبارہ کوشش کریں',
      'الإعلان غير جاهز، حاول مجددًا',
      'Anuncio no listo, inténtalo de nuevo'
    ],
    'dailyReminder': [
      'Daily reminder',
      'روزانہ یاد دہانی',
      'تذكير يومي',
      'Recordatorio diario'
    ],
    'reminderTime': [
      'Reminder time',
      'یاد دہانی کا وقت',
      'وقت التذكير',
      'Hora del recordatorio'
    ],
    'reminderBody': [
      'Your daily word is waiting!',
      'آپ کا روزانہ لفظ منتظر ہے!',
      'كلمتك اليومية بانتظارك!',
      '¡Tu palabra diaria te espera!'
    ],
    'language': ['Language / زبان', 'زبان / Language', 'اللغة / Language', 'Idioma / Language'],
    'proTitle': ['Lafz Daily Pro', 'لفظ ڈیلی پرو', 'لفظ يومي برو', 'Lafz Diario Pro'],
    'proF1': ['No ads, ever', 'کبھی اشتہار نہیں', 'بلا إعلانات أبدًا', 'Sin anuncios, nunca'],
    'proF2': [
      'Puzzle archive — replay any day',
      'پرانی پہیلیاں — کوئی بھی دن کھیلیں',
      'أرشيف الألغاز — أعد لعب أي يوم',
      'Archivo de retos: repite cualquier día'
    ],
    'proF3': [
      'Extra stats & streak freeze',
      'اضافی شماریات',
      'إحصائيات إضافية',
      'Más estadísticas'
    ],
    'oneTime': ['One-time purchase', 'ایک بار کی خریداری', 'دفعة واحدة', 'Compra única'],
    'buyPro': ['Buy Pro', 'پرو خریدیں', 'اشترِ برو', 'Comprar Pro'],
    'restore': [
      'Restore purchases',
      'خریداری بحال کریں',
      'استعادة المشتريات',
      'Restaurar compras'
    ],
    'proActive': ['Pro is active 🎉', 'پرو فعال ہے 🎉', 'برو مفعّل 🎉', 'Pro activado 🎉'],
    'proWelcome': [
      'Welcome to Pro!',
      'پرو میں خوش آمدید!',
      'مرحبًا بك في برو!',
      '¡Bienvenido a Pro!'
    ],
    'purchaseFailed': [
      'Purchase failed',
      'خریداری ناکام ہوئی',
      'فشلت عملية الشراء',
      'La compra falló'
    ],
    'proUnavailable': [
      'Pro upgrade not available yet',
      'پرو اپ گریڈ ابھی دستیاب نہیں',
      'ترقية برو غير متاحة بعد',
      'La mejora Pro aún no está disponible'
    ],
    'privacy': [
      'Privacy Policy',
      'پرائیویسی پالیسی',
      'سياسة الخصوصية',
      'Política de privacidad'
    ],
    'terms': [
      'Terms of Service',
      'شرائطِ استعمال',
      'شروط الاستخدام',
      'Términos de servicio'
    ],
    'rateUs': ['Rate us', 'ہمیں ریٹ کریں', 'قيّمنا', 'Valóranos'],
    'shareApp': ['Share app', 'ایپ شیئر کریں', 'شارك التطبيق', 'Compartir app'],
    'youWon': ['Brilliant!', 'شاباش!', 'رائع!', '¡Genial!'],
    'youLost': ['Good try!', 'اچھی کوشش!', 'محاولة جيدة!', '¡Buen intento!'],
    'answerWas': ['The word was', 'لفظ تھا', 'كانت الكلمة', 'La palabra era'],
    'archive': ['Archive', 'پرانی پہیلیاں', 'الأرشيف', 'Archivo'],
    'pickDay': ['Pick a day', 'دن منتخب کریں', 'اختر يومًا', 'Elige un día'],
    'proOnly': ['Pro only', 'صرف پرو', 'لبرو فقط', 'Solo Pro'],
    'enter': ['ENTER', 'ٹھیک', 'إدخال', 'ENVIAR'],
    'daily': ['Daily', 'روزانہ', 'يومي', 'Diario'],
    'practiceMode': ['Practice', 'مشق', 'تدريب', 'Práctica'],
    'streak': ['🔥 streak', '🔥 سلسلہ', '🔥 سلسلة', '🔥 racha'],
    'comeBack': [
      'Come back tomorrow!',
      'کل دوبارہ آئیں!',
      'عُد غدًا!',
      '¡Vuelve mañana!'
    ],
    'copied': ['Copied!', 'کاپی ہو گیا!', 'تم النسخ!', '¡Copiado!'],
    'shareText': [
      'I play Lafz Daily — try it!',
      'میں لفظ ڈیلی کھیلتا ہوں — آپ بھی آزمائیں!',
      'ألعب لفظ يومي — جرّبه!',
      '¡Juego a Lafz Diario — pruébalo!'
    ],
    'ok': ['OK', 'ٹھیک ہے', 'حسنًا', 'Aceptar'],
    'cancel': ['Cancel', 'منسوخ', 'إلغاء', 'Cancelar'],
    'save': ['Save', 'محفوظ کریں', 'حفظ', 'Guardar'],
    'how1t': [
      'Guess the hidden 5-letter word',
      'چھپا ہوا 5 حرفی لفظ پہچانیں',
      'خمّن الكلمة المخفية من 5 أحرف',
      'Adivina la palabra oculta de 5 letras'
    ],
    'how1b': [
      'You get 6 tries. Type any valid word and press ENTER.',
      'آپ کو 6 مواقع ملتے ہیں۔ کوئی درست لفظ لکھ کر ENTER دبائیں۔',
      'لديك 6 محاولات. اكتب كلمة صحيحة واضغط إدخال.',
      'Tienes 6 intentos. Escribe una palabra válida y pulsa ENVIAR.'
    ],
    'how2t': [
      'Letters change color',
      'حروف رنگ بدلتے ہیں',
      'تتغير ألوان الحروف',
      'Las letras cambian de color'
    ],
    'how2b': [
      'Green = right letter, right spot. Yellow = right letter, wrong spot. Gray = not in the word.',
      'سبز = صحیح حرف صحیح جگہ۔ پیلا = حرف درست، جگہ غلط۔ سرمئی = لفظ میں نہیں۔',
      'الأخضر = الحرف الصحيح في المكان الصحيح. الأصفر = الحرف صحيح والمكان خطأ. الرمادي = ليس في الكلمة.',
      'Verde = letra correcta en su sitio. Amarillo = letra correcta en otro sitio. Gris = no está en la palabra.'
    ],
    'how3t': [
      'A new puzzle every day',
      'ہر روز نئی پہیلی',
      'لغز جديد كل يوم',
      'Un reto nuevo cada día'
    ],
    'how3b': [
      'Everyone gets the same word. Keep your streak alive!',
      'سب کو ایک ہی لفظ ملتا ہے۔ اپنا سلسلہ برقرار رکھیں!',
      'الجميع يحصل على نفس الكلمة. حافظ على سلسلتك!',
      'Todos reciben la misma palabra. ¡Mantén tu racha!'
    ],
    'earnT': [
      'Earn real rewards',
      'اصل انعام کمائیں',
      'اربح مكافآت حقيقية',
      'Gana recompensas reales'
    ],
    'earnB': [
      'Win any of the 5 daily puzzles to earn \$0.05. Each puzzle pays only once — practice games earn nothing. Withdraw once your balance reaches \$5.00. Premium: 20 daily puzzles — \$10 for 3 months, \$15 for 6 months.',
      'روز کی 5 پہیلیوں میں سے کوئی بھی جیتیں اور \$0.05 کمائیں۔ ہر پہیلی پر صرف ایک بار انعام ملتا ہے — مشق والے کھیل پر کچھ نہیں ملتا۔ بیلنس \$5.00 ہو جائے تو رقم نکلوا سکتے ہیں۔ پریمیم: روز 20 پہیلیاں — 3 ماہ \$10، 6 ماہ \$15۔',
      'اربح أيًّا من الألغاز اليومية الخمسة لتحصل على \$0.05. كل لغز يدفع مرة واحدة فقط — ألعاب التدريب لا تمنح شيئًا. يمكنك السحب عندما يصل رصيدك إلى \$5.00. المميز: 20 لغزًا يوميًا — \$10 لثلاثة أشهر، \$15 لستة أشهر.',
      'Gana cualquiera de los 5 puzzles diarios y recibe \$0.05. Cada puzzle paga una sola vez — la práctica no da recompensa. Podrás retirar cuando tu saldo llegue a \$5.00. Premium: 20 puzzles diarios — \$10 por 3 meses, \$15 por 6 meses.'
    ],
    'exampleWord': ['A sample word', 'مثال کے طور پر', 'كلمة للتوضيح', 'Palabra de ejemplo'],
    'version': ['Version', 'ورژن', 'الإصدار', 'Versión'],
    'notifTitle': ['Lafz Daily', 'لفظ ڈیلی', 'لفظ يومي', 'Lafz Diario'],
    'streakLost': [
      'Streak reset — play today!',
      'سلسلہ ٹوٹ گیا — آج کھیلیں!',
      'انقطعت السلسلة — العب اليوم!',
      '¡Racha perdida — juega hoy!'
    ],
    'balance': ['Balance', 'بیلنس', 'الرصيد', 'Saldo'],
    'youWonReward': [
      'You earned \$0.05!',
      'آپ نے \$0.05 جیتے!',
      'لقد ربحت \$0.05!',
      '¡Ganaste \$0.05!'
    ],
    'dailyPuzzles': [
      "Today's puzzles",
      'آج کی پہیلیاں',
      'ألغاز اليوم',
      'Puzzles de hoy'
    ],
    'nextPuzzle': ['Next puzzle', 'اگلی پہیلی', 'اللغز التالي', 'Siguiente'],
    'history': ['History', 'ہسٹری', 'السجل', 'Historial'],
    'noHistory': [
      'No earnings yet — win a daily puzzle!',
      'ابھی کوئی کمائی نہیں — روزانہ پہیلی جیتیں!',
      'لا أرباح بعد — اربح لغز اليوم!',
      'Sin ganancias aún — ¡gana el puzzle diario!'
    ],
    'practiceEarnsNothing': [
      'Practice is just for fun — only daily puzzles earn.',
      'مشق صرف مزے کے لیے ہے — صرف روزانہ پہیلیوں پر کمائی ہوتی ہے۔',
      'التدريب للمتعة فقط — الألغاز اليومية هي التي تربح.',
      'La práctica es solo diversión — solo los puzzles diarios ganan.'
    ],
  };

  /// Index of each language in the [_t] value lists.
  static const Map<AppLang, int> _index = {
    AppLang.en: 0,
    AppLang.ur: 1,
    AppLang.ar: 2,
    AppLang.es: 3,
  };

  String get(String key) => _t[key]![_index[lang]!];

  /// "Lafz Daily #123 4/6" / per-language branding.
  String puzzleTag(int number) => switch (lang) {
        AppLang.en => 'Lafz Daily #$number',
        AppLang.ur => 'لفظ ڈیلی #$number',
        AppLang.ar => 'لفظ يومي #$number',
        AppLang.es => 'Lafz Diario #$number',
      };

  /// "Puzzle 3 of 5" for the daily slot header.
  String puzzleOf(int i, int total) => switch (lang) {
        AppLang.en => 'Puzzle $i of $total',
        AppLang.ur => 'پہیلی $i از $total',
        AppLang.ar => 'اللغز $i من $total',
        AppLang.es => 'Puzzle $i de $total',
      };

  /// Feedback toast after a wrong (but valid) guess.
  String guessFeedback(int correct, int present) => switch (lang) {
        AppLang.en => '$correct exact • $present misplaced — try again!',
        AppLang.ur =>
          '$correct بالکل صحیح • $present غلط جگہ — دوبارہ کوشش کریں!',
        AppLang.ar =>
          '$correct في مكانها • $present في مكان خاطئ — حاول مجددًا!',
        AppLang.es =>
          '$correct exactas • $present mal ubicadas — ¡otra vez!',
      };
}
