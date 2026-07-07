import 'package:flutter/material.dart';
import '../models/akademik_model.dart';

enum TaskFilter { all, pending, completed }

class TugasPage extends StatefulWidget {
  const TugasPage({super.key});
  @override
  State<TugasPage> createState() => _TugasPageState();
}

class _TugasPageState extends State<TugasPage> {
  String _searchQuery = '';
  TaskFilter _filter = TaskFilter.all;

  void _toggleTugas(int i) {
    setState(() {
      AkademikData.tugasList[i].sudahDikumpulkan =
          !AkademikData.tugasList[i].sudahDikumpulkan;
      AkademikData.saveTasks();
    });
  }

  List<Tugas> get _filteredTugas {
    final tasks = AkademikData.tugasList.where((t) {
      if (_filter == TaskFilter.pending && t.sudahDikumpulkan) return false;
      if (_filter == TaskFilter.completed && !t.sudahDikumpulkan) return false;
      final query = _searchQuery.toLowerCase();
      return t.judul.toLowerCase().contains(query) ||
          t.mataKuliah.toLowerCase().contains(query) ||
          t.deadline.toLowerCase().contains(query);
    }).toList();
    tasks.sort((a, b) {
      final aDate = a.dueDate ?? DateTime(9999);
      final bDate = b.dueDate ?? DateTime(9999);
      return aDate.compareTo(bDate);
    });
    return tasks;
  }

  void _deleteTugas(int index) {
    setState(() {
      AkademikData.tugasList.removeAt(index);
      AkademikData.saveTasks();
    });
  }

  void _editTugas(int index) {
    final task = AkademikData.tugasList[index];
    final formKey = GlobalKey<FormState>();
    String judul = task.judul;
    String mataKuliah = task.mataKuliah;
    String deadline = task.deadline;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Edit Tugas',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: judul,
                  decoration: const InputDecoration(
                    labelText: 'Judul Tugas',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Masukkan judul tugas';
                    }
                    return null;
                  },
                  onSaved: (value) => judul = value?.trim() ?? '',
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: mataKuliah,
                  decoration: const InputDecoration(
                    labelText: 'Mata Kuliah',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Masukkan nama mata kuliah';
                    }
                    return null;
                  },
                  onSaved: (value) => mataKuliah = value?.trim() ?? '',
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: deadline,
                  decoration: const InputDecoration(
                    labelText: 'Deadline',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Masukkan tenggat waktu';
                    }
                    return null;
                  },
                  onSaved: (value) => deadline = value?.trim() ?? '',
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade700,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      if (formKey.currentState?.validate() ?? false) {
                        formKey.currentState?.save();
                        setState(() {
                          AkademikData.tugasList[index] = Tugas(
                            judul,
                            mataKuliah,
                            deadline,
                            sudahDikumpulkan: task.sudahDikumpulkan,
                          );
                          AkademikData.saveTasks();
                        });
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Update Tugas'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _addTugas() {
    final formKey = GlobalKey<FormState>();
    String judul = '';
    String mataKuliah = '';
    String deadline = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tambah Tugas Baru',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Judul Tugas',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Masukkan judul tugas';
                    }
                    return null;
                  },
                  onSaved: (value) => judul = value?.trim() ?? '',
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Mata Kuliah',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Masukkan nama mata kuliah';
                    }
                    return null;
                  },
                  onSaved: (value) => mataKuliah = value?.trim() ?? '',
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Deadline',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Masukkan tenggat waktu';
                    }
                    return null;
                  },
                  onSaved: (value) => deadline = value?.trim() ?? '',
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade700,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      if (formKey.currentState?.validate() ?? false) {
                        formKey.currentState?.save();
                        setState(() {
                          AkademikData.tugasList.add(
                            Tugas(judul, mataKuliah, deadline),
                          );
                          AkademikData.saveTasks();
                        });
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Simpan Tugas'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final belum = AkademikData.tugasList
        .where((t) => !t.sudahDikumpulkan)
        .length;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange.shade700,
        title: const Text(
          'Daftar Tugas',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        color: const Color(0xFFF0F2F5),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.orange.shade700,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _statItem('Belum', '$belum', Colors.red.shade100),
                  _statItem(
                    'Selesai',
                    '${AkademikData.tugasList.length - belum}',
                    Colors.green.shade100,
                  ),
                  _statItem(
                    'Total',
                    '${AkademikData.tugasList.length}',
                    Colors.white,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                children: [
                  TextField(
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: 'Cari tugas, mata kuliah, atau deadline',
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: TaskFilter.values.map((filter) {
                      final label = filter == TaskFilter.all
                          ? 'Semua'
                          : filter == TaskFilter.pending
                          ? 'Belum'
                          : 'Selesai';
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(label),
                            selected: _filter == filter,
                            onSelected: (_) {
                              setState(() {
                                _filter = filter;
                              });
                            },
                            selectedColor: Colors.orange.shade700,
                            backgroundColor: Colors.white,
                            labelStyle: TextStyle(
                              color: _filter == filter
                                  ? Colors.white
                                  : Colors.grey.shade800,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _filteredTugas.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final t = _filteredTugas[i];
                  final originalIndex = AkademikData.tugasList.indexOf(t);
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: Checkbox(
                        value: t.sudahDikumpulkan,
                        activeColor: Colors.green,
                        onChanged: (_) => _toggleTugas(originalIndex),
                      ),
                      title: Text(
                        t.judul,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                          decoration: t.sudahDikumpulkan
                              ? TextDecoration.lineThrough
                              : null,
                          color: t.sudahDikumpulkan ? Colors.grey : null,
                        ),
                      ),
                      subtitle: Text(
                        '${t.mataKuliah} • Deadline: ${t.deadline}',
                        style: const TextStyle(fontSize: 11),
                      ),
                      trailing: PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert),
                        onSelected: (value) {
                          if (value == 'edit') {
                            _editTugas(originalIndex);
                          } else if (value == 'delete') {
                            _deleteTugas(originalIndex);
                          }
                        },
                        itemBuilder: (_) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Text('Edit'),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text('Hapus'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.orange.shade700,
        onPressed: _addTugas,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Tugas'),
      ),
    );
  }

  Widget _statItem(String label, String value, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: bg.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
