import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../controllers/spice_controller.dart';
import '../models/spice_model.dart';

class SpiceAddPage extends StatefulWidget {
  const SpiceAddPage({super.key});

  @override
  State<SpiceAddPage> createState() => _SpiceAddPageState();
}

class _SpiceAddPageState extends State<SpiceAddPage> {
  final nameC = TextEditingController();
  final originC = TextEditingController();
  final statusC = TextEditingController();

  XFile? pickedFile; // UNIVERSAL (Web + Android)
  final picker = ImagePicker();

  final spc = Get.find<SpiceController>();
  final isLoading = false.obs;

  Future<void> pickImage() async {
    final x = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
    );

    if (x != null) {
      setState(() => pickedFile = x);
    }
  }

  Future<void> submit() async {
    final name = nameC.text.trim();
    final origin = originC.text.trim();
    final status = statusC.text.trim();

    if (name.isEmpty) {
      Get.snackbar('Error', 'Nama kosong');
      return;
    }

    isLoading.value = true;

    try {
      String imageUrl = "";

      if (pickedFile != null) {
        imageUrl = await spc.uploadImage(pickedFile!);
      }

      final spice = Spice(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        origin: origin,
        exportStatus: status,
        image: imageUrl,
      );

      await spc.addLocalSpice(spice);

      try {
        await spc.loadSpices(forceRemote: true);
      } catch (_) {}

      Get.back();
      Get.snackbar("Sukses", "Rempah ditambahkan");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Rempah')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameC,
                decoration: const InputDecoration(labelText: 'Nama'),
              ),
              const SizedBox(height: 8),

              TextField(
                controller: originC,
                decoration: const InputDecoration(labelText: 'Asal'),
              ),
              const SizedBox(height: 8),

              TextField(
                controller: statusC,
                decoration: const InputDecoration(labelText: 'Status ekspor'),
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: pickImage,
                    icon: const Icon(Icons.photo),
                    label: const Text('Pilih Gambar'),
                  ),
                  const SizedBox(width: 12),
                  pickedFile == null
                      ? const Text('Belum ada gambar')
                      : const Text('Gambar siap'),
                ],
              ),

              const SizedBox(height: 20),

              Obx(
                () => ElevatedButton(
                  onPressed: isLoading.value ? null : submit,
                  child: isLoading.value
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Simpan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
