import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/spice_controller.dart';

class SpiceDashboard extends StatelessWidget {
  const SpiceDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final spiceC = Get.find<SpiceController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Daftar Rempah"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Get.toNamed('/add'); // ke halaman tambah
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => spiceC.loadSpices(forceRemote: true),
          ),
        ],
      ),

      body: Obx(() {
        if (spiceC.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (spiceC.spices.isEmpty) {
          return const Center(child: Text("Belum ada data bumbu"));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================================
            // HASIL UJI SHARED PREFERENCES
            // ================================
            Padding(
              padding: const EdgeInsets.all(8),
              child: Obx(() {
                return Text(
                  "SharedPref Read: ${spiceC.prefReadTime.value} ms | "
                  "Write: ${spiceC.prefWriteTime.value} ms",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                );
              }),
            ),

            // ================================
            // HASIL RESPONSE TIME API (HTTP/DIO)
            // ================================
            Padding(
              padding: const EdgeInsets.all(8),
              child: Obx(() {
                return Text(
                  "API Response Time: ${spiceC.responseTime.value} ms",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                );
              }),
            ),

            // ================================
            // LIST DATA REMPAH
            // ================================
            Expanded(
              child: ListView.builder(
                itemCount: spiceC.spices.length,
                itemBuilder: (context, index) {
                  final spice = spiceC.spices[index];

                  return Card(
                    margin: const EdgeInsets.all(8),
                    child: ListTile(
                      leading: spice.image.isNotEmpty
                          ? Image.network(
                              spice.image,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (c, e, s) =>
                                  const Icon(Icons.image_not_supported),
                            )
                          : const Icon(Icons.image_not_supported),
                      title: Text(spice.name),
                      subtitle: Text(
                        "Asal: ${spice.origin}\n"
                        "Status Ekspor: ${spice.exportStatus}",
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Hapus'),
                              content: const Text(
                                'Yakin ingin menghapus rempah ini?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Batal'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Hapus'),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            await spiceC.deleteSpice(spice.id);
                          }
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      }),

      bottomNavigationBar: Obx(() {
        return Container(
          padding: const EdgeInsets.all(8),
          child: Text(
            'Total data: ${spiceC.spices.length}',
            textAlign: TextAlign.center,
          ),
        );
      }),
    );
  }
}
