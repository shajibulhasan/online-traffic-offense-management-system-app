import 'package:flutter/material.dart';
import 'package:online_traffic_offense_management_system/services/auth_service.dart';
import '../../services/assigned_officer_service.dart';
import '../model/assigned_officer.dart';

class AssignedOfficersScreen extends StatefulWidget {
  const AssignedOfficersScreen({super.key});

  @override
  State<AssignedOfficersScreen> createState() => _AssignedOfficersScreenState();
}

class _AssignedOfficersScreenState extends State<AssignedOfficersScreen> {
  late AssignedOfficerService _service;
  List<AssignedOfficer> _assignedOfficers = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeServiceAndLoadData();
  }

  Future<void> _initializeServiceAndLoadData() async {
    final token = await AuthService.getToken();
    _service = AssignedOfficerService(token: token ?? '');
    await _loadAssignedOfficers();
  }

  Future<void> _loadAssignedOfficers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final officers = await _service.getAllAssignedOfficers();
      setState(() {
        _assignedOfficers = officers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _showAssignDialog({AssignedOfficer? officer}) {
    final isEdit = officer != null;
    final districts = _service.getAllDistricts();

    // Controllers and selected values
    int? selectedOfficerId;
    String? selectedDistrict;
    String? selectedThana;
    String? selectedArea;

    List<Map<String, dynamic>> officers = [];
    List<Map<String, dynamic>> thanas = [];
    List<Map<String, dynamic>> areas = [];
    bool isLoadingOfficers = true;
    bool isLoadingThanas = false;
    bool isLoadingAreas = true;

    // Pre-fill if editing
    if (isEdit) {
      selectedOfficerId = officer!.officerId;
      selectedDistrict = officer.district;
      selectedThana = officer.thana;
      selectedArea = officer.areaLead;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        // Load initial data
        Future.microtask(() async {
          if (officers.isEmpty) {
            final fetchedOfficers = await _service.getAllOfficers();
            setState(() {
              officers = fetchedOfficers;
              isLoadingOfficers = false;
            });
          }

          if (areas.isEmpty) {
            final fetchedAreas = await _service.getAllAreas();
            setState(() {
              areas = fetchedAreas;
              isLoadingAreas = false;
            });
          }
        });

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(isEdit ? 'Edit Assigned Officer' : 'Assign New Officer'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Officer Dropdown
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonFormField<int>(
                        value: selectedOfficerId,
                        decoration: const InputDecoration(
                          labelText: 'Officer Name *',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          prefixIcon: Icon(Icons.person),
                        ),
                        items: isLoadingOfficers
                            ? [
                          const DropdownMenuItem<int>(
                            value: null,
                            child: Text('Loading...'),
                          )
                        ]
                            : officers.map<DropdownMenuItem<int>>((officer) {
                          return DropdownMenuItem<int>(
                            value: officer['id'],
                            child: Text(officer['name']),
                          );
                        }).toList(),
                        onChanged: !isLoadingOfficers
                            ? (value) {
                          setDialogState(() {
                            selectedOfficerId = value;
                          });
                        }
                            : null,
                        validator: (value) {
                          if (value == null && !isLoadingOfficers) return 'Please select officer';
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
                          labelText: 'District *',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          prefixIcon: Icon(Icons.location_city),
                        ),
                        items: districts.map<DropdownMenuItem<String>>((district) {
                          return DropdownMenuItem<String>(
                            value: district,
                            child: Text(district),
                          );
                        }).toList(),
                        onChanged: (value) async {
                          setDialogState(() {
                            selectedDistrict = value;
                            selectedThana = null;
                            selectedArea = null;
                            isLoadingThanas = true;
                          });

                          final fetchedThanas = await _service.getThanasByDistrict(value!);

                          setDialogState(() {
                            thanas = fetchedThanas;
                            isLoadingThanas = false;
                          });
                        },
                        validator: (value) {
                          if (value == null) return 'Please select district';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Thana Dropdown
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonFormField<String>(
                        value: selectedThana,
                        decoration: const InputDecoration(
                          labelText: 'Thana *',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          prefixIcon: Icon(Icons.location_on),
                        ),
                        items: () {
                          if (isLoadingThanas) {
                            return [
                              const DropdownMenuItem<String>(
                                value: null,
                                child: Text('Loading...'),
                              )
                            ];
                          }
                          return thanas.map<DropdownMenuItem<String>>((thana) {
                            return DropdownMenuItem<String>(
                              value: thana['thana_name'],
                              child: Text(thana['thana_name']),
                            );
                          }).toList();
                        }(),
                        onChanged: (selectedDistrict != null && !isLoadingThanas)
                            ? (value) {
                          setDialogState(() {
                            selectedThana = value;
                            selectedArea = null;
                          });

                          // Filter areas by thana
                          final filteredAreas = areas.where((area) =>
                          area['thana_name'] == value
                          ).toList();
                          setDialogState(() {
                            areas = filteredAreas;
                          });
                        }
                            : null,
                        validator: (value) {
                          if (value == null && !isLoadingThanas) return 'Please select thana';
                          return null;
                        },
                        disabledHint: const Text('Select district first'),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Area Dropdown
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonFormField<String>(
                        value: selectedArea,
                        decoration: const InputDecoration(
                          labelText: 'Area *',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          prefixIcon: Icon(Icons.list),
                        ),
                        items: () {
                          if (isLoadingAreas) {
                            return [
                              const DropdownMenuItem<String>(
                                value: null,
                                child: Text('Loading...'),
                              )
                            ];
                          }
                          final filteredAreas = areas.where((area) =>
                          selectedThana == null || area['thana_name'] == selectedThana
                          ).toList();
                          return filteredAreas.map<DropdownMenuItem<String>>((area) {
                            return DropdownMenuItem<String>(
                              value: area['area_name'],
                              child: Text(area['area_name']),
                            );
                          }).toList();
                        }(),
                        onChanged: (selectedThana != null)
                            ? (value) {
                          setDialogState(() {
                            selectedArea = value;
                          });
                        }
                            : null,
                        validator: (value) {
                          if (value == null && selectedThana != null) return 'Please select area';
                          return null;
                        },
                        disabledHint: const Text('Select thana first'),
                      ),
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
                  onPressed: () async {
                    // Validate
                    if (selectedOfficerId == null) {
                      _showSnackBar('Please select officer', Colors.orange);
                      return;
                    }
                    if (selectedDistrict == null) {
                      _showSnackBar('Please select district', Colors.orange);
                      return;
                    }
                    if (selectedThana == null) {
                      _showSnackBar('Please select thana', Colors.orange);
                      return;
                    }
                    if (selectedArea == null) {
                      _showSnackBar('Please select area', Colors.orange);
                      return;
                    }

                    Navigator.pop(context);

                    final officerData = {
                      'officer_id': selectedOfficerId,
                      'district': selectedDistrict,
                      'thana': selectedThana,
                      'area_lead': selectedArea,
                    };

                    if (isEdit) {
                      await _updateAssignedOfficer(officer!.id, officerData);
                    } else {
                      await _assignOfficer(officerData);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: Text(isEdit ? 'Update' : 'Assign'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _assignOfficer(Map<String, dynamic> data) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final newAssignment = await _service.assignOfficer(data);
      setState(() {
        _assignedOfficers.insert(0, newAssignment);
        _isLoading = false;
      });
      _showSnackBar('Officer assigned successfully', Colors.green);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showSnackBar('Error: ${e.toString()}', Colors.red);
    }
  }

  Future<void> _updateAssignedOfficer(int id, Map<String, dynamic> data) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final updated = await _service.updateAssignedOfficer(id, data);
      setState(() {
        final index = _assignedOfficers.indexWhere((o) => o.id == id);
        if (index != -1) {
          _assignedOfficers[index] = updated;
        }
        _isLoading = false;
      });
      _showSnackBar('Officer assignment updated', Colors.green);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showSnackBar('Error: ${e.toString()}', Colors.red);
    }
  }

  void _showDeleteDialog(AssignedOfficer officer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Unassign'),
        content: Text('Are you sure you want to unassign ${officer.name} from ${officer.areaLead}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteAssignedOfficer(officer.id, officer.name);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Unassign'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAssignedOfficer(int id, String name) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _service.deleteAssignedOfficer(id);
      setState(() {
        _assignedOfficers.removeWhere((o) => o.id == id);
        _isLoading = false;
      });
      _showSnackBar('$name unassigned successfully', Colors.green);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showSnackBar('Error: ${e.toString()}', Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assigned Officers'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAssignDialog(),
            tooltip: 'Assign Officer',
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
            Text(_error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadAssignedOfficers,
              child: const Text('Retry'),
            ),
          ],
        ),
      )
          : _assignedOfficers.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_off, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text(
              'No Officers Assigned',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              'Click the + button to assign an officer',
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: _loadAssignedOfficers,
        child: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: _assignedOfficers.length,
          itemBuilder: (context, index) {
            final officer = _assignedOfficers[index];
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
                    officer.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    '${officer.areaLead} - ${officer.thana}',
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
                            icon: Icons.email,
                            label: 'Email',
                            value: officer.email,
                          ),
                          const Divider(),
                          _InfoRow(
                            icon: Icons.location_city,
                            label: 'District',
                            value: officer.district,
                          ),
                          const Divider(),
                          _InfoRow(
                            icon: Icons.location_on,
                            label: 'Thana',
                            value: officer.thana,
                          ),
                          const Divider(),
                          _InfoRow(
                            icon: Icons.list,
                            label: 'Area',
                            value: officer.areaLead,
                          ),
                          if (officer.createdAt != null) ...[
                            const Divider(),
                            _InfoRow(
                              icon: Icons.calendar_today,
                              label: 'Assigned',
                              value: _formatDate(officer.createdAt!),
                            ),
                          ],
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _showAssignDialog(officer: officer),
                                  icon: const Icon(Icons.edit, size: 18),
                                  label: const Text('Edit'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _showDeleteDialog(officer),
                                  icon: const Icon(Icons.delete, size: 18),
                                  label: const Text('Unassign'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
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
          SizedBox(
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