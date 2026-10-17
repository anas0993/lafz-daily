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
    'proTitle': ['Word Daily Pro', 'لفظ ڈیلی پرو', 'لفظ يومي برو', 'Word Diario Pro'],
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
      'I play Word Daily — try it!',
      'میں لفظ ڈیلی کھیلتا ہوں — آپ بھی آزمائیں!',
      'ألعب لفظ يومي — جرّبه!',
      '¡Juego a Word Diario — pruébalo!'
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
    'notifTitle': ['Word Daily', 'لفظ ڈیلی', 'لفظ يومي', 'Word Diario'],
    'streakLost': [
      'Streak reset — play today!',
      'سلسلہ ٹوٹ گیا — آج کھیلیں!',
      'انقطعت السلسلة — العب اليوم!',
      '¡Racha perdida — juega hoy!'
    ],
    'balance': ['Balance', 'بیلنس', 'الرصيد', 'Saldo'],
    'wins': ['Wins', 'جیت', 'الفوز', 'Victorias'],
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
      'Reach \$5.00 to unlock withdrawals. Keep playing!',
      'رقم نکلوانے کے لیے \$5.00 تک پہنچیں۔ کھیلتے رہیں!',
      'اصِل إلى \$5.00 لفتح السحوبات. واصل اللعب!',
      '¡Llega a \$5.00 para desbloquear retiros. Sigue jugando!'
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

    // ===== v4 additions (WS1-WS5) =====
    'emptyBoardHint': [
      'Type your first word 👇',
      'اپنا پہلا لفظ لکھیں 👇',
      'اكتب أول كلمة 👇',
      'Escribe tu primera palabra 👇',
    ],
    'tutorialStep1': [
      'Type a 5-letter word',
      'پانچ حروف کا لفظ لکھیں',
      'اكتب كلمة من 5 أحرف',
      'Escribe una palabra de 5 letras',
    ],
    'tutorialStep2': [
      'Press ENTER to guess',
      'اندازہ لگانے کے لیے ENTER دبائیں',
      'اضغط ENTER للتخمين',
      'Pulsa ENVIAR para adivinar',
    ],
    'tutorialStep3': [
      'Green = correct spot, Yellow = wrong spot',
      'سبز = صحیح جگہ، پیلا = غلط جگہ',
      'الأخضر = المكان الصحيح، الأصفر = المكان الخطأ',
      'Verde = posición correcta, Amarillo = posición incorrecta',
    ],
    'tutorialNext': [
      'Next',
      'آگے',
      'التالي',
      'Siguiente',
    ],
    'tutorialSkip': [
      'Skip',
      'چھوڑیں',
      'تخطَّ',
      'Omitir',
    ],
    'tutorialGotIt': [
      'Got it!',
      'سمجھ گیا!',
      'فهمت!',
      '¡Entendido!',
    ],
    'scramble': [
      'Scramble',
      'اسکرمبل',
      'لعبة الخلط',
      'Revoltijo',
    ],
    'scrambleSub': [
      'Unscramble the letters',
      'بکھرے حروف کو ترتیب دیں',
      'رتّب الحروف المبعثرة',
      'Ordena las letras',
    ],
    'scrambleHelp': [
      'Tap letters to fill the slots',
      'خانے بھرنے کے لیے حروف پر ٹیپ کریں',
      'اضغط على الحروف لملء الخانات',
      'Toca las letras para rellenar',
    ],
    'scrambleCheck': [
      'Check',
      'چیک کریں',
      'تحقّق',
      'Comprobar',
    ],
    'scrambleNewWord': [
      'New Word',
      'نیا لفظ',
      'كلمة جديدة',
      'Nueva palabra',
    ],
    'scrambleWin': [
      'You unscrambled it!',
      'آپ نے درست ترتیب دے دی!',
      'أحسنت! رتّبتها بشكل صحيح!',
      '¡Lo ordenaste!',
    ],
    'scrambleWrong': [
      'Not quite — try again',
      'درست نہیں — دوبارہ کوشش کریں',
      'ليس صحيحًا — حاول مجددًا',
      'Casi — inténtalo de nuevo',
    ],
    'scrambleWins': [
      'Scramble Wins',
      'اسکرمبل جیتیں',
      'انتصارات الخلط',
      'Victorias de scramble',
    ],
    'shareCopied': [
      'Copied! Paste it anywhere 📋',
      'کاپی ہو گیا! جہاں چاہیں پیسٹ کریں 📋',
      'تم النسخ! الصقه في أي مكان 📋',
      '¡Copiado! Pégalo donde quieras 📋',
    ],
    'challengeTitle': [
      'Challenge a Friend',
      'دوست کو چیلنج کریں',
      'تحدَّ صديقًا',
      'Desafía a un amigo',
    ],
    'challengeBannerSub': [
      'Play with friends!',
      'دوستوں کے ساتھ کھیلیں!',
      'العب مع أصدقائك!',
      '¡Juega con amigos!',
    ],
    'createChallenge': [
      'Create a challenge',
      'چیلنج بنائیں',
      'أنشئ تحديًا',
      'Crea un reto',
    ],
    'joinChallenge': [
      'Join a challenge',
      'چیلنج میں شامل ہوں',
      'انضم إلى تحدٍّ',
      'Únete a un reto',
    ],
    'yourWord': [
      'Your 5-letter word',
      'آپ کا 5 حرفی لفظ',
      'كلمتك المكوّنة من 5 أحرف',
      'Tu palabra de 5 letras',
    ],
    'createCode': [
      'Create code',
      'کوڈ بنائیں',
      'أنشئ الرمز',
      'Crear código',
    ],
    'yourCode': [
      'Your challenge code',
      'آپ کا چیلنج کوڈ',
      'رمز التحدي الخاص بك',
      'Tu código de reto',
    ],
    'copyCode': [
      'Copy code',
      'کوڈ کاپی کریں',
      'نسخ الرمز',
      'Copiar código',
    ],
    'codeCopied': [
      'Code copied — send it to your friend!',
      'کوڈ کاپی ہو گیا — دوست کو بھیجیں!',
      'تم نسخ الرمز — أرسله إلى صديقك!',
      '¡Código copiado! ¡Envíalo a tu amigo!',
    ],
    'enterCode': [
      'Enter challenge code',
      'چیلنج کوڈ درج کریں',
      'أدخل رمز التحدي',
      'Introduce el código del reto',
    ],
    'playChallenge': [
      'Play challenge',
      'چیلنج کھیلیں',
      'العب التحدي',
      'Jugar reto',
    ],
    'wordMustBe5': [
      'Word must be exactly 5 letters',
      'لفظ بالکل 5 حروف کا ہونا چاہیے',
      'يجب أن تكون الكلمة 5 أحرف بالضبط',
      'La palabra debe tener exactamente 5 letras',
    ],
    'invalidCode': [
      'That code doesn’t look right — check and try again',
      'یہ کوڈ درست نہیں لگ رہا — چیک کر کے دوبارہ کوشش کریں',
      'هذا الرمز غير صحيح — تحقق وحاول مجددًا',
      'Ese código no es válido; revísalo e inténtalo de nuevo',
    ],
    'achievements': [
      'Achievements',
      'کارنامے',
      'الإنجازات',
      'Logros',
    ],
    'tournament': [
      'Weekly Tournament',
      'ہفتہ وار ٹورنامنٹ',
      'بطولة أسبوعية',
      'Torneo semanal',
    ],
    'coinsLabel': [
      'Coins',
      'سکے',
      'عملات',
      'Monedas',
    ],
    'dailyReward': [
      'Daily Reward',
      'روزانہ انعام',
      'مكافأة يومية',
      'Recompensa diaria',
    ],
    'dailyRewardSub': [
      'You\'ve earned coins for opening the app',
      'ایپ کھولنے پر آپ نے سکے کمائے',
      'لقد ربحت عملات لفتح التطبيق',
      'Has ganado monedas por abrir la app',
    ],
    'comeBackTomorrow': [
      'Come back tomorrow for a bigger reward',
      'بڑے انعام کے لیے کل دوبارہ آئیں',
      'عد غداً لمكافأة أكبر',
      'Vuelve mañana por una recompensa mayor',
    ],
    'claim': [
      'Claim',
      'وصول کریں',
      'استلام',
      'Reclamar',
    ],
    'milestoneReached': [
      'Streak milestone reached!',
      'مسلسل کھیلنے کا سنگ میل حاصل!',
      'تم تحقيق إنجاز السلسلة!',
      '¡Hito de racha alcanzado!',
    ],
    'achievementUnlocked': [
      'Achievement unlocked!',
      'کارنامہ حاصل ہوا!',
      'تم فتح الإنجاز!',
      '¡Logro desbloqueado!',
    ],
    'thisWeekWins': [
      'This week\'s wins',
      'اس ہفتے کی جیتیں',
      'انتصارات هذا الأسبوع',
      'Victorias de esta semana',
    ],
    'bestWeek': [
      'Best week ever',
      'اب تک کا بہترین ہفتہ',
      'أفضل أسبوع على الإطلاق',
      'Mejor semana',
    ],
    'yourRank': [
      'Your rank',
      'آپ کا درجہ',
      'رتبتك',
      'Tu rango',
    ],
    'rankBronze': [
      'Bronze',
      'کانسی',
      'برونزي',
      'Bronce',
    ],
    'rankSilver': [
      'Silver',
      'چاندی',
      'فضي',
      'Plata',
    ],
    'rankGold': [
      'Gold',
      'سونا',
      'ذهبي',
      'Oro',
    ],
    'rankDiamond': [
      'Diamond',
      'ہیرا',
      'ماسي',
      'Diamante',
    ],
    'globalSyncSoon': [
      'Global leaderboard sync is coming soon. Rankings are local for now.',
      'عالمی لیڈر بورڈ کی مطابقت جلد آرہی ہے۔ درجہ بندی فی الحال مقامی ہے۔',
      'ستأتي مزامنة لوحة الصدارة العالمية قريباً. الترتيب محلي حالياً.',
      'La sincronización del ranking global llegará pronto. Los rangos son locales por ahora.',
    ],
    'playMoreToRankUp': [
      'Win more puzzles to rank up!',
      'درجہ بڑھانے کے لیے مزید پہیلیاں جیتیں!',
      'اربح المزيد من الألغاز لترتقي!',
      '¡Gana más puzzles para subir de rango!',
    ],
    'weeklyResets': [
      'Resets every Monday',
      'ہر پیر کو ری سیٹ ہوتا ہے',
      'يُعاد الضبط كل يوم اثنين',
      'Se reinicia cada lunes',
    ],
    'achFirstWin': [
      'First Win',
      'پہلی جیت',
      'أول فوز',
      'Primera victoria',
    ],
    'achFirstWinDesc': [
      'Win your first puzzle',
      'اپنی پہلی پہیلی جیتیں',
      'اربح أول لغز لك',
      'Gana tu primer puzzle',
    ],
    'achRookie': [
      'Word Rookie',
      'لفظ نو آموز',
      'مبتدئ الكلمات',
      'Novato',
    ],
    'achRookieDesc': [
      'Win 10 puzzles',
      '10 پہیلیاں جیتیں',
      'اربح 10 ألغاز',
      'Gana 10 puzzles',
    ],
    'achPro': [
      'Word Pro',
      'لفظ ماہر',
      'محترف الكلمات',
      'Pro de palabras',
    ],
    'achProDesc': [
      'Win 50 puzzles',
      '50 پہیلیاں جیتیں',
      'اربح 50 لغزاً',
      'Gana 50 puzzles',
    ],
    'achMaster': [
      'Word Master',
      'لفظ استاد',
      'سيد الكلمات',
      'Maestro',
    ],
    'achMasterDesc': [
      'Win 100 puzzles',
      '100 پہیلیاں جیتیں',
      'اربح 100 لغز',
      'Gana 100 puzzles',
    ],
    'achSharp': [
      'Sharp Shooter',
      'تیز نشانہ باز',
      'الرامي الحاد',
      'Tirador certero',
    ],
    'achSharpDesc': [
      'Win a puzzle in 2 guesses or less',
      '2 یا کم اندازوں میں پہیلی جیتیں',
      'اربح لغزاً في محاولتين أو أقل',
      'Gana un puzzle en 2 intentos o menos',
    ],
    'achWeekWarrior': [
      'Week Warrior',
      'ہفتہ وار جنگجو',
      'محارب الأسبوع',
      'Guerrero semanal',
    ],
    'achWeekWarriorDesc': [
      'Play 7 days in a row',
      'لگاتار 7 دن کھیلیں',
      'العب 7 أيام متتالية',
      'Juega 7 días seguidos',
    ],
    'achMonthLegend': [
      'Month Legend',
      'ماہانہ لیجنڈ',
      'أسطورة الشهر',
      'Leyenda del mes',
    ],
    'achMonthLegendDesc': [
      'Play 30 days in a row',
      'لگاتار 30 دن کھیلیں',
      'العب 30 يوماً متتالية',
      'Juega 30 días seguidos',
    ],
    'achScramble': [
      'Scramble Master',
      'اسکرمبل ماہر',
      'سيد التشويش',
      'Maestro del scramble',
    ],
    'achScrambleDesc': [
      'Win 10 scramble games',
      '10 اسکرمبل گیمز جیتیں',
      'اربح 10 ألعاب تشويش',
      'Gana 10 juegos de scramble',
    ],
    'achLocked': [
      'Locked',
      'مقفل',
      'مقفل',
      'Bloqueado',
    ],
    'achUnlocked': [
      'Unlocked',
      'حاصل شدہ',
      'مفتوح',
      'Desbloqueado',
    ],
    'team': [
      'Team',
      'ٹیم',
      'الفريق',
      'Equipo',
    ],
    'teamName': [
      'Team name',
      'ٹیم کا نام',
      'اسم الفريق',
      'Nombre del equipo',
    ],
    'teamNameHint': [
      'e.g. "Word Warriors"',
      'مثلاً "لفظ کے جنگجو"',
      'مثل "محاربي الكلمات"',
      'p. ej. "Guerreros de palabras"',
    ],
    'createTeam': [
      'Create team',
      'ٹیم بنائیں',
      'أنشئ فريقًا',
      'Crear equipo',
    ],
    'joinTeam': [
      'Join team',
      'ٹیم میں شامل ہوں',
      'انضم إلى فريق',
      'Unirse al equipo',
    ],
    'teamNameInvalid': [
      'Please enter a valid team name',
      'براہ کرم درست ٹیم کا نام درج کریں',
      'يرجى إدخال اسم فريق صالح',
      'Introduce un nombre de equipo válido',
    ],
    'teamWins': [
      'Team wins',
      'ٹیم کی جیت',
      'انتصارات الفريق',
      'Victorias del equipo',
    ],
    'emptyBoard': [
      'No messages yet — say hello!',
      'ابھی کوئی پیغام نہیں — سلام کہیں!',
      'لا رسائل بعد — قل مرحبًا!',
      'Aún no hay mensajes. ¡Saluda!',
    ],
    'typeMessage': [
      'Type a message…',
      'پیغام لکھیں…',
      'اكتب رسالة…',
      'Escribe un mensaje…',
    ],
    'send': [
      'Send',
      'بھیجیں',
      'إرسال',
      'Enviar',
    ],
    'leaveTeam': [
      'Leave team',
      'ٹیم چھوڑیں',
      'مغادرة الفريق',
      'Abandonar el equipo',
    ],
    'leaveTeamConfirm': [
      'Are you sure you want to leave your team? Your local team data will be cleared.',
      'کیا آپ واقعی اپنی ٹیم چھوڑنا چاہتے ہیں؟ آپ کا مقامی ٹیم ڈیٹا صاف ہو جائے گا۔',
      'هل أنت متأكد من مغادرة فريقك؟ سيتم مسح بيانات فريقك المحلية.',
      '¿Seguro que quieres abandonar tu equipo? Tus datos locales del equipo se borrarán.',
    ],
    'confirm': [
      'Confirm',
      'تصدیق کریں',
      'تأكيد',
      'Confirmar',
    ],
    'leaderboard': [
      'Leaderboard',
      'لیڈر بورڈ',
      'لوحة المتصدرين',
      'Clasificación',
    ],
    'mostWins': [
      'Most Wins',
      'سب سے زیادہ جیت',
      'أكثر الانتصارات',
      'Más victorias',
    ],
    'bestStreak': [
      'Best Streak',
      'بہترین سلسلہ',
      'أفضل سلسلة',
      'Mejor racha',
    ],
    'yourScore': [
      'Your score',
      'آپ کا اسکور',
      'نتيجتك',
      'Tu puntuación',
    ],
    'you': [
      'You',
      'آپ',
      'أنت',
      'Tú',
    ],
    'friendSlotsSoon': [
      'Coming soon',
      'جلد آ رہا ہے',
      'قريبًا',
      'Próximamente',
    ],
    'shareCodeSoon': [
      'Friend comparison via share codes is coming soon.',
      'شیئر کوڈز کے ذریعے دوستوں سے موازنہ جلد آ رہا ہے۔',
      'مقارنة الأصدقاء عبر رموز المشاركة قادمة قريبًا.',
      'La comparación con amigos mediante códigos llegará pronto.',
    ],
    'notEnoughCoins': [
      'Not enough coins',
      'کافی سکے نہیں ہیں',
      'لا توجد عملات كافية',
      'No tienes suficientes monedas',
    ],
    'coins': [
      'Coins',
      'سکے',
      'عملات',
      'Monedas',
    ],
    'soundSettings': [
      'Sound',
      'آواز',
      'الصوت',
      'Sonido',
    ],
    'classic': [
      'Classic',
      'کلاسک',
      'كلاسيكي',
      'Clásico',
    ],
    'classicSub': [
      'Guess the 5-letter word',
      'پانچ حرفی لفظ پہچانیں',
      'خمّن الكلمة من ٥ أحرف',
      'Adivina la palabra de 5 letras',
    ],
    'dailyPuzzle': [
      'Daily Puzzle',
      'روزانہ پہیلی',
      'اللغز اليومي',
      'Puzzle diario',
    ],
    'dailyPuzzleSub': [
      'A fresh word every day',
      'روز ایک نیا لفظ',
      'كلمة جديدة كل يوم',
      'Una palabra nueva cada día',
    ],
    'wordFever': [
      'Word Fever',
      'ورڈ فیور',
      'حمى الكلمات',
      'Fiebre de palabras',
    ],
    'wordFeverSub': [
      'Race the clock, chain words',
      'وقت کے خلاف الفاظ بنائیں',
      'سابق الزمن واجمع الكلمات',
      'Contra el reloj, encadena palabras',
    ],
    'best': [
      'Best',
      'بہترین',
      'الأفضل',
      'Mejor',
    ],
    'newBadge': [
      'NEW',
      'نیا',
      'جديد',
      'NUEVO',
    ],
    'submit': [
      'SUBMIT',
      'جمع کریں',
      'إرسال',
      'ENVIAR',
    ],
    'hintTip': [
      'Hint: reveal a correct letter',
      'اشارہ: ایک صحیح حرف ظاہر کریں',
      'تلميح: اكشف حرفًا صحيحًا',
      'Pista: revela una letra correcta',
    ],
    'dartTip': [
      'Dart: remove a wrong letter',
      'ڈارٹ: ایک غلط حرف ہٹائیں',
      'السهم: أزل حرفًا خاطئًا',
      'Dardo: elimina una letra incorrecta',
    ],
    'skipTip': [
      'Skip: abandon this puzzle',
      'چھوڑیں: یہ پہیلی چھوڑ دیں',
      'تخطي: اترك هذا اللغز',
      'Omitir: abandona este puzzle',
    ],
    'dartUsed': [
      'A wrong letter is gone!',
      'ایک غلط حرف ختم ہو گیا!',
      'اختفى حرف خاطئ!',
      '¡Una letra incorrecta eliminada!',
    ],
    'noDarts': [
      'No darts left',
      'ڈارٹ ختم ہو گئے',
      'لا أسهم متبقية',
      'No quedan dardos',
    ],
    'noSkips': [
      'No skips left',
      'اسکپ ختم ہو گئے',
      'لا تخطيات متبقية',
      'No quedan omisiones',
    ],
    'dartLatinOnly': [
      'Dart works in English & Spanish for now',
      'ڈارٹ فی الحال انگریزی اور ہسپانوی میں کام کرتا ہے',
      'السهم يعمل بالإنجليزية والإسبانية حاليًا',
      'El dardo funciona en inglés y español por ahora',
    ],
    'skipTitle': [
      'Skip this puzzle?',
      'یہ پہیلی چھوڑ دیں؟',
      'تخطي هذا اللغز؟',
      '¿Omitir este puzzle?',
    ],
    'skipMsg': [
      'You will leave this puzzle unfinished.',
      'آپ یہ پہیلی ادھوری چھوڑ دیں گے۔',
      'ستترك هذا اللغز غير مكتمل.',
      'Dejarás este puzzle sin terminar.',
    ],
    'skipYes': [
      'Skip',
      'چھوڑیں',
      'تخطي',
      'Omitir',
    ],
    'puzzleSkipped': [
      'Puzzle skipped',
      'پہیلی چھوڑ دی گئی',
      'تم تخطي اللغز',
      'Puzzle omitido',
    ],
    'difficulty': [
      'Difficulty',
      'مشکل کی سطح',
      'الصعوبة',
      'Dificultad',
    ],
    'buy': [
      'Buy',
      'خریدیں',
      'شراء',
      'Comprar',
    ],
    'buyFor': [
      'Buy one for',
      'کے لیے ایک خریدیں',
      'اشترِ واحدًا مقابل',
      'Comprar uno por',
    ],
    'easy': [
      'Easy',
      'آسان',
      'سهل',
      'Fácil',
    ],
    'normal': [
      'Normal',
      'معمول',
      'عادي',
      'Normal',
    ],
    'hard': [
      'Hard',
      'مشکل',
      'صعب',
      'Difícil',
    ],
    'music': [
      'Music',
      'موسیقی',
      'الموسيقى',
      'Música'
    ],
    'soundEffects': [
      'Sound effects',
      'صوتی اثرات',
      'المؤثرات الصوتية',
      'Efectos de sonido'
    ],
    'difficultyEasy': [
      'Easy', 'آسان', 'سهل', 'Fácil'
    ],
    'difficultyNormal': [
      'Normal', 'معمول', 'عادي', 'Normal'
    ],
    'difficultyHard': [
      'Hard', 'مشکل', 'صعب', 'Difícil'
    ],
    'hardModeHint': [
      'Revealed hints must be used in every guess',
      'ظاہر شدہ اشارے ہر اندازے میں استعمال کریں',
      'يجب استخدام التلميحات المكشوفة في كل محاولة',
      'Debes usar las pistas reveladas en cada intento'
    ],
    'pickDate': [
      'Pick a date', 'تاریخ منتخب کریں', 'اختر تاريخًا', 'Elige una fecha'
    ],
    'archiveHint': [
      'Replay any past daily puzzle. Replays never change today\'s game or streak.',
      'کسی بھی پرانی روزانہ پہیلی کو دوبارہ کھیلیں۔ دوبارہ کھیلنے سے آج کا کھیل یا سلسلہ متاثر نہیں ہوتا۔',
      'أعد لعب أي لغز يومي سابق. الإعادات لا تغيّر لعبة اليوم أو السلسلة.',
      'Repite cualquier reto diario anterior. Las repeticiones no cambian tu juego ni tu racha de hoy.'
    ],
    'streakCalendar': [
      'Streak Calendar', 'سلسلہ کیلنڈر', 'تقويم السلسلة', 'Calendario de racha'
    ],
    'dayWin': [
      'Win', 'جیت', 'فوز', 'Victoria'
    ],
    'dayLoss': [
      'Loss', 'ہار', 'خسارة', 'Derrota'
    ],
    'dayNotPlayed': [
      'Not played', 'نہیں کھیلا', 'لم يُلعب', 'Sin jugar'
    ],
    'wfTitle': [
      'Word Fever',
      'ورڈ فیور',
      'حمى الكلمات',
      'Fiebre de palabras',
    ],
    'wfSubtitle': [
      '60-second word sprint',
      '60 سیکنڈ کا لفظی مقابلہ',
      'سباق الكلمات لمدة 60 ثانية',
      'Sprint de palabras de 60 segundos',
    ],
    'wfScore': [
      'SCORE',
      'اسکور',
      'النقاط',
      'PUNTOS',
    ],
    'wfBest': [
      'BEST',
      'بہترین',
      'الأفضل',
      'RÉCORD',
    ],
    'wfSkip': [
      'Skip',
      'چھوڑیں',
      'تخطَّ',
      'Saltar',
    ],
    'wfNoSkips': [
      'No skips left',
      'کوئی اسکپ باقی نہیں',
      'لا توجد تخطيات متبقية',
      'No quedan saltos',
    ],
    'wfBuySkip': [
      'Buy a skip for {n} coins?',
      'کیا {n} سکوں میں ایک اسکپ خریدیں؟',
      'شراء تخطٍّ مقابل {n} عملة؟',
      '¿Comprar un salto por {n} monedas?',
    ],
    'wfBuy': [
      'BUY',
      'خریدیں',
      'شراء',
      'COMPRAR',
    ],
    'wfNotEnoughCoins': [
      'Not enough coins',
      'سکے ناکافی ہیں',
      'لا توجد عملات كافية',
      'Monedas insuficientes',
    ],
    'wfTimeUp': [
      "Time's up!",
      'وقت ختم!',
      'انتهى الوقت!',
      '¡Tiempo agotado!',
    ],
    'wfWordsSolved': [
      'words solved',
      'الفاظ حل ہوئے',
      'كلمات تم حلها',
      'palabras resueltas',
    ],
    'wfNewBest': [
      'NEW BEST!',
      'نیا ریکارڈ!',
      'رقم قياسي جديد!',
      '¡NUEVO RÉCORD!',
    ],
    'wfPlayAgain': [
      'Play again',
      'دوبارہ کھیلیں',
      'العب مجددًا',
      'Jugar de nuevo',
    ],
    'wfGoHome': [
      'Home',
      'ہوم',
      'الرئيسية',
      'Inicio',
    ],
    'wfSolved': [
      'Solved! +5 coins',
      'حل ہو گیا! +5 سکے',
      'أُحِلَّت! +5 عملات',
      '¡Resuelto! +5 monedas',
    ],
    'wfOutOfGuesses': [
      'The word was {w}',
      'لفظ تھا: {w}',
      'كانت الكلمة: {w}',
      'La palabra era: {w}',
    ],
    'wfTapToStart': [
      'Solve as many 5-letter words as you can!',
      'جتنے ہو سکیں، اتنے 5 حرفی الفاظ حل کریں!',
      'احْلُلْ أكبر عدد ممكن من الكلمات ذات الخمسة أحرف!',
      '¡Resuelve tantas palabras de 5 letras como puedas!',
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

  /// "Word Daily #123 4/6" / per-language branding.
  String puzzleTag(int number) => switch (lang) {
        AppLang.en => 'Word Daily #$number',
        AppLang.ur => 'لفظ ڈیلی #$number',
        AppLang.ar => 'لفظ يومي #$number',
        AppLang.es => 'Word Diario #$number',
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
