import 'package:flutter/material.dart';
import 'package:online_traffic_offense_management_system/services/auth_service.dart';
import '../../services/thana_service.dart';
import '../model/thana.dart';

class ThanaListScreen extends StatefulWidget {
  const ThanaListScreen({super.key});

  @override
  State<ThanaListScreen> createState() => _ThanaListScreenState();
}

class _ThanaListScreenState extends State<ThanaListScreen> {
  late ThanaService _thanaService;
  List<Thana> _thanas = [];
  bool _isLoading = true;
  String? _error;

  // Division and District data
  final Map<String, List<String>> _divisionDistricts = {
    "Barishal": [
      "Barguna", "Barisal", "Bhola", "Jhalokathi", "Patuakhali", "Pirojpur"
    ],
    "Chattogram": [
      "Bandarban", "Brahmanbaria", "Chandpur", "Chittagong", "Comilla",
      "Coxsbazar", "Feni", "Khagrachari", "Lakshmipur", "Noakhali", "Rangamati"
    ],
    "Dhaka": [
      "Dhaka", "Faridpur", "Gazipur", "Gopalganj", "Kishoreganj", "Madaripur",
      "Manikganj", "Munshiganj", "Narayanganj", "Narsingdi", "Rajbari",
      "Shariatpur", "Tangail"
    ],
    "Khulna": [
      "Bagerhat", "Chuadanga", "Jessore", "Jhenaidah", "Khulna",
      "Kushtia", "Magura", "Meherpur", "Narail", "Satkhira"
    ],
    "Mymensingh": [
      "Jamalpur", "Mymensingh", "Netrokona", "Sherpur"
    ],
    "Rajshahi": [
      "Bogura", "Chapai Nawabganj", "Joypurhat", "Naogaon",
      "Natore", "Pabna", "Rajshahi", "Sirajganj"
    ],
    "Rangpur": [
      "Dinajpur", "Gaibandha", "Kurigram", "Lalmonirhat",
      "Nilphamari", "Panchagarh", "Rangpur", "Thakurgaon"
    ],
    "Sylhet": [
      "Habiganj", "Moulvibazar", "Sunamganj", "Sylhet"
    ],
  };

  @override
  void initState() {
    super.initState();
    _initializeServiceAndLoadData();
  }

  Future<void> _initializeServiceAndLoadData() async {
    final token = await AuthService.getToken();
    _thanaService = ThanaService(token: token ?? '');
    await _loadThanas();
  }

  Future<void> _loadThanas() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final thanas = await _thanaService.getAllThanas();
      setState(() {
        _thanas = thanas;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _addThana(Map<String, dynamic> thanaData) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final newThana = await _thanaService.createThana(thanaData);

      // Add to list and sort
      setState(() {
        _thanas.add(newThana);
        // Sort by id or created_at descending
        _thanas.sort((a, b) => b.id.compareTo(a.id));
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thana added successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updateThana(int id, Map<String, dynamic> thanaData) async {
    // Show loading indicator (optional)
    setState(() {
      _isLoading = true;
    });

    try {
      final updatedThana = await _thanaService.updateThana(id, thanaData);

      // Update the list
      setState(() {
        final index = _thanas.indexWhere((t) => t.id == id);
        if (index != -1) {
          _thanas[index] = updatedThana;
        }
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thana updated successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteThana(int id, String thanaName) async {
    try {
      await _thanaService.deleteThana(id);
      setState(() {
        _thanas.removeWhere((t) => t.id == id);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$thanaName deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showAddEditDialog({Thana? thana}) {
    final isEdit = thana != null;

    // Controllers
    final thanaNameController = TextEditingController(text: thana?.thanaName);
    final contactController = TextEditingController(text: thana?.contact);
    final addressController = TextEditingController(text: thana?.address);

    // Selected values
    String? selectedDivision = thana?.division;
    String? selectedDistrict = thana?.district;

    // State for dialog
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          // Get districts based on selected division
          List<String> districts = [];
          if (selectedDivision != null && _divisionDistricts.containsKey(selectedDivision)) {
            districts = _divisionDistricts[selectedDivision]!;
          }

          return AlertDialog(
            title: Text(isEdit ? 'Edit Thana' : 'Add New Thana'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Division Dropdown
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonFormField<String>(
                      value: selectedDivision,
                      decoration: const InputDecoration(
                        labelText: 'Division',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        prefixIcon: Icon(Icons.map),
                      ),
                      items: _divisionDistricts.keys.map((division) {
                        return DropdownMenuItem(
                          value: division,
                          child: Text(division),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedDivision = value;
                          selectedDistrict = null; // Reset district when division changes
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a division';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // District Dropdown
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonFormField<String>(
                      value: selectedDistrict,
                      decoration: const InputDecoration(
                        labelText: 'District',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        prefixIcon: Icon(Icons.location_city),
                      ),
                      items: districts.map((district) {
                        return DropdownMenuItem(
                          value: district,
                          child: Text(district),
                        );
                      }).toList(),
                      onChanged: selectedDivision != null
                          ? (value) {
                        setDialogState(() {
                          selectedDistrict = value;
                        });
                      }
                          : null,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a district';
                        }
                        return null;
                      },
                      disabledHint: const Text('Select division first'),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Thana Name
                  TextField(
                    controller: thanaNameController,
                    decoration: const InputDecoration(
                      labelText: 'Thana Name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_on),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Contact
                  TextField(
                    controller: contactController,
                    decoration: const InputDecoration(
                      labelText: 'Contact',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),

                  // Address
                  TextField(
                    controller: addressController,
                    decoration: const InputDecoration(
                      labelText: 'Detailed Address',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.home),
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Validate fields
                  if (selectedDivision == null || selectedDivision!.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please select a division'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                    return;
                  }

                  if (selectedDistrict == null || selectedDistrict!.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please select a district'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                    return;
                  }

                  final thanaName = thanaNameController.text.trim();
                  if (thanaName.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter thana name'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                    return;
                  }

                  final thanaData = {
                    'division': selectedDivision!,
                    'district': selectedDistrict!,
                    'thana_name': thanaName,
                    'contact': contactController.text.trim(),
                    'address': addressController.text.trim(),
                  };

                  Navigator.pop(context);

                  if (isEdit) {
                    _updateThana(thana!.id, thanaData);
                  } else {
                    _addThana(thanaData);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: Text(isEdit ? 'Update' : 'Add'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showDeleteDialog(Thana thana) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red.shade700),
            const SizedBox(width: 8),
            const Text('Confirm Delete'),
          ],
        ),
        content: Text('Are you sure you want to delete ${thana.thanaName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteThana(thana.id, thana.thanaName);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thana List'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddEditDialog(),
            tooltip: 'Add Thana',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: TextStyle(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadThanas,
              child: const Text('Retry'),
            ),
          ],
        ),
      )
          : _thanas.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No Thana Found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Click the + button to add a new thana',
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: _loadThanas,
        child: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: _thanas.length,
          itemBuilder: (context, index) {
            final thana = _thanas[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: index % 2 == 0 ? Colors.white : Colors.green.shade50,
                ),
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.green.shade100,
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    thana.thanaName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    '${thana.district}, ${thana.division}',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _InfoRow(
                            icon: Icons.map,
                            label: 'Division',
                            value: thana.division,
                          ),
                          const Divider(),
                          _InfoRow(
                            icon: Icons.location_city,
                            label: 'District',
                            value: thana.district,
                          ),
                          const Divider(),
                          _InfoRow(
                            icon: Icons.phone,
                            label: 'Contact',
                            value: thana.contact,
                          ),
                          const Divider(),
                          _InfoRow(
                            icon: Icons.home,
                            label: 'Address',
                            value: thana.address,
                          ),
                          if (thana.createdAt != null) ...[
                            const Divider(),
                            _InfoRow(
                              icon: Icons.calendar_today,
                              label: 'Created',
                              value: _formatDate(thana.createdAt!),
                            ),
                          ],
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _showAddEditDialog(thana: thana),
                                  icon: const Icon(Icons.edit, size: 18),
                                  label: const Text('Edit'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _showDeleteDialog(thana),
                                  icon: const Icon(Icons.delete, size: 18),
                                  label: const Text('Delete'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day} ${_getMonth(date.month)}, ${date.year}';
  }

  String _getMonth(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 100,
            child: Row(
              children: [
                Icon(icon, size: 16, color: Colors.green.shade600),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}