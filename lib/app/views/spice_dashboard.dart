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
              Get.toNamed('/add');
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
            // ================
            // TOMBOL MAP MODULE 5
            // ================
            Padding(
              padding: const EdgeInsets.all(12),
              child: ElevatedButton(
                onPressed: () => Get.toNamed('/map'),
                child: const Text("Open Map / Location Module 5"),
              ),
            ),

            // Pref test
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

            // Response time API
            Padding(
              padding: const EdgeInsets.all(8),
              child: Obx(() {
                return Text(
                  "API Response Time: ${spiceC.responseTime.value} ms",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                );
              }),
            ),

            Expanded(
              child: ListView.builder(
                itemCount: spiceC.spices.length,
                itemBuilder: (context, index) {
                  final spice = spiceC.spices[index];

                  return Card(
                    margin: const EdgeInsets.all(8),
                    child: ListTile(
                      title: Text(spice.name),
                      subtitle: Text(
                        "Asal: ${spice.origin}\n"
                        "Status Ekspor: ${spice.exportStatus}",
                      ),
                      trailing: Icon(Icons.arrow_forward_ios),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      }),
    );
  }
}
