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
  AssignedOfficerService? _service;
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
    if (!mounted) return;
    _service = AssignedOfficerService(token: token ?? '');
    await _loadAssignedOfficers();
  }

  Future<void> _loadAssignedOfficers() async {
    if (_service == null) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final officers = await _service!.getAllAssignedOfficers();
      if (!mounted) return;
      setState(() {
        _assignedOfficers = officers;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _showAssignDialog({AssignedOfficer? officer}) {
    if (_service == null) return;

    final isEdit = officer != null;
    final AssignedOfficer? editOfficer = officer;
    final districts = _service!.getAllDistricts();

    // Variables
    int? selectedOfficerId = isEdit ? editOfficer!.officerId : null;
    String? selectedDistrict = isEdit ? editOfficer!.district : null;
    String? selectedThana = isEdit ? editOfficer!.thana : null;
    String? selectedArea = isEdit ? editOfficer!.areaLead : null;
    String selectedOfficerName = isEdit ? editOfficer!.name : '';

    // Data lists
    List<Map<String, dynamic>> officers = [];
    List<Map<String, dynamic>> thanas = [];
    List<Map<String, dynamic>> allAreas = [];

    // Loading states
    bool isLoadingOfficers = true;
    bool isLoadingAreas = true;
    bool isLoadingThanas = false;

    // FIX: guard flag so microtask only fires once
    bool _initialized = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            // FIX: only load once using _initialized flag
            if (!_initialized) {
              _initialized = true;
              Future.microtask(() async {
                // Load officers - FIXED: Ensure officers list is populated
                try {
                  final fetchedOfficers = await _service!.getAllOfficers();
                  if (!mounted) return;
                  setDialogState(() {
                    officers = fetchedOfficers;
                    isLoadingOfficers = false;
                    if (isEdit && selectedOfficerId != null) {
                      final found = officers.firstWhere(
                            (o) => o['id'] == selectedOfficerId,
                        orElse: () => {},
                      );
                      if (found.isNotEmpty) {
                        selectedOfficerName = found['name']?.toString() ?? '';
                      }
                    }
                  });
                } catch (e) {
                  if (!mounted) return;
                  setDialogState(() {
                    isLoadingOfficers = false;
                    officers = [];
                  });
                }

                // Load all areas
                try {
                  final fetchedAreas = await _service!.getAllAreas();
                  if (!mounted) return;
                  setDialogState(() {
                    allAreas = fetchedAreas;
                    isLoadingAreas = false;
                  });
                } catch (e) {
                  if (!mounted) return;
                  setDialogState(() {
                    isLoadingAreas = false;
                    allAreas = [];
                  });
                }

                // Load thanas for edit mode
                if (isEdit && selectedDistrict != null) {
                  try {
                    final fetchedThanas =
                    await _service!.getThanasByDistrict(selectedDistrict!);
                    if (!mounted) return;
                    setDialogState(() => thanas = fetchedThanas);
                  } catch (e) {
                    if (!mounted) return;
                    setDialogState(() => thanas = []);
                  }
                }
              });
            }

            return AlertDialog(
              title: Row(
                children: [
                  Icon(isEdit ? Icons.edit : Icons.person_add,
                      color: Colors.green, size: 28),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      isEdit ? 'Edit Assigned Officer' : 'Assign New Officer',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Officer Dropdown
                    _buildLabel('Officer Name'),
                    const SizedBox(height: 8),
                    _buildDropdownContainer(
                      onTap: (isLoadingOfficers || officers.isEmpty)
                          ? null
                          : () async {
                        final selected =
                        await showModalBottomSheet<int>(
                          context: context,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(20)),
                          ),
                          builder: (context) {
                            return SafeArea(
                              child: _buildBottomSheet(
                                title: 'Select Officer',
                                child: ListView(
                                  children: officers.map((o) {
                                    final id = o['id'] as int;
                                    final name =
                                        o['name']?.toString() ??
                                            'Unknown';
                                    return ListTile(
                                      leading: const Icon(Icons.person,
                                          color: Colors.green),
                                      title: Text(name),
                                      trailing: selectedOfficerId == id
                                          ? const Icon(Icons.check,
                                          color: Colors.green)
                                          : null,
                                      onTap: () =>
                                          Navigator.pop(context, id),
                                    );
                                  }).toList(),
                                ),
                              ),
                            );
                          },
                        );

                        if (selected != null) {
                          final selectedData = officers.firstWhere(
                                (o) => o['id'] == selected,
                            orElse: () => {},
                          );
                          setDialogState(() {
                            selectedOfficerId = selected;
                            selectedOfficerName =
                                selectedData['name']?.toString() ?? '';
                          });
                        }
                      },
                      icon: Icons.person,
                      displayText: isLoadingOfficers
                          ? 'Loading officers...'
                          : (selectedOfficerId != null &&
                          selectedOfficerName.isNotEmpty
                          ? selectedOfficerName
                          : 'Select Officer'),
                      hasValue: selectedOfficerId != null,
                    ),

                    const SizedBox(height: 16),

                    // District Dropdown
                    _buildLabel('District'),
                    const SizedBox(height: 8),
                    _buildDropdownContainer(
                      onTap: () async {
                        final selected = await showModalBottomSheet<String>(
                          context: context,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(20)),
                          ),
                          builder: (context) {
                            return SafeArea(
                              child: _buildBottomSheet(
                                title: 'Select District',
                                child: ListView(
                                  children: districts.map((d) {
                                    return ListTile(
                                      leading: const Icon(Icons.location_city,
                                          color: Colors.green),
                                      title: Text(d),
                                      trailing: selectedDistrict == d
                                          ? const Icon(Icons.check,
                                          color: Colors.green)
                                          : null,
                                      onTap: () => Navigator.pop(context, d),
                                    );
                                  }).toList(),
                                ),
                              ),
                            );
                          },
                        );

                        if (selected != null && selected != selectedDistrict) {
                          setDialogState(() {
                            selectedDistrict = selected;
                            selectedThana = null;
                            selectedArea = null;
                            isLoadingThanas = true;
                          });

                          try {
                            final fetchedThanas =
                            await _service!.getThanasByDistrict(selected);
                            if (!mounted) return;
                            setDialogState(() {
                              thanas = fetchedThanas;
                              isLoadingThanas = false;
                            });
                          } catch (e) {
                            if (!mounted) return;
                            setDialogState(() {
                              thanas = [];
                              isLoadingThanas = false;
                            });
                          }
                        }
                      },
                      icon: Icons.location_city,
                      displayText: selectedDistrict ?? 'Select District',
                      hasValue: selectedDistrict != null,
                    ),

                    const SizedBox(height: 16),

                    // Thana Dropdown
                    _buildLabel('Thana'),
                    const SizedBox(height: 8),
                    _buildDropdownContainer(
                      // FIX: disable while loading thanas too
                      onTap: (selectedDistrict == null || isLoadingThanas)
                          ? null
                          : () async {
                        final selected =
                        await showModalBottomSheet<String>(
                          context: context,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(20)),
                          ),
                          builder: (context) {
                            return SafeArea(
                              child: _buildBottomSheet(
                                title: 'Select Thana',
                                child: thanas.isEmpty
                                    ? const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(20),
                                    child: Text(
                                        'No thanas available'),
                                  ),
                                )
                                    : ListView(
                                  children: thanas.map((t) {
                                    final thanaName =
                                        t['thana_name']
                                            ?.toString() ??
                                            '';
                                    return ListTile(
                                      leading: const Icon(
                                          Icons.location_on,
                                          color: Colors.green),
                                      title: Text(thanaName),
                                      trailing:
                                      selectedThana == thanaName
                                          ? const Icon(
                                          Icons.check,
                                          color:
                                          Colors.green)
                                          : null,
                                      onTap: () => Navigator.pop(
                                          context, thanaName),
                                    );
                                  }).toList(),
                                ),
                              ),
                            );
                          },
                        );

                        if (selected != null &&
                            selected != selectedThana) {
                          setDialogState(() {
                            selectedThana = selected;
                            selectedArea = null;
                          });
                        }
                      },
                      icon: Icons.location_on,
                      // FIX: show loading indicator text when thanas are loading
                      displayText: selectedDistrict == null
                          ? 'Select district first'
                          : isLoadingThanas
                          ? 'Loading thanas...'
                          : (selectedThana ?? 'Select Thana'),
                      hasValue: selectedThana != null,
                    ),

                    const SizedBox(height: 16),

                    // Area Dropdown - FIXED
                    _buildLabel('Area Lead'),
                    const SizedBox(height: 8),
                    _buildDropdownContainer(
                      // FIX: disable while areas are still loading
                      onTap: (selectedThana == null || isLoadingAreas)
                          ? null
                          : () async {
                        // FIXED: Filter areas by thana name correctly
                        final filteredAreas = allAreas
                            .where((area) {
                          final areaThana = area['thana_name']?.toString() ?? '';
                          return areaThana == selectedThana;
                        })
                            .toList();

                        if (filteredAreas.isEmpty) {
                          _showSnackBar(
                              'No areas available for this thana',
                              Colors.orange);
                          return;
                        }

                        final selected =
                        await showModalBottomSheet<String>(
                          context: context,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(20)),
                          ),
                          builder: (context) {
                            return SafeArea(
                              child: _buildBottomSheet(
                                title: 'Select Area Lead',
                                child: ListView(
                                  children: filteredAreas.map((a) {
                                    final areaName =
                                        a['area_name']?.toString() ?? '';
                                    return ListTile(
                                      leading: const Icon(Icons.list_alt,
                                          color: Colors.green),
                                      title: Text(areaName),
                                      trailing: selectedArea == areaName
                                          ? const Icon(Icons.check,
                                          color: Colors.green)
                                          : null,
                                      onTap: () =>
                                          Navigator.pop(context, areaName),
                                    );
                                  }).toList(),
                                ),
                              ),
                            );
                          },
                        );

                        if (selected != null && selected != selectedArea) {
                          setDialogState(() => selectedArea = selected);
                        }
                      },
                      icon: Icons.list_alt,
                      // FIXED: Show loading text while areas are loading
                      displayText: selectedThana == null
                          ? 'Select thana first'
                          : isLoadingAreas
                          ? 'Loading areas...'
                          : (selectedArea != null && selectedArea!.isNotEmpty
                          ? selectedArea!
                          : 'Select Area Lead'),
                      hasValue: selectedArea != null && selectedArea!.isNotEmpty,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(fontSize: 16)),
                ),
                ElevatedButton(
                  onPressed: () async {
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
                    if (selectedArea == null || selectedArea!.isEmpty) {
                      _showSnackBar('Please select area lead', Colors.orange);
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
                      await _updateAssignedOfficer(
                          editOfficer!.id, officerData);
                    } else {
                      await _assignOfficer(officerData);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: Text(isEdit ? 'Update' : 'Assign',
                      style: const TextStyle(fontSize: 16)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ── Reusable helper widgets ──────────────────────────────────────────────

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }

  Widget _buildDropdownContainer({
    required VoidCallback? onTap,
    required IconData icon,
    required String displayText,
    required bool hasValue,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: Colors.green.shade600, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  displayText,
                  style: TextStyle(
                    color: hasValue ? Colors.black87 : Colors.grey.shade500,
                    fontSize: 14,
                  ),
                ),
              ),
              // FIX: show spinner inside dropdown when onTap is null due to loading
              onTap == null && (displayText.contains('Loading'))
                  ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.green.shade600,
                ),
              )
                  : Icon(Icons.arrow_drop_down, color: Colors.green.shade600),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSheet({required String title, required Widget child}) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              title,
              style:
              const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(height: 1),
          Flexible(child: child),
        ],
      ),
    );
  }

  // ── CRUD operations ──────────────────────────────────────────────────────

  Future<void> _assignOfficer(Map<String, dynamic> data) async {
    if (_service == null) return;
    setState(() => _isLoading = true);

    try {
      final newAssignment = await _service!.assignOfficer(data);
      if (!mounted) return;
      setState(() {
        _assignedOfficers.insert(0, newAssignment);
        _isLoading = false;
      });
      _showSnackBar('✓ Officer assigned successfully', Colors.green);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showSnackBar('✗ Error: ${e.toString()}', Colors.red);
    }
  }

  Future<void> _updateAssignedOfficer(
      int id, Map<String, dynamic> data) async {
    if (_service == null) return;
    setState(() => _isLoading = true);

    try {
      final updated = await _service!.updateAssignedOfficer(id, data);
      if (!mounted) return;
      setState(() {
        final index = _assignedOfficers.indexWhere((o) => o.id == id);
        if (index != -1) _assignedOfficers[index] = updated;
        _isLoading = false;
      });
      _showSnackBar('✓ Officer assignment updated', Colors.green);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showSnackBar('✗ Error: ${e.toString()}', Colors.red);
    }
  }

  void _showDeleteDialog(AssignedOfficer officer) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Confirm Unassign'),
        content: Text(
          'Are you sure you want to unassign ${officer.name} from ${officer.areaLead}?',
        ),
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
    if (_service == null) return;
    setState(() => _isLoading = true);

    try {
      await _service!.deleteAssignedOfficer(id);
      if (!mounted) return;
      setState(() {
        _assignedOfficers.removeWhere((o) => o.id == id);
        _isLoading = false;
      });
      _showSnackBar('✓ $name unassigned successfully', Colors.green);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showSnackBar('✗ Error: ${e.toString()}', Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assigned Officers',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => _showAssignDialog(),
            tooltip: 'Assign Officer',
            iconSize: 28,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _buildErrorWidget()
          : _assignedOfficers.isEmpty
          ? _buildEmptyWidget()
          : RefreshIndicator(
        onRefresh: _loadAssignedOfficers,
        color: Colors.green,
        child: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: _assignedOfficers.length,
          itemBuilder: (context, index) {
            final officer = _assignedOfficers[index];
            return _buildOfficerCard(officer, index);
          },
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: Colors.red.shade300),
          const SizedBox(height: 16),
          Text(_error!,
              style: const TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadAssignedOfficers,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_off, size: 100, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text('No Officers Assigned',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Click the + button to assign an officer',
              style: TextStyle(color: Colors.grey.shade500)),
        ],
      ),
    );
  }

  Widget _buildOfficerCard(AssignedOfficer officer, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: index % 2 == 0
              ? null
              : LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.green.shade50, Colors.white],
          ),
        ),
        child: ExpansionTile(
          leading: CircleAvatar(
            backgroundColor: Colors.green.shade100,
            radius: 25,
            child: Text(
              officer.name.isNotEmpty ? officer.name[0].toUpperCase() : '?',
              style: TextStyle(
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.bold,
                  fontSize: 18),
            ),
          ),
          title: Text(officer.name,
              style:
              const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(officer.areaLead,
                  style: TextStyle(
                      color: Colors.green.shade700, fontSize: 13)),
              const SizedBox(height: 2),
              Text('${officer.thana}, ${officer.district}',
                  style: TextStyle(
                      color: Colors.grey.shade600, fontSize: 11)),
            ],
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
                      value: officer.email),
                  const Divider(height: 1),
                  _InfoRow(
                      icon: Icons.location_city,
                      label: 'District',
                      value: officer.district),
                  const Divider(height: 1),
                  _InfoRow(
                      icon: Icons.location_on,
                      label: 'Thana',
                      value: officer.thana),
                  const Divider(height: 1),
                  _InfoRow(
                      icon: Icons.list_alt,
                      label: 'Area Lead',
                      value: officer.areaLead),
                  if (officer.createdAt != null) ...[
                    const Divider(height: 1),
                    _InfoRow(
                        icon: Icons.calendar_today,
                        label: 'Assigned',
                        value: _formatDate(officer.createdAt!)),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              _showAssignDialog(officer: officer),
                          icon: const Icon(Icons.edit, size: 18),
                          label: const Text('Edit'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding:
                            const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
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
                            padding:
                            const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
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

  const _InfoRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Row(
              children: [
                Icon(icon, size: 18, color: Colors.green.shade600),
                const SizedBox(width: 8),
                Text(label,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700)),
              ],
            ),
          ),
          Expanded(
              child: Text(value,
                  style: const TextStyle(
                      fontSize: 14, color: Colors.black87))),
        ],
      ),
    );
  }
}