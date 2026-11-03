import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 1. STATE VARIABLES (Our App's Memory)
  List<String> notes = [];
  List<String> dates = [];
  String selectedDate = 'No date chosen';

  // 2. TEXT CONTROLLERS (Reads what the user types)
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _editController = TextEditingController();

  // =========================================================
  // PART A: LOCAL STORAGE (SHARED PREFERENCES)
  // =========================================================

  // STEP 3 (Slide 7): Save both lists to phone storage
  Future<void> saveToStorage() async {
    // Write SharedPreferences save logic here
    final prefs = await SharedPreferences.getInstance();

    await prefs.setStringList('saved_notes', notes);
    await prefs.setStringList('saved_dates', dates);
  }

  // STEP 4A (Slide 8): Call loadFromStorage when the screen first opens
  @override
  void initState() {
    super.initState();
    loadFromStorage();
  }

  // STEP 4B (Slide 8): Load both lists from phone storage
  Future<void> loadFromStorage() async {    
    final prefs = await SharedPreferences.getInstance();

    final loadedNotes = prefs.getStringList('saved_notes') ?? [];
    if (loadedNotes.isNotEmpty) {
      print('Notes saved successfully: $loadedNotes');
    } else {
      print('No notes found in storage.');
    }
  }

  // =========================================================
  // PART B: DATE PICKER & INTL FORMATTING
  // =========================================================

  // STEP 5 (Slide 9): Open calendar popup and format date with intl
  Future<void> pickDate() async {
    // Write showDatePicker and DateFormat logic here
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        selectedDate = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  // =========================================================
  // PART C: CRUD FUNCTIONS (CREATE, DELETE, UPDATE)
  // =========================================================

  // STEP 6 (Slide 11 - CREATE): Add new task and save to storage
  void addTask() {
    // Write addTask logic here
    if(_noteController.text.isNotEmpty) return;
    
    setState(() {
      notes.add(_noteController.text);
      dates.add(selectedDate);
      _noteController.clear();
    });

    saveToStorage();
  }

  // STEP 7 (Slide 12 - DELETE): Remove task by index and save to storage
  void deleteTask(int index) {
    // Write deleteTask logic here
    setState(() {
      notes.removeAt(index);
      dates.removeAt(index);
    });

    saveToStorage();
  }

  // STEP 8 (Slide 13 - UPDATE): Open popup dialog to edit task name and date
  void editTask(int index) {
    _editController.text = notes[index];
    String tempEditedDate = dates[index];

    // Write showDialog with StatefulBuilder and AlertDialog here
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Edit Task'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _editController,
                    decoration: const InputDecoration(
                      labelText: 'Task Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setDialogState(() {
                          tempEditedDate = DateFormat('yyyy-MM-dd').format(picked);
                        });
                      }
                    },
                    icon: const Icon(Icons.calendar_today),
                    label: Text('Due: $tempEditedDate'),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Close'),
                ),
              ],
            );
          }
        );
      }
    );
  }

  @override
  void dispose() {
    _noteController.dispose();
    _editController.dispose();
    super.dispose();
  }

  // =========================================================
  // PART D: USER INTERFACE (PRE-BUILT SKELETON)
  // =========================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          'Smart Task Planner',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // --- TOP CARD: INPUT FORM ---
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _noteController,
                      decoration: const InputDecoration(
                        labelText: 'What do you need to do?',
                        hintText: 'e.g., Finish Flutter Project',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.task_alt),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 18,
                          color: Colors.indigo,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Due: $selectedDate',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        TextButton(
                          onPressed: pickDate,
                          child: const Text('Pick Date'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: addTask,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Task'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),
            
            Expanded(
              child: notes.isEmpty
                  ? const Center(
                      child: Text(
                        'No tasks yet. Add your first task above!',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      itemCount: notes.length,
                      itemBuilder: (context, index) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.indigo.shade100,
                              foregroundColor: Colors.indigo,
                              child: Text('${index + 1}'),
                            ),
                            title: Text(
                              notes[index],
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text('Due: ${dates[index]}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () => editTask(index),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => deleteTask(index),
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
    );
  }
}