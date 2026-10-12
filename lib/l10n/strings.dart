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
    'hardMode': [
      'Hard Mode',
      'مشکل موڈ',
      'الوضع الصعب',
      'Modo difícil'
    ],
    'hardModeDesc': [
      'Revealed hints must be used in guesses',
      'ظاہر شدہ اشارے اندازوں میں استعمال کرنے ہوں گے',
      'يجب استخدام التلميحات المكشوفة في التخمينات',
      'Las pistas reveladas deben usarse'
    ],
    'hardModeGreen': [
      'Green letter must stay in the same spot',
      'سبز حرف اسی جگہ رہنا چاہیے',
      'يجب أن يبقى الحرف الأخضر في نفس المكان',
      'La letra verde debe quedarse en su lugar'
    ],
    'hardModeYellow': [
      'Guess must include the revealed letter',
      'اندازے میں ظاہر شدہ حرف شامل ہونا چاہیے',
      'يجب أن يتضمن التخمين الحرف المكشوف',
      'El intento debe incluir la letra revelada'
    ],
    'colorBlind': [
      'Color Blind Mode',
      'کلر بلائنڈ موڈ',
      'وضع عمى الألوان',
      'Modo daltónico'
    ],
    'colorBlindDesc': [
      'High contrast orange and blue colors',
      'تیز کنٹراسٹ نارنجی اور نیلے رنگ',
      'ألوان برتقالية وزرقاء عالية التباين',
      'Colores naranja y azul de alto contraste'
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
      'Win any of the 5 daily puzzles to earn \$0.05. Each puzzle pays only once \u2014 practice games earn nothing. Cash rewards are limited to 5 wins per day for everyone. Withdraw once your balance reaches \$5.00. Premium (\$10/3 months, \$15/6 months): 20 daily puzzles, no ads, extra hints \u2014 cash rewards stay capped at 5/day.',
      'روز کی 5 پہیلیوں میں سے کوئی بھی جیتیں اور \$0.05 کمائیں۔ ہر پہیلی پر صرف ایک بار انعام ملتا ہے — مشق والے کھیل پر کچھ نہیں ملتا۔ کیش انعام سب کے لیے روزانہ 5 جیت تک محدود ہے۔ بیلنس \$5.00 ہو جائے تو رقم نکلوا سکتے ہیں۔ پریمیم (3 ماہ \$10، 6 ماہ \$15): روز 20 پہیلیاں، بغیر اشتہار، اضافی اشارے — کیش انعام پھر بھی 5/روز تک۔',
      'اربح أيًّا من الألغاز اليومية الخمسة لتحصل على \$0.05. كل لغز يدفع مرة واحدة فقط — ألعاب التدريب لا تمنح شيئًا. المكافآت النقدية محدودة بـ 5 انتصارات يوميًا للجميع. يمكنك السحب عندما يصل رصيدك إلى \$5.00. المميز (\$10/3 أشهر، \$15/6 أشهر): 20 لغزًا يوميًا، بلا إعلانات، تلميحات إضافية — وتبقى المكافآت النقدية محدودة بـ 5/يوم.',
      'Gana cualquiera de los 5 puzzles diarios y recibe \$0.05. Cada puzzle paga una sola vez — la práctica no da recompensa. Las recompensas en efectivo están limitadas a 5 victorias al día para todos. Podrás retirar cuando tu saldo llegue a \$5.00. Premium (\$10/3 meses, \$15/6 meses): 20 puzzles diarios, sin anuncios, más pistas — las recompensas siguen limitadas a 5/día.'
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
        'enterNameTitle': [
      'What should we call you?',
      'آپ کو کیا کہیں؟',
      'ما اسمك؟',
      '¿Cómo te llamamos?'
    ],
    'enterNameDesc': [
      'Enter your name so we can identify you for rewards and withdrawals.',
      'اپنا نام درج کریں تاکہ انعامات اور رقم نکلوانے کے لیے آپ کی شناخت ہو سکے۔',
      'أدخل اسمك حتى نتمكن من التعرف عليك للمكافآت والسحوبات.',
      'Ingresa tu nombre para identificarte en recompensas y retiros.'
    ],
    'yourName': [
      'Your name',
      'آپ کا نام',
      'اسمك',
      'Tu nombre'
    ],
    'nameHint': [
      'e.g. Ahmed Khan',
      'مثلاً احمد خان',
      'مثال: أحمد خان',
      'p. ej. Ahmed Khan'
    ],
    'continueBtn': [
      'Continue',
      'جاری رکھیں',
      'متابعة',
      'Continuar'
    ],
    'premiumTitle': [
      'Go Premium',
      'پریمیم حاصل کریں',
      'اشترك في المميز',
      'Hazte Premium'
    ],
    'choosePackage': [
      'Choose a package',
      'پیکیج منتخب کریں',
      'اختر الباقة',
      'Elige un paquete'
    ],
    'package3mo': [
      '3 Months Premium',
      '3 ماہ پریمیم',
      'المميز 3 أشهر',
      'Premium 3 meses'
    ],
    'package6mo': [
      '6 Months Premium',
      '6 ماہ پریمیم',
      'المميز 6 أشهر',
      'Premium 6 meses'
    ],
    'premiumFeatures': [
      '20 puzzles/day • No ads • Extra hints',
      'روز 20 پہیلیاں • بغیر اشتہار • اضافی اشارے',
      '20 لغزًا/يوم • بلا إعلانات • تلميحات إضافية',
      '20 puzzles/día • Sin anuncios • Más pistas'
    ],
    'bestValue': [
      'Best value',
      'بہترین',
      'الأفضل',
      'Mejor valor'
    ],
    'howToPay': [
      'How to pay',
      'ادائیگی کا طریقہ',
      'كيفية الدفع',
      'Cómo pagar'
    ],
    'paymentRef': [
      'Payment reference / Transaction ID',
      'ادائیگی کا حوالہ / ٹرانزیکشن آئی ڈی',
      'مرجع الدفع / معرف المعاملة',
      'Referencia de pago / ID de transacción'
    ],
    'paymentRefHint': [
      'Enter the ID from your payment app',
      'اپنی پیمنٹ ایپ سے آئی ڈی درج کریں',
      'أدخل المعرف من تطبيق الدفع',
      'Ingresa el ID de tu app de pago'
    ],
    'submitApplication': [
      'Submit Application',
      'درخواست جمع کرائیں',
      'إرسال الطلب',
      'Enviar solicitud'
    ],
    'premiumNote': [
      'Cash rewards are capped at 5 wins/day for everyone. Premium gives you more puzzles to enjoy!',
      'کیش انعام سب کے لیے روزانہ 5 جیت تک ہے۔ پریمیم سے آپ کو کھیلنے کے لیے مزید پہیلیاں ملتی ہیں!',
      'المكافآت النقدية محدودة بـ 5 انتصارات يوميًا للجميع. يمنحك المميز المزيد من الألغاز للاستمتاع!',
      'Las recompensas están limitadas a 5 victorias/día para todos. ¡Premium te da más puzzles para disfrutar!'
    ],
    'applicationSubmitted': [
      'Application Submitted!',
      'درخواست جمع ہو گئی!',
      'تم إرسال الطلب!',
      '¡Solicitud enviada!'
    ],
    'applicationPending': [
      'We will review your payment and activate premium soon.',
      'ہم آپ کی ادائیگی کی تصدیق کرکے جلد پریمیم فعال کر دیں گے۔',
      'سنراجع دفعتك ونفعّل المميز قريبًا.',
      'Revisaremos tu pago y activaremos premium pronto.'
    ],
    'backBtn': [
      'Back',
      'واپس',
      'رجوع',
      'Atrás'
    ],
    'withdrawTitle': [
      'Withdraw Earnings',
      'رقم نکلوائیں',
      'سحب الأرباح',
      'Retirar ganancias'
    ],
    'yourBalance': [
      'Your balance',
      'آپ کا بیلنس',
      'رصيدك',
      'Tu saldo'
    ],
    'minWithdrawal': [
      'Minimum',
      'کم از کم',
      'الحد الأدنى',
      'Mínimo'
    ],
    'payoutMethod': [
      'Payout method',
      'ادائیگی کا طریقہ',
      'طريقة الدفع',
      'Método de pago'
    ],
    'accountDetails': [
      'Account details',
      'اکاؤنٹ کی تفصیلات',
      'تفاصيل الحساب',
      'Detalles de la cuenta'
    ],
    'accountDetailsHint': [
      'Easypaisa number / USDT address etc.',
      'ایزی پیسہ نمبر / USDT ایڈریس وغیرہ',
      'رقم Easypaisa / عنوان USDT إلخ',
      'Número Easypaisa / dirección USDT etc.'
    ],
    'requestWithdrawal': [
      'Request Withdrawal',
      'رقم نکلوانے کی درخواست',
      'طلب السحب',
      'Solicitar retiro'
    ],
    'withdrawLocked': [
      'Reach $5.00 to unlock withdrawals. Keep playing!',
      'رقم نکلوانے کے لیے $5.00 تک پہنچیں۔ کھیلتے رہیں!',
      'اصِل إلى $5.00 لفتح السحوبات. واصل اللعب!',
      '¡Llega a $5.00 para desbloquear retiros. Sigue jugando!'
    ],
    'withdrawSubmitted': [
      'Request Submitted!',
      'درخواست جمع ہو گئی!',
      'تم إرسال الطلب!',
      '¡Solicitud enviada!'
    ],
    'withdrawPending': [
      'We will process your payment soon.',
      'ہم جلد آپ کی ادائیگی کر دیں گے۔',
      'سنعالج دفعتك قريبًا.',
      'Procesaremos tu pago pronto.'
    ],
  };
}
