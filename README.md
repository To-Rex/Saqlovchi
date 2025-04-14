---

# Saqlovchi - Omborxona Boshqaruv Tizimi

![Saqlovchi Logo](https://via.placeholder.com/150) <!-- Agar logotip bo‘lsa, URL ni almashtiring -->

**Saqlovchi** - bu omborxona jarayonlarini samarali boshqarish uchun mo‘ljallangan Flutter asosidagi mobil va veb-ilova. Mahsulotlarning kirim-chiqimi, sotuvlar (naqd, qarzga, chegirma bilan, qimmatroq narx bilan), tranzaksiyalar va foydalanuvchi rollarini boshqarish imkonini beradi. Supabase bilan integratsiyalashgan bo‘lib, real vaqtda ma'lumotlarni sinxronlashtirish va xavfsiz autentifikatsiyani ta'minlaydi.

---

## Xususiyatlar

- **Mahsulot boshqaruvi**:
    - Kategoriyalar va o‘lchov birliklari (kg, metr, litr, dona) asosida mahsulotlar qo‘shish.
    - Partiyalarni (batches) boshqarish: tannarx, sotish narxi, miqdor va partiya raqami.
- **Sotuvlar**:
    - Naqd, qarzga, chegirma bilan yoki qarz va chegirma birgalikda sotish.
    - Qimmatroq narx bilan sotish (standart narxdan yuqori narx belgilash).
    - Mijoz ma'lumotlari bilan qarzli sotuvlar.
- **Tranzaksiyalar**:
    - Kirim, chiqim va qarz to‘lovlarini qayd etish.
    - Qarzlar, foyda, chiqimlar va qimmatroq sotuvlar bo‘yicha hisobotlar.
- **Foydalanuvchi rollari**:
    - **Admin**: To‘liq boshqaruv huquqlari.
    - **Manager**: Mahsulotlar, sotuvlar va tranzaksiyalarni qisman boshqarish.
    - **Sotuvchi**: Faqat sotuv qilish va ombor ma'lumotlarini ko‘rish.
- **Realtime**: Ombor miqdori o‘zgarishlarini real vaqtda kuzatish.
- **Xavfsizlik**: Supabase RLS (Row-Level Security) bilan ma'lumotlarni himoya qilish.

---

## Texnologiyalar

- **Frontend**: Flutter (`supabase_flutter` kutubxonasi)
- **Backend**: Supabase (PostgreSQL)
- **Autentifikatsiya**: Supabase Email Auth
- **Ma'lumotlar ombori**: PostgreSQL
- **API**: REST va Realtime (Supabase SDK)

---

## O‘rnatish

### 1. Talablar
- Flutter SDK (2.0 yoki undan yuqori)
- Dart
- Supabase loyihasi (URL va Anon Key bilan)
- Git

### 2. Loyihani klonlash
```bash
git clone https://github.com/your-username/saqlovchi.git
cd saqlovchi
```

### 3. Bog‘liqliklarni o‘rnatish
```bash
flutter pub get
```

### 4. Supabase sozlamalari
`lib/config/supabase.dart` faylida Supabase URL va Anon Key’ni sozlang:
```dart
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> initSupabase() async {
  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL',
    anonKey: 'YOUR_SUPABASE_ANON_KEY',
  );
}
```

### 5. Ma'lumotlar omborini sozlash
Supabase loyihangizda quyidagi SQL skriptlarini ishlatib jadvallarni yarating:
```sql
-- users jadvali
CREATE TABLE users (
    id UUID PRIMARY KEY,
    email TEXT NOT NULL,
    full_name TEXT,
    role TEXT CHECK (role IN ('admin', 'manager', 'seller')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    is_blocked BOOLEAN DEFAULT FALSE
);

-- Boshqa jadvallar uchun docs/database.sql ni ko‘ring
```
To‘liq SQL skriptlari uchun [docs/database.sql](docs/database.sql) fayliga qarang.

### 6. Ilovani ishga tushirish
```bash
flutter run
```

---

## Foydalanish

1. **Foydalanuvchi yaratish**:
    - Supabase Auth orqali ro‘yxatdan o‘ting (email va parol bilan).
    - Rolni tanlang: `admin`, `manager` yoki `seller`.

2. **Mahsulot qo‘shish**:
    - Kategoriya va birlikni tanlang.
    - Partiya ma'lumotlarini kiriting (miqdor, tannarx, sotish narxi).

3. **Sotuv qilish**:
    - Sotuv turi: naqd, qarzga, chegirma bilan yoki qimmatroq narx bilan.
    - Qarzga sotish uchun mijozni tanlang.
    - Narxni moslashtirish uchun `unit_price` ni o‘zgartiring.

4. **Hisobotlar**:
    - Qarzlar, qimmatroq sotuvlar va foyda bo‘yicha hisobotlarni ko‘ring.

---

## API Service

Loyihada `ApiService` sinfi `supabase_flutter` orqali barcha ma'lumotlar bilan ishlashni ta'minlaydi:
- **GET metodlari**: `List<dynamic>` ko‘rinishida ma'lumotlarni qaytaradi (`getProducts`, `getSales` va boshqalar).
- **POST/PUT/DELETE**: Ma'lumotlarni qo‘shish, yangilash va o‘chirish (`addSale`, `updateProduct`, `deleteBatch`).
- Qimmatroq sotish: `addSaleItem` da `unit_price` ni moslashtirish orqali.

Misol:
```dart
final apiService = ApiService();

// Qimmatroq narx bilan sotuv
await apiService.addSaleItem(
  saleId: 1,
  batchId: 1,
  quantity: 1,
  unitPrice: 800000, // Standart narxdan yuqori
);
```

To‘liq API hujjatlari uchun [docs/api.md](docs/api.md) ni ko‘ring.

---

## Ma'lumotlar Ombori Tuzilmasi

| Jadval          | Tavsif                              |
|-----------------|-------------------------------------|
| `users`         | Foydalanuvchilar (Supabase Auth)    |
| `units`         | O‘lchov birliklari (kg, dona, va hokazo) |
| `categories`    | Mahsulot kategoriyalari             |
| `products`      | Mahsulotlar                         |
| `batches`       | Partiyalar (miqdor, narxlar)        |
| `customers`     | Mijozlar                            |
| `sales`         | Sotuvlar (naqd, qarz, chegirma)     |
| `sale_items`    | Sotuv elementlari (narx, miqdor)    |
| `transactions`  | Tranzaksiyalar (kirim, chiqim)      |

To‘liq sxema uchun [docs/database.sql](docs/database.sql) ga qarang.

---

## Xatolarni Bartaraf Qilish

- **Takroriy partiya raqami**:
  ```dart
  bool isUnique = await _supabase
      .from('batches')
      .select('id')
      .eq('product_id', productId)
      .eq('batch_number', batchNumber)
      .isEmpty;
  ```
- **Chegirma xatosi**:
    - Serverda: `CHECK (discount_amount <= total_amount)`.
    - Frontend: `if (discountAmount > totalAmount) throw 'Chegirma xatosi!';`
- **Qimmatroq sotish xatosi**:
    - `unit_price` manfiy bo‘lmasligi uchun: `CHECK (unit_price >= 0)`.

---

## Hisobotlar

- **Qarzlar**: `ApiService.getDebtWithDiscountReport()`
- **Qimmatroq sotuvlar**:
  ```dart
  final premiumSales = await apiService.getPremiumSales();
  ```
- **Foyda**: Naqd va qarzli sotuvlar bo‘yicha umumiy hisobot.

---

## Litsenziya

Ushbu loyiha [MIT License](LICENSE) ostida tarqatiladi.

---

## Hissa qo‘shish

1. Loyihani fork qiling.
2. Yangi branch yarating: `git checkout -b feature/your-feature`.
3. O‘zgarishlarni kiriting va commit qiling: `git commit -m "Yangi funksiya"`.
4. Push qiling: `git push origin feature/your-feature`.
5. Pull Request oching.

---

## Aloqa

- **Email**: your-email@example.com
- **GitHub**: [To-Rex](https://github.com/To-Rex)
- **Supabase loyihasi**: [Supabase Docs](https://supabase.com/docs)

---

## Kelajakdagi rejalarni ko‘rib chiqish

- **UI yaxshilash**: Foydalanuvchi interfeysini yanada qulaylashtirish.
- **Hisobotlar**: Eng ko‘p sotilgan mahsulotlar va ombor holati bo‘yicha grafiklar.
- **Mobil funksiyalar**: Offline rejim va push bildirishnomalar.

---

**Saqlovchi** bilan omborxona jarayonlaringizni soddalashtiring va samaradorlikni oshiring! 🚀

---

### Qo‘shimcha eslatmalar
- **Logotip**: Agar loyihangizda logotip bo‘lsa, `![Saqlovchi Logo]`
- **Docs fayllari**: Yuqorida ko‘rsatilgan `docs/database.sql` va `docs/api.md`
- **Foydalanuvchi ma'lumotlari**: `your-username` va `torex.amaki@gmail.com`
