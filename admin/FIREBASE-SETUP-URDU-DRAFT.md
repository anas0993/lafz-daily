# Admin Panel Chalane Ke Liye Firebase Setup — Step-by-Step (DRAFT)

> **DRAFT** — research pass ne tayyar kiya hai, handover se pehle main agent verify kare.
> Ye guide `admin/README.md` ke technical steps ka asaan Roman-Urdu version hai.

Aap ka admin panel (jahan se aap words aur ads khud change kar saken ge) **Firebase**
par chalta hai — Google ki free service. Aap ko sirf **aik dafa** ye setup karna hai,
taqreeban 15 minute lagein ge, aur **koi paisa nahi** lagega.

**Pehle se tayyar rakhein:** aap ka Gmail account (wahi jo Play Console ke liye use hoga).

## Step 1 — Firebase project banayein (2 minute)
1. Browser mein kholein: **console.firebase.google.com**
2. **"Add project"** / "Create a project" dabayein.
3. Naam likhein: `lafz-daily` → Continue.
4. Google Analytics ka option aaye to **disable** kar dein (zaroori nahi) → Create.

## Step 2 — Web app register karein (3 minute)
1. Project ke andar **⚙️ Settings → Project settings** kholein.
2. Neeche "Your apps" mein **Web `</>`** ka icon dabayein.
3. Nickname likhein: `admin` → Register.
4. Jo `firebaseConfig` code nazar aaye, us ki values **copy** kar lein.
5. Code package mein `admin/firebase-config.js` file kholein, har `PASTE_HERE` ki
   jagah apni copied value **paste** kar dein, file save karein.

## Step 3 — Login ka tareeqa on karein (1 minute)
1. Left menu: **Build → Authentication → Get started**.
2. **Sign-in method** → **Email/Password** → **Enable** → Save.

## Step 4 — Database banayein (2 minute)
1. Left menu: **Build → Firestore Database → Create database**.
2. **"Start in production mode"** select karein → Next.
3. Region chunein (jo qareeb ho, e.g. `asia-south1`) → Enable.

## Step 5 — Security rules lagayein (3 minute)
Ye aik dafa computer par command chalani hai:
1. Apne computer par **Node.js** install karein (nodejs.org se — free).
2. Terminal/CMD kholein aur likhein: `npm install -g firebase-tools`
3. `admin` folder mein jayein, phir:
   - `firebase login` (browser mein Google account se login hoga)
   - `firebase deploy --only firestore:rules`
4. Success likha aaye to ho gaya — ab sirf aap words/ads change kar saken ge,
   baqi sab sirf parh saken ge.

## Step 6 — Apna admin account banayein (2 minute)
1. Firebase console: **Authentication → Users → Add user**.
2. Apna email + aik mazboot password likhein → Add.

## Step 7 — Khud ko admin banayein (yeh step main aap ke saath karunga)
Is mein aik chhoti si file chalani hoti hai (service account key) — thora technical
hai, is liye **yeh wala step hum call/message par aik saath karein ge**, 5 minute ka
kaam hai. Us ke baad panel mein logout → login karein.

## Step 8 — Panel kholein (2 minute)
Sab se asaan tareeqa — Firebase Hosting:
1. `admin` folder mein terminal kholein: `firebase init hosting`
   (public directory pooche to bas `.` likhein — isi folder ka matlab).
2. `firebase deploy --only hosting`
3. Aap ko aik link milega, jese: `https://lafz-daily.web.app` — **yehi aap ka
   admin panel hai.** Ise bookmark kar lein, phone/laptop dono par khulta hai.

## Phir kya hoga?
- **Words tab** — 4 languages (English, اردو, العربية, Español) mein words add/remove.
- **Ads tab** — AdMob IDs aur roz kitne ads dikhein, sab yahin se.
- **Settings tab** — free hints, reminder waghera.
- App agle launch par ye sab khud utha legi. **Agar panel kabhi band bhi ho jaye to
  app chalti rahegi** — us ke andar apni copy mehfooz hai, kuch nahi tootega.

*Masla ho to screenshot bhej dein — main dekh lunga.*
