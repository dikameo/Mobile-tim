// lib/core/utils/formatters.dart
import 'package:intl/intl.dart'; // ← import ini wajib!

class Formatters {
  static String rupiah(int amount) {
    final formatter = NumberFormat("#,##0", "id_ID");
    return "Rp${formatter.format(amount)}";
  }
}
