# 📚 Kitobxon — Flutter kitob do'koni (v2)

Firebase (Authentication + Realtime Database) asosidagi zamonaviy kitob do'koni va shaxsiy kutubxona. Ilova to'liq qayta yozilgan: toza arxitektura, xatolarga chidamli tarmoq qatlami, 3 tilli interfeys, yorug'/qorong'i mavzu va bir qator kreativ funksiyalar.

## ✨ Imkoniyatlar

**Asosiy**
- Ro'yxatdan o'tish, kirish, parolni tiklash (email orqali)
- Avtomatik sessiya yangilash (refresh token) — har soatda qayta kirish shart emas
- Katalog: ommabop, yangi, chegirmadagi kitoblar
- Qidiruv + filtrlar (janr, til, narx oralig'i, chegirma) + saralash, to'r/ro'yxat ko'rinishi
- Kitob sahifasi: Hero animatsiya, kitob rangidagi dinamik fon, ma'lumot paneli, o'xshash kitoblar
- Savatcha: miqdor, suring-o'chirish (bekor qilish bilan), promo-kodlar, qurilmada saqlanadi
- "Suring va buyurtma bering" tugmasi, konfetti bilan tasdiqlash
- Buyurtmalar tarixi va holat vaqt chizig'i (Qabul qilindi → Tayyorlanmoqda → Yo'lda → Yetkazildi)

**Kreativ**
- ☀️ **Kunning kitobi** — har kuni yangi tavsiya
- 🌙 **Kayfiyat bo'yicha tanlov** — "Iliq", "Sarguzasht", "Sirli"... kayfiyatni tanlang, ilova mos kitoblarni topadi
- 🎯 **Yillik o'qish maqsadi** — animatsion halqa, 🔥 kunlik o'qish seriyasi
- 📖 **Shaxsiy javonlar** — "O'qimoqchiman / O'qiyapman / O'qib bo'ldim", sahifalar bo'yicha jarayon
- ⭐ **Sharhlar va reytinglar**
- 💡 **Siz uchun tanladik** — sevimli kitoblaringiz janriga qarab tavsiyalar
- 🕓 Yaqinda ko'rilganlar, o'qish vaqti taxmini

**Sozlamalar va profil**
- Ism va avatar rangini tahrirlash, statistika (buyurtmalar, sevimlilar, o'qilganlar)
- Mavzu: tizim / yorug' / qorong'i
- Til: o'zbek, rus, ingliz

**Admin panel** (faqat adminlar)
- Kitob qo'shish / tahrirlash / o'chirish — muqovaning jonli ko'rinishi bilan
- Barcha foydalanuvchilar buyurtmalari, holatini o'zgartirish

## 🗂 Tuzilma

```
lib/
├── main.dart              # ishga tushirish, servislarni yig'ish
├── app.dart               # Provider'lar, MaterialApp, boshlang'ich ekran tanlovi
├── core/
│   ├── config/env.dart    # Firebase sozlamalari (--dart-define bilan almashtiriladi)
│   ├── l10n/              # uz / ru / en tarjimalar
│   ├── network/           # ApiClient (timeout, xatolar) + AppException
│   ├── theme/             # dizayn tizimi (yorug' va qorong'i)
│   ├── utils/             # formatlash, validatsiya
│   ├── widgets/           # qayta ishlatiladigan vidjetlar
│   └── router.dart        # nomlangan marshrutlar
├── data/
│   ├── models/            # Book, CartItem, Order, Review, ShelfEntry, UserProfile
│   ├── repositories/      # Firebase REST bilan ishlash
│   └── local/             # SharedPreferences
├── state/                 # ChangeNotifier provider'lar
└── features/              # ekranlar (auth, home, explore, details, cart, orders, library, profile, admin)
```

## 🚀 Ishga tushirish

```bash
flutter pub get
flutter run
```

Testlar va tahlil:

```bash
flutter analyze
flutter test
```

Boshqa Firebase loyihasidan foydalanish uchun:

```bash
flutter run --dart-define=FIREBASE_API_KEY=xxx --dart-define=FIREBASE_DB_URL=https://<loyiha>-default-rtdb.firebaseio.com
```

## 🔐 Firebase sozlash (bir martalik)

1. **Xavfsizlik qoidalari.** Firebase Console → Realtime Database → *Rules* bo'limiga `firebase/database.rules.json` faylidagi qoidalarni qo'ying va *Publish* bosing.
2. **O'zingizni admin qiling.** Ilovada ro'yxatdan o'ting, so'ng Console → Authentication bo'limidan o'z **User UID** ingizni nusxalang. Realtime Database'da quyidagi yozuvni qo'shing:
   ```
   admins
     └── <sizning UID>: true
   ```
   Ilovani qayta oching — Profil sahifasida **Admin panel** paydo bo'ladi.
3. **Promo-kodlar (ixtiyoriy).** `promoCodes/KOD: foiz` ko'rinishida qo'shing, masalan `promoCodes/YANGIYIL: 20`. Ilovada standart `KITOBXON10` (10%) va `BOOKLOVER` (15%) kodlari ham ishlaydi.

## ♻️ Eski versiyadan o'tish

Ma'lumotlar formati saqlab qolingan (`ganre`, `discout` kabi kalitlar), shuning uchun mavjud kitoblar, sevimlilar va buyurtmalar o'zgarishsiz ishlaydi. Eski buyurtmalarda holat bo'lmasa — "Qabul qilindi" deb ko'rsatiladi.

## 🐞 v1 dagi tuzatilgan asosiy xatolar

- Savatcha savatdagi mahsulot o'rniga ro'yxatdagi tasodifiy kitobni ko'rsatardi
- Avtomatik chiqish taymeri chaqirilmasdi (`autoLogOutFunction` qavssiz)
- Baza bo'sh bo'lsa yoki narx butun son bo'lsa ilova qulardi
- Sevimlilar tasodifiy kalit bilan saqlanib, keyin topilmasdi
- Kitobni tahrirlash `await` qilinmasdi; buyurtma xatosi ilovani yopardi
- Sozlamalar sahifasi bo'sh, profil ismi kodga qattiq yozilgan edi
