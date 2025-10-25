import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/spice_controller.dart';

class SpiceDashboard extends StatelessWidget {
  const SpiceDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SpiceController());

    return Scaffold(
      backgroundColor: Colors.teal[50],
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text(
          "SpiceTrack Dashboard",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: controller.toggleLibrary,
            icon: Obx(
              () => Icon(
                controller.useDio.value
                    ? Icons.swap_horiz
                    : Icons.swap_vert_circle_outlined,
                color: Colors.white,
              ),
            ),
            tooltip: "Ganti HTTP/Dio",
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.spices.isEmpty) {
          return const Center(child: Text('Tidak ada data rempah 🌿'));
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                "Waktu respon: ${controller.responseTime.value} ms "
                "(${controller.useDio.value ? 'Dio' : 'HTTP'})",
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      controller.loadSpicesWithRecommendation();
                    },
                    icon: const Icon(Icons.timer),
                    label: const Text("Async–Await"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      controller.loadSpicesWithCallback();
                    },
                    icon: const Icon(Icons.link),
                    label: const Text("Callback"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Obx(
              () => Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  controller.recommendationText.value,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.spices.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.8,
                ),
                itemBuilder: (context, index) {
                  final spice = controller.spices[index];
                  final isSelected = controller.selectedIndex.value == index;

                  return GestureDetector(
                    onTap: () {
                      controller.selectedIndex.value =
                          controller.selectedIndex.value == index ? -1 : index;
                    },
                    child: AnimatedScale(
                      scale: isSelected ? 1.05 : 1.0,
                      duration: const Duration(milliseconds: 250),
                      child: Card(
                        elevation: isSelected ? 8 : 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        shadowColor: isSelected
                            ? Colors.teal.withOpacity(0.4)
                            : Colors.grey.withOpacity(0.3),
                        child: Column(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(16),
                                ),
                                child: Image.network(
                                  spice.image,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Text(
                                    spice.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "Asal: ${spice.origin}",
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  Text(
                                    "Status: ${spice.exportStatus}",
                                    style: const TextStyle(
                                      color: Colors.black54,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
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
