
Penjelasan Folder 
lib/
├── core/                  # Core utilities & global configurations
│   ├── constants/         # Konstanta (spasi, ukuran, warna)
│   ├── routes/            # Navigasi halaman (GetX)
│   ├── themes/            # Tema aplikasi (warna, font, style)
│   └── utils/             # Helper functions (Screen, ResponsiveLayout, dll.)
│
├── features/
│   └── coffee_catalog/    # Fitur utama: katalog kopi
│       ├── catalog_mediaquery.dart      # Tampilan dengan MediaQuery
│       ├── catalog_withlayoutbuilder.dart  # Tampilan dengan LayoutBuilder
│       └── product_detail.dart          # Halaman detail produk
│
├── widgets/               # Komponen UI reusable
│   ├── product_card.dart  # Kartu produk kopi
│   └── responsive_widget.dart  # Widget responsif (ResponsiveLayout)
│
└── main.dart              # Entry point aplikasi