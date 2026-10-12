# Lafz Daily — Setup Guide (Roman Urdu mein)

Assalam-o-Alaikum! Ye package aapke **Lafz Daily** word puzzle game ka complete
source code hai. Is mein sab kuch hai: game ka code (4 languages: English,
Urdu, Arabic, Spanish), admin panel (web dashboard), aur testing ke liye
ready-made APK.

## 1. Package mein kya kya hai

| Cheez | Kahan hai | Kaam |
|---|---|---|
| Game ka source code | `lib/` folder | Poori app (Flutter) |
| Debug APK (test version) | `lafz-daily-debug.apk` | Apne phone par install karke test karein |
| Admin panel | `admin/` folder | Words aur ads manage karne ka web dashboard |
| Ye guide | `README-URDU.md` | — |

## 2. APK apne phone par install karke test karein

1. `lafz-daily-debug.apk` file apne phone mein bhejein (WhatsApp ya USB se).
2. Phone par file par tap karein → install ki ijazat dein.
   ("Unknown sources / namaloom zariye se install" ki permission maangega —
   ye normal hai, allow kar dein. Ye sirf test version hai.)
3. App kholein, 4 languages try karein, daily puzzle khelein.

**Note:** Ye DEBUG version hai — is mein Google ke **test ads** lagte hain
(asli earning wale ads nahi). Asli ads ke liye neeche step 4 dekhein.

## 3. Firebase project banana (FREE) — admin panel ke liye

Admin panel se aap baghair code chhue naye words add kar sakte hain aur ads
control kar sakte hain. Is ke liye free Firebase account chahiye:

1. https://console.firebase.google.com/ kholein, Google account se login karein.
2. **Add project** → naam likhein (misal: `lafz-daily`) → continue karein.
3. Project Settings (⚙️) → **Your apps** → Web `</>` → config copy karke
   `admin/firebase-config.js` mein paste karein (PASTE_HERE ki jagah).
4. **Authentication** → Get started → Sign-in method → **Email/Password** enable karein.
5. **Firestore Database** → Create database → production mode.
6. `admin/` folder se rules deploy karein (tafseel `admin/README.md` mein hai).
7. Authentication → Users → **Add user** se apna admin account banayein,
   phir usay admin claim dein (tariqa `admin/README.md` mein hai).
8. Admin panel kholne ke liye: `admin/` folder ko Firebase Hosting
   (ya Netlify/Vercel) par deploy karein — aapko ek link milega.

**Mushkil lage to:** mujhe batayein, main step-by-step WhatsApp par guide
kar doonga.

## 4. AdMob account — asli earning ke liye

1. https://apps.admob.com/ par account banayein.
2. Apni app register karein → **App ID** milega.
3. 3 **Ad Unit IDs** banayein: Banner, Interstitial, Rewarded.
4. Ye IDs admin panel ke **Ads tab** mein paste kar dein — app aglay restart
   par asli ads dikhana shuru kar degi. Code mein kuch change nahi karna!

## 5. Play Store par publish karna

1. https://play.google.com/console par **$25** (one-time fee) dekar
   developer account banayein — apne naam/ID par.
2. **Closed testing**: kam az kam **12 testers** 14 din tak app test karein
   (backup ke liye 18–20 testers ready rakhein).
3. Us ke baad production release — app Play Store par live!

## 6. Release build (final APK/AAB)

Debug APK sirf testing ke liye hai. Play Store par upload ke liye **release
build** chahiye hoti hai (signed AAB file). Jab aap tayyar hon, mujhe bata
dein — main release build bana kar de doonga.

---
**Yaad rakhein:** `google-services.json` file (Firebase ki) abhi package mein
nahi hai — wo aap tab add karein ge jab Firebase project bana lein ge
(tariqa `admin/README.md` mein hai).
