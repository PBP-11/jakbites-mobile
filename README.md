# JakBites Mobile by F11 - PBP 2024/2025

### 🍽️ Discover the best restaurants and food in Jakarta! 🌆

### [🚀 App Deployment Link (TBA)](link_here)

## Our Team 👥

- Christian Yudistira Hermawan (2306241676)
- Muhammad Fadhlan Karimuddin (2306245011)
- Alpha Sutha Media (2306275935)
- Shintia Dharma Shanty (2306245655)
- William Matthew Saputra (2306165862)

## What is JakBites❓

**JakBites** adalah platform inovatif yang dirancang untuk membantu Anda menemukan pengalaman kuliner terbaik di Jakarta! Dengan tampilan yang user-friendly dan fitur yang lengkap, JakBites mempermudah Anda dalam menjelajahi berbagai restoran dan makanan yang ada di ibu kota. 🎉

Jakarta, sebagai kota metropolitan, menawarkan beragam pilihan kuliner dari berbagai penjuru dunia. JakBites hadir untuk menjadi panduan kuliner pribadi Anda, menampilkan berbagai restoran dan produk makanan lengkap dengan informasi detail, rating, dan ulasan dari pengguna lainnya. Dengan JakBites, Anda dapat dengan mudah mencari restoran favorit atau menemukan tempat makan baru berdasarkan preferensi Anda seperti jenis makanan, harga, dan lokasi.

Beberapa fitur utama yang ditawarkan oleh JakBites meliputi:
- **Pencarian dan Penyortiran:** Cari restoran dan makanan favorit Anda dengan mudah menggunakan filter berdasarkan kategori, harga, dan lokasi.
- **Rating dan Ulasan:** Dapatkan rekomendasi terbaik dari komunitas JakBites melalui rating dan ulasan yang diberikan oleh pengguna lainnya.
- **Favorit:** Simpan restoran dan makanan favorit Anda untuk akses cepat di kemudian hari.
- **Antarmuka yang Intuitif:** Nikmati pengalaman menjelajah kuliner dengan antarmuka yang sederhana dan responsif, dirancang untuk memudahkan navigasi Anda.

Dengan JakBites, menemukan tempat makan yang sempurna di Jakarta menjadi lebih praktis dan menyenangkan! 🌟

## Modules 📦

1. **Authentication and Admin/Super User (Autentikasi dan Admin/Super User): Fadhlan**
   - **🔐 Login Page:** Halaman untuk masuk ke akun pengguna.
   - **📝 Register Page:** Halaman pendaftaran untuk pengguna baru.
   - **🛠️ Admin Pages:** Halaman yang memungkinkan admin untuk menambah Restoran dan Makanan
   - **🍔 Add Food and Resto:** Admin dapat menambah data makanan dan restoran baru.

2. **Main: Christian**
   - **🏠 Homepage (Static HTML Page):** Halaman statis yang menampilkan informasi dasar tentang JakBites.
   - **📋 Main Page (Daftar Produk):** Halaman yang menampilkan daftar makanan dan restoran, lengkap dengan fitur penyortiran dan filter untuk memudahkan pencarian.

3. **Food (Makanan): Shintia**
   - **🍽️ Product Page:** Halaman yang menampilkan detail produk makanan, termasuk rating dan ulasan dari pengguna.
   - **⭐ Rating and Review:** Pengguna dapat memberikan rating serta menulis ulasan untuk produk makanan.

4. **Restaurant (Restoran): Alpha**
   - **🏢 Restaurant Page:** Halaman yang menampilkan detail restoran, termasuk daftar makanan yang disediakan.
   - **🍛 Resto Food List:** Daftar makanan yang tersedia di restoran tertentu.
   - **🌟 Resto Rating:** Pengguna dapat memberikan rating dan ulasan untuk restoran.

5. **User (Pengguna): William**
   - **👤 User Page:** Halaman yang menampilkan profil pengguna, di mana mereka dapat memperbarui informasi dan mengelola akun, termasuk mengubah kata sandi.
   - **❤️ Favorite Page:** Pengguna dapat melihat dan mengelola daftar restoran dan makanan favorit mereka.

## Initial Dataset 📊

- [Kaggle - Indonesia Food Delivery GoFood Product List](https://www.kaggle.com/datasets/ariqsyahalam/indonesia-food-delivery-gofood-product-list)

## Roles 🔏

1. **Pengguna Biasa (User):** 
   Pengguna umum yang menggunakan JakBites untuk menemukan restoran dan makanan di Jakarta. Mereka dapat mencari restoran dan produk makanan, menambah tempat favorit, serta memberikan ulasan dan rating terhadap restoran atau produk makanan.

2. **Administrator (Admin / Super User):** 
   Admin memiliki hak penuh untuk mengelola konten di JakBites. Mereka dapat menambahkan restoran dan makanan baru.

## Integration With JakBites Web App ⚙️

Untuk mengintegrasikan aplikasi mobile JakBites dengan web service yang telah dibangun pada Proyek Tengah Semester, kami mengikuti beberapa langkah utama:

1. **Membuat Model di Flutter**:
   - Mendefinisikan kelas model yang sesuai dengan respons dari web service Django menggunakan metode `fromJson` dan `toJson`.
   - Mengimpor library `dart:convert` untuk membantu dalam proses konversi data JSON.

2. **Mengambil Data dari Web Service**:
   - Menggunakan package `http` untuk melakukan request ke web service.
   - Melakukan parsing data JSON yang diterima menjadi objek model di Flutter.

3. **State Management dengan Provider**:
   - Mengimplementasikan `Provider` untuk mengelola state secara global.
   - Memungkinkan akses ke instance `CookieRequest` di seluruh widget dalam aplikasi.

4. **Autentikasi**:
   - Mengintegrasikan fitur login dan registrasi dengan endpoint autentikasi pada web service Django.
   - Menggunakan package `pbp_django_auth` untuk mempermudah proses autentikasi dan pengelolaan cookie.

5. **Testing dan Debugging**:
   - Menguji koneksi antara aplikasi Flutter dan web service untuk memastikan data dapat diambil dan dikirim dengan benar.
   - Melakukan debugging terhadap isu yang muncul selama proses integrasi.

6. **Deploy Aplikasi**:
   - Melakukan deploy aplikasi Flutter dan memastikan bahwa aplikasi terhubung dengan web service yang telah di-deploy sebelumnya.
   - Memastikan fungsi-fungsi utama berjalan dengan baik setelah proses deploy.

Dengan mengikuti langkah-langkah di atas, aplikasi mobile JakBites berhasil terhubung dengan web service, memungkinkan sinkronisasi data antara aplikasi web dan mobile serta memberikan pengalaman pengguna yang konsisten.
