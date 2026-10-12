# Lafz Daily — Admin Panel

A simple web dashboard to manage the app's content **without touching code**:
- **Words tab** — add/remove words per language (English, اردو, العربية, Español)
- **Ads tab** — AdMob ad unit IDs, max interstitials per day, ads on/off
- **Settings tab** — free hints per day, archive days, daily reminder, Pro product

The app reads these values from Firebase on startup. If Firebase is not
configured (or the phone is offline), the app silently keeps its built-in
word lists and default settings — nothing breaks.

## Setup (one time, ~15 minutes, all free)

1. **Create a Firebase project**: go to https://console.firebase.google.com/
   → "Add project" → give it a name (e.g. `lafz-daily`) → continue
   (Google Analytics is optional — you can disable it).

2. **Register the admin web app**: Project Settings (⚙️) → "Your apps" →
   "Add app" → Web `</>` → nickname `admin` → copy the `firebaseConfig`
   values → paste them into `admin/firebase-config.js` (replace PASTE_HERE).

3. **Enable sign-in**: Build → Authentication → Get started →
   Sign-in method → enable **Email/Password**.

4. **Create the database**: Build → Firestore Database → Create database →
   "Start in **production mode**" → choose a region.

5. **Deploy the security rules**: install the Firebase CLI once
   (`npm install -g firebase-tools`), then from the `admin/` folder:
   ```
   firebase login
   firebase use --add        # pick your project
   firebase deploy --only firestore:rules
   ```
   Rules summary (`firestore.rules`): everyone can **read** words/config
   (the app needs this); only users with the `admin` claim can **write**.

6. **Create your admin user**: Authentication → Users → "Add user" →
   enter your email + a password.

7. **Give yourself the admin claim** — run once in a terminal with the
   Firebase Admin SDK (Node):
   ```
   npm install -g firebase-tools   # if not installed yet
   ```
   Then create a file `set-admin.js`:
   ```js
   const admin = require('firebase-admin');
   const sa = require('./service-account.json'); // from Project Settings > Service accounts > Generate new private key
   admin.initializeApp({ credential: admin.credential.cert(sa) });
   admin.auth().setCustomUserClaims('YOUR_EMAIL_HERE', { admin: true })
     .then(() => { console.log('done'); process.exit(0); });
   ```
   ```
   npm install firebase-admin
   node set-admin.js
   ```
   Log out and back in to the admin panel afterwards.

8. **Open the panel**: the easiest reliable way is Firebase Hosting
   (Firestore blocks `file://` pages in some browsers):
   ```
   cd admin
   firebase init hosting   # public dir: . (this folder)
   firebase deploy --only hosting
   ```
   You'll get a URL like `https://lafz-daily.web.app`. Or host the folder
   on any static host (Netlify, Vercel, GitHub Pages).

## Data model

| Path | Contents |
|---|---|
| `words/{lang}/answers/{word}` | empty doc; doc id = the word (normalized, 5 letters). `lang` ∈ `en, ur, ar, es` |
| `words/{lang}/guesses/{word}` | same; every answer is automatically also added here |
| `config/ads` | `bannerId`, `interstitialId`, `rewardedId` (AdMob unit IDs), `maxInterstitialsPerDay` (0–10), `adsEnabled` (bool) |
| `config/settings` | `freeHintsPerDay` (0–10), `archiveDays` (1–365), `reminderEnabled` (bool), `reminderHour` (0–23), `reminderMinute` (0–59), `proProductId`, `proPriceLabel` |

## Validation rules (enforced in the panel)

- English/Spanish: exactly 5 chars, `a–z` lowercase only (no accents, no ñ).
- Urdu: exactly 5 letters after normalization (ي→ی, ك→ک, ہ→ہ; diacritics stripped).
- Arabic: exactly 5 letters after normalization (أإآ→ا, ة→ه, ى→ي, ؤ→و, ئ→ي; diacritics stripped).
- These mirror `lib/game/urdu_text.dart` and `lib/game/arabic_text.dart`,
  so the panel and the app always agree on word length.

## Connect the app (for the developer)

1. In the same Firebase project: Project Settings → "Your apps" → Add app → **Android** → package `com.lafz.dailypuzzle` → download `google-services.json` → place it in `word-puzzle-app/android/app/`.
2. The app's `remote_content_service.dart` picks up `config/ads`,
   `config/settings`, and the word lists automatically on next launch.
