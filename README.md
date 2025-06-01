# 🏠 Ev Yönetim Uygulaması

Bu uygulama, çiftlerin ve ailelerin ortak giderlerini, gelirlerini ve harcamalarını takip etmesi için geliştirilmiş bir Flutter mobil uygulamasıdır.

## 📋 Proje Hakkında

Ev Yönetim Uygulaması, ailelerin finansal durumlarını yönetmelerine yardımcı olmak için tasarlanmıştır. Uygulama, aile üyelerinin harcamalarını kaydetmelerine, bütçe analizi yapmalarına ve sabit giderleri takip etmelerine olanak tanır.

## ✨ Özellikler

- **👤 Kullanıcı Yönetimi**
  - 🔐 Kayıt ve giriş işlemleri
  - 👤 Profil yönetimi
  - 🔑 Rol tabanlı yetkilendirme (Aile Yöneticisi ve Aile Üyesi)

- **👨‍👩‍👧‍👦 Aile Yönetimi**
  - ➕ Aile oluşturma
  - ✉️ Aileye üye davet etme
  - 🔍 Aile detaylarını görüntüleme ve düzenleme
  - 📝 Sabit giderleri yönetme

- **💰 Harcama Takibi**
  - ➕ Harcama ekleme, düzenleme ve silme
  - 🏷️ Kategori bazlı harcama sınıflandırma
  - 📋 Harcama listesi ve detayları görüntüleme
  - 📅 Tarih bazlı filtreleme

- **📊 Bütçe Analizi**
  - 📈 Aylık gelir ve gider özeti
  - 📊 Kategori bazlı harcama grafikleri
  - 🔍 Bütçe performansı analizi
  - 💡 Tasarruf önerileri

## 🛠️ Teknoloji Yığını

- **💻 Dil ve Framework**: Dart ve Flutter
- **🔄 Durum Yönetimi**: Riverpod
- **🧭 Navigasyon**: Go Router
- **💉 Bağımlılık Enjeksiyonu**: GetIt ve Injectable
- **💾 Yerel Depolama**: Shared Preferences ve Flutter Secure Storage
- **🌐 Ağ İstekleri**: Dio
- **📊 Grafikler**: FL Chart
- **✨ Animasyonlar**: Lottie
- **🌍 Uluslararasılaştırma**: Intl

## 📁 Proje Yapısı

Proje, temiz mimari prensiplerini takip eden bir yapıya sahiptir:

```
lib/
├── core/                  # Çekirdek bileşenler
│   ├── constants/         # Uygulama sabitleri
│   ├── di/                # Bağımlılık enjeksiyonu
│   ├── error/             # Hata yönetimi
│   ├── network/           # Ağ işlemleri
│   ├── routes/            # Uygulama rotaları
│   ├── storage/           # Yerel depolama
│   ├── theme/             # Tema yapılandırması
│   ├── usecases/          # Temel kullanım durumları
│   ├── utils/             # Yardımcı fonksiyonlar
│   └── widgets/           # Ortak widget'lar
├── features/              # Uygulama özellikleri
│   ├── auth/              # Kimlik doğrulama
│   ├── budget/            # Bütçe yönetimi
│   ├── core/              # Çekirdek özellikler
│   ├── expense/           # Harcama yönetimi
│   └── family/            # Aile yönetimi
└── presentation/          # Genel sunum katmanı
    └── screens/           # Ana ekranlar
```

Her özellik modülü, temiz mimari prensiplerine uygun olarak üç katmana ayrılmıştır:

- **📊 data**: Veri kaynakları, modeller ve repository implementasyonları
- **🧠 domain**: Varlıklar, repository arayüzleri ve kullanım durumları
- **🖼️ presentation**: Ekranlar, widget'lar ve durum yönetimi

## 🚀 Kurulum

1. Flutter SDK'yı yükleyin (https://flutter.dev/docs/get-started/install)
2. Projeyi klonlayın:
   ```
   git clone https://github.com/kullanici-adi/home-management.git
   ```
3. Bağımlılıkları yükleyin:
   ```
   flutter pub get
   ```
4. Uygulamayı çalıştırın:
   ```
   flutter run
   ```

## 👨‍💻 Geliştirme

### 🔄 Kod Üretimi

Proje, kod üretimi için çeşitli araçlar kullanmaktadır:

```
flutter pub run build_runner build --delete-conflicting-outputs
```

### 🏗️ Mimari Prensipler

- **🧩 Temiz Mimari**: Uygulama, bağımlılık kuralına uygun olarak katmanlara ayrılmıştır.
- **🔧 SOLID Prensipleri**: Kod, SOLID prensiplerine uygun olarak yazılmıştır.
- **💉 Bağımlılık Enjeksiyonu**: GetIt ve Injectable kullanılarak bağımlılıklar yönetilmektedir.
- **📚 Repository Pattern**: Veri erişimi repository pattern kullanılarak soyutlanmıştır.

## 🤝 Katkıda Bulunma

1. Projeyi fork edin
2. Özellik dalı oluşturun (`git checkout -b feature/amazing-feature`)
3. Değişikliklerinizi commit edin (`git commit -m 'Add some amazing feature'`)
4. Dalınıza push edin (`git push origin feature/amazing-feature`)
5. Pull Request açın

## 📄 Lisans

Bu proje [MIT Lisansı](LICENSE) altında lisanslanmıştır.
