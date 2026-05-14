import 'package:sqflite/sqflite.dart';

class SeedData {
  static Future<void> seedMilestones(Database db) async {
    final milestones = [
      // MOTORIK KASAR 0-3 bulan
      {'category': 'motorik', 'subcategory': 'motorik_kasar', 'age_months_min': 0, 'age_months_max': 3, 'description': 'Mengangkat kepala saat tengkurap'},
      {'category': 'motorik', 'subcategory': 'motorik_kasar', 'age_months_min': 0, 'age_months_max': 3, 'description': 'Menggerakkan kepala dari kiri/kanan ke tengah'},
      {'category': 'motorik', 'subcategory': 'motorik_kasar', 'age_months_min': 0, 'age_months_max': 3, 'description': 'Menahan kepala tetap tegak saat digendong'},
      // MOTORIK KASAR 4-6 bulan
      {'category': 'motorik', 'subcategory': 'motorik_kasar', 'age_months_min': 4, 'age_months_max': 6, 'description': 'Tengkurap dan telentang sendiri'},
      {'category': 'motorik', 'subcategory': 'motorik_kasar', 'age_months_min': 4, 'age_months_max': 6, 'description': 'Mengangkat dada dengan bertopang tangan'},
      {'category': 'motorik', 'subcategory': 'motorik_kasar', 'age_months_min': 4, 'age_months_max': 6, 'description': 'Duduk dengan bantuan'},
      // MOTORIK KASAR 7-9 bulan
      {'category': 'motorik', 'subcategory': 'motorik_kasar', 'age_months_min': 7, 'age_months_max': 9, 'description': 'Duduk sendiri tanpa bantuan'},
      {'category': 'motorik', 'subcategory': 'motorik_kasar', 'age_months_min': 7, 'age_months_max': 9, 'description': 'Belajar berdiri dengan pegangan'},
      {'category': 'motorik', 'subcategory': 'motorik_kasar', 'age_months_min': 7, 'age_months_max': 9, 'description': 'Merangkak meraih mainan'},
      // MOTORIK KASAR 10-12 bulan
      {'category': 'motorik', 'subcategory': 'motorik_kasar', 'age_months_min': 10, 'age_months_max': 12, 'description': 'Berdiri tanpa berpegangan'},
      {'category': 'motorik', 'subcategory': 'motorik_kasar', 'age_months_min': 10, 'age_months_max': 12, 'description': 'Berjalan dengan berpegangan'},
      {'category': 'motorik', 'subcategory': 'motorik_kasar', 'age_months_min': 10, 'age_months_max': 12, 'description': 'Berjalan beberapa langkah sendiri'},
      // MOTORIK KASAR 13-18 bulan
      {'category': 'motorik', 'subcategory': 'motorik_kasar', 'age_months_min': 13, 'age_months_max': 18, 'description': 'Berjalan sendiri tanpa terjatuh'},
      {'category': 'motorik', 'subcategory': 'motorik_kasar', 'age_months_min': 13, 'age_months_max': 18, 'description': 'Berlari kecil-kecil'},
      {'category': 'motorik', 'subcategory': 'motorik_kasar', 'age_months_min': 13, 'age_months_max': 18, 'description': 'Naik tangga dengan bantuan'},
      // MOTORIK KASAR 19-24 bulan
      {'category': 'motorik', 'subcategory': 'motorik_kasar', 'age_months_min': 19, 'age_months_max': 24, 'description': 'Naik turun tangga dengan berpegangan'},
      {'category': 'motorik', 'subcategory': 'motorik_kasar', 'age_months_min': 19, 'age_months_max': 24, 'description': 'Menendang bola'},
      {'category': 'motorik', 'subcategory': 'motorik_kasar', 'age_months_min': 19, 'age_months_max': 24, 'description': 'Melompat dengan dua kaki'},
      // MOTORIK HALUS 0-3 bulan
      {'category': 'motorik', 'subcategory': 'motorik_halus', 'age_months_min': 0, 'age_months_max': 3, 'description': 'Menggenggam benda yang disentuhkan ke tangan'},
      {'category': 'motorik', 'subcategory': 'motorik_halus', 'age_months_min': 0, 'age_months_max': 3, 'description': 'Memperhatikan benda bergerak'},
      // MOTORIK HALUS 4-6 bulan
      {'category': 'motorik', 'subcategory': 'motorik_halus', 'age_months_min': 4, 'age_months_max': 6, 'description': 'Meraih dan menggenggam mainan'},
      {'category': 'motorik', 'subcategory': 'motorik_halus', 'age_months_min': 4, 'age_months_max': 6, 'description': 'Memindahkan benda antar tangan'},
      // MOTORIK HALUS 7-12 bulan
      {'category': 'motorik', 'subcategory': 'motorik_halus', 'age_months_min': 7, 'age_months_max': 12, 'description': 'Menjimpit benda kecil (pincer grasp)'},
      {'category': 'motorik', 'subcategory': 'motorik_halus', 'age_months_min': 7, 'age_months_max': 12, 'description': 'Memasukkan benda ke wadah'},
      {'category': 'motorik', 'subcategory': 'motorik_halus', 'age_months_min': 7, 'age_months_max': 12, 'description': 'Menumpuk 2 kubus'},
      // MOTORIK HALUS 13-24 bulan
      {'category': 'motorik', 'subcategory': 'motorik_halus', 'age_months_min': 13, 'age_months_max': 24, 'description': 'Mencoret-coret kertas'},
      {'category': 'motorik', 'subcategory': 'motorik_halus', 'age_months_min': 13, 'age_months_max': 24, 'description': 'Menumpuk 4-6 kubus'},
      {'category': 'motorik', 'subcategory': 'motorik_halus', 'age_months_min': 13, 'age_months_max': 24, 'description': 'Memegang sendok sendiri'},
      // KOGNITIF 0-3 bulan
      {'category': 'kognitif', 'subcategory': 'kognitif', 'age_months_min': 0, 'age_months_max': 3, 'description': 'Memperhatikan wajah orang'},
      {'category': 'kognitif', 'subcategory': 'kognitif', 'age_months_min': 0, 'age_months_max': 3, 'description': 'Mengikuti benda bergerak dengan mata'},
      {'category': 'kognitif', 'subcategory': 'kognitif', 'age_months_min': 0, 'age_months_max': 3, 'description': 'Mengenali wajah dan bau ibu'},
      // KOGNITIF 4-6 bulan
      {'category': 'kognitif', 'subcategory': 'kognitif', 'age_months_min': 4, 'age_months_max': 6, 'description': 'Meraih benda yang diminati'},
      {'category': 'kognitif', 'subcategory': 'kognitif', 'age_months_min': 4, 'age_months_max': 6, 'description': 'Memasukkan benda ke mulut'},
      {'category': 'kognitif', 'subcategory': 'kognitif', 'age_months_min': 4, 'age_months_max': 6, 'description': 'Memperhatikan benda jatuh'},
      // KOGNITIF 7-12 bulan
      {'category': 'kognitif', 'subcategory': 'kognitif', 'age_months_min': 7, 'age_months_max': 12, 'description': 'Mencari benda yang disembunyikan'},
      {'category': 'kognitif', 'subcategory': 'kognitif', 'age_months_min': 7, 'age_months_max': 12, 'description': 'Meniru gerakan sederhana'},
      {'category': 'kognitif', 'subcategory': 'kognitif', 'age_months_min': 7, 'age_months_max': 12, 'description': 'Mengenal fungsi benda sederhana'},
      // KOGNITIF 13-24 bulan
      {'category': 'kognitif', 'subcategory': 'kognitif', 'age_months_min': 13, 'age_months_max': 24, 'description': 'Menunjuk benda yang diinginkan'},
      {'category': 'kognitif', 'subcategory': 'kognitif', 'age_months_min': 13, 'age_months_max': 24, 'description': 'Mengenal warna dan bentuk dasar'},
      {'category': 'kognitif', 'subcategory': 'kognitif', 'age_months_min': 13, 'age_months_max': 24, 'description': 'Bermain pura-pura sederhana'},
      // BAHASA 0-3 bulan
      {'category': 'bahasa', 'subcategory': 'bahasa', 'age_months_min': 0, 'age_months_max': 3, 'description': 'Bereaksi terhadap suara/bunyi'},
      {'category': 'bahasa', 'subcategory': 'bahasa', 'age_months_min': 0, 'age_months_max': 3, 'description': 'Mengeluarkan suara "aah", "ooh"'},
      {'category': 'bahasa', 'subcategory': 'bahasa', 'age_months_min': 0, 'age_months_max': 3, 'description': 'Tersenyum saat diajak bicara'},
      // BAHASA 4-6 bulan
      {'category': 'bahasa', 'subcategory': 'bahasa', 'age_months_min': 4, 'age_months_max': 6, 'description': 'Berceloteh (babbling)'},
      {'category': 'bahasa', 'subcategory': 'bahasa', 'age_months_min': 4, 'age_months_max': 6, 'description': 'Menoleh ke arah suara'},
      {'category': 'bahasa', 'subcategory': 'bahasa', 'age_months_min': 4, 'age_months_max': 6, 'description': 'Tertawa keras'},
      // BAHASA 7-12 bulan
      {'category': 'bahasa', 'subcategory': 'bahasa', 'age_months_min': 7, 'age_months_max': 12, 'description': 'Mengucapkan "mama" atau "papa"'},
      {'category': 'bahasa', 'subcategory': 'bahasa', 'age_months_min': 7, 'age_months_max': 12, 'description': 'Mengerti perintah sederhana'},
      {'category': 'bahasa', 'subcategory': 'bahasa', 'age_months_min': 7, 'age_months_max': 12, 'description': 'Meniru kata sederhana'},
      // BAHASA 13-24 bulan
      {'category': 'bahasa', 'subcategory': 'bahasa', 'age_months_min': 13, 'age_months_max': 24, 'description': 'Mengucapkan 3-6 kata'},
      {'category': 'bahasa', 'subcategory': 'bahasa', 'age_months_min': 13, 'age_months_max': 24, 'description': 'Menunjuk bagian tubuh yang disebutkan'},
      {'category': 'bahasa', 'subcategory': 'bahasa', 'age_months_min': 13, 'age_months_max': 24, 'description': 'Membuat kalimat 2 kata'},
      // SOSIAL EMOSIONAL 0-3 bulan
      {'category': 'sosial_emosional', 'subcategory': 'sosial_emosional', 'age_months_min': 0, 'age_months_max': 3, 'description': 'Tersenyum spontan'},
      {'category': 'sosial_emosional', 'subcategory': 'sosial_emosional', 'age_months_min': 0, 'age_months_max': 3, 'description': 'Menatap mata orang tua'},
      {'category': 'sosial_emosional', 'subcategory': 'sosial_emosional', 'age_months_min': 0, 'age_months_max': 3, 'description': 'Tenang saat digendong'},
      // SOSIAL EMOSIONAL 4-6 bulan
      {'category': 'sosial_emosional', 'subcategory': 'sosial_emosional', 'age_months_min': 4, 'age_months_max': 6, 'description': 'Tersenyum pada bayangannya di cermin'},
      {'category': 'sosial_emosional', 'subcategory': 'sosial_emosional', 'age_months_min': 4, 'age_months_max': 6, 'description': 'Menangis jika mainan diambil'},
      {'category': 'sosial_emosional', 'subcategory': 'sosial_emosional', 'age_months_min': 4, 'age_months_max': 6, 'description': 'Membedakan orang yang dikenal dan asing'},
      // SOSIAL EMOSIONAL 7-12 bulan
      {'category': 'sosial_emosional', 'subcategory': 'sosial_emosional', 'age_months_min': 7, 'age_months_max': 12, 'description': 'Cemas dengan orang asing'},
      {'category': 'sosial_emosional', 'subcategory': 'sosial_emosional', 'age_months_min': 7, 'age_months_max': 12, 'description': 'Menangis saat ditinggal orang tua'},
      {'category': 'sosial_emosional', 'subcategory': 'sosial_emosional', 'age_months_min': 7, 'age_months_max': 12, 'description': 'Bermain cilukba'},
      // SOSIAL EMOSIONAL 13-24 bulan
      {'category': 'sosial_emosional', 'subcategory': 'sosial_emosional', 'age_months_min': 13, 'age_months_max': 24, 'description': 'Menunjukkan kasih sayang pada orang terdekat'},
      {'category': 'sosial_emosional', 'subcategory': 'sosial_emosional', 'age_months_min': 13, 'age_months_max': 24, 'description': 'Bermain bersama anak lain'},
      {'category': 'sosial_emosional', 'subcategory': 'sosial_emosional', 'age_months_min': 13, 'age_months_max': 24, 'description': 'Menunjukkan emosi (marah, senang, sedih)'},
    ];
    for (final m in milestones) {
      await db.insert('milestones', m);
    }
  }

  static Future<void> seedArticles(Database db) async {
    final articles = [
      {
        'title': 'Pentingnya ASI Eksklusif untuk Tumbuh Kembang Bayi',
        'content': 'ASI eksklusif selama 6 bulan pertama kehidupan bayi sangat penting untuk mendukung pertumbuhan dan perkembangan optimal. ASI mengandung semua nutrisi yang dibutuhkan bayi, termasuk antibodi yang melindungi dari berbagai penyakit.\n\nManfaat ASI Eksklusif:\n1. Meningkatkan daya tahan tubuh bayi\n2. Mendukung perkembangan otak\n3. Mengurangi risiko alergi\n4. Mempererat ikatan ibu dan bayi\n5. Mengurangi risiko obesitas di kemudian hari\n\nTips Menyusui:\n- Pastikan posisi menyusui yang nyaman\n- Susui bayi sesuai keinginannya (on demand)\n- Hindari penggunaan dot dan empeng\n- Konsumsi makanan bergizi seimbang\n- Minum air putih yang cukup',
        'category': 'Kesehatan',
        'image_url': 'asi_eksklusif',
        'published_at': '2026-05-01T08:00:00',
      },
      {
        'title': 'Stimulasi Motorik Kasar untuk Bayi 0-12 Bulan',
        'content': 'Stimulasi motorik kasar sangat penting untuk perkembangan fisik bayi. Berikut adalah beberapa aktivitas yang bisa dilakukan sesuai usia:\n\n0-3 Bulan:\n- Tummy time (tengkurap) 3-5 menit beberapa kali sehari\n- Goyangkan mainan di depan bayi untuk melatih mengangkat kepala\n\n4-6 Bulan:\n- Bantu bayi duduk dengan bantal penyangga\n- Letakkan mainan agak jauh untuk merangsang berguling\n\n7-9 Bulan:\n- Biarkan bayi merangkak di lantai yang aman\n- Berikan pegangan untuk belajar berdiri\n\n10-12 Bulan:\n- Pegang tangan bayi untuk belajar berjalan\n- Bermain kejar-kejaran merangkak',
        'category': 'Tumbuh Kembang',
        'image_url': 'stimulasi_motorik',
        'published_at': '2026-04-28T10:00:00',
      },
      {
        'title': 'Panduan MPASI Sehat untuk Si Kecil',
        'content': 'Makanan Pendamping ASI (MPASI) diberikan saat bayi berusia 6 bulan. Berikut panduan lengkapnya:\n\nPrinsip MPASI:\n1. Tepat waktu - mulai saat usia 6 bulan\n2. Adekuat - memenuhi kebutuhan nutrisi\n3. Aman - higienis dalam penyiapan\n4. Diberikan secara responsif\n\nTahapan Tekstur:\n- 6-8 bulan: Bubur halus/puree\n- 9-11 bulan: Makanan dicincang halus\n- 12-24 bulan: Makanan keluarga\n\nMenu Seimbang:\n- Karbohidrat (nasi, kentang, ubi)\n- Protein hewani (telur, ikan, ayam, daging)\n- Protein nabati (tahu, tempe, kacang)\n- Sayur dan buah\n- Lemak tambahan (minyak, mentega)',
        'category': 'Kesehatan',
        'image_url': 'mpasi_sehat',
        'published_at': '2026-04-25T09:00:00',
      },
      {
        'title': 'Mengenal Tahap Perkembangan Bahasa Anak',
        'content': 'Perkembangan bahasa anak dimulai sejak lahir. Memahami tahapannya membantu orang tua memberikan stimulasi yang tepat.\n\nTahapan Perkembangan Bahasa:\n\n0-6 Bulan (Pra-Linguistik):\n- Menangis sebagai komunikasi awal\n- Cooing (suara "aaa", "ooo")\n- Babbling (ba-ba, ma-ma)\n\n7-12 Bulan:\n- Memahami kata "tidak"\n- Mengucapkan kata pertama\n- Menunjuk benda yang diinginkan\n\n13-24 Bulan:\n- Kosakata bertambah cepat\n- Mulai menggabungkan 2 kata\n- Mengikuti instruksi sederhana\n\nCara Stimulasi:\n- Ajak bicara sesering mungkin\n- Bacakan buku cerita\n- Nyanyikan lagu anak\n- Respon setiap ocehan bayi\n- Hindari screen time berlebihan',
        'category': 'Tumbuh Kembang',
        'image_url': 'bahasa_anak',
        'published_at': '2026-04-20T11:00:00',
      },
      {
        'title': 'Tips Membangun Bonding dengan Anak',
        'content': 'Ikatan emosional (bonding) yang kuat antara orang tua dan anak sangat penting untuk perkembangan sosial-emosional anak.\n\nCara Membangun Bonding:\n\n1. Skin-to-skin contact\n- Gendong bayi dengan kontak kulit langsung\n- Lakukan saat menyusui atau setelah mandi\n\n2. Bermain bersama\n- Luangkan waktu bermain setiap hari\n- Ikuti minat dan inisiatif anak\n- Bermain peran dan imajinatif\n\n3. Komunikasi positif\n- Dengarkan anak dengan penuh perhatian\n- Gunakan kata-kata positif\n- Berikan pujian atas usaha anak\n\n4. Rutinitas bersama\n- Makan bersama keluarga\n- Membacakan cerita sebelum tidur\n- Jalan-jalan pagi bersama',
        'category': 'Parenting',
        'image_url': 'bonding_anak',
        'published_at': '2026-04-15T14:00:00',
      },
      {
        'title': 'Mengatasi Tantrum pada Balita',
        'content': 'Tantrum adalah ledakan emosi yang umum terjadi pada anak usia 1-4 tahun. Ini merupakan bagian normal dari perkembangan emosional anak.\n\nPenyebab Tantrum:\n- Belum bisa mengekspresikan keinginan\n- Lelah atau lapar\n- Frustrasi karena keterbatasan kemampuan\n- Mencari perhatian\n\nCara Mengatasi:\n1. Tetap tenang - jangan ikut emosi\n2. Pastikan anak aman dari bahaya\n3. Jangan menyerah pada tuntutan yang tidak wajar\n4. Alihkan perhatian anak\n5. Peluk anak saat mulai tenang\n6. Bicarakan perasaannya setelah tenang\n\nPencegahan:\n- Jaga rutinitas tidur dan makan\n- Berikan pilihan terbatas\n- Puji perilaku baik anak\n- Hindari pemicu yang sudah diketahui',
        'category': 'Psikologi Anak',
        'image_url': 'tantrum_balita',
        'published_at': '2026-04-10T10:00:00',
      },
    ];
    for (final a in articles) {
      await db.insert('articles', a);
    }
  }
}
