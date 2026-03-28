import 'package:flutter/material.dart';
import 'package:online_traffic_offense_management_system/services/auth_service.dart';
import '../../services/area_service.dart';
import '../model/area.dart';

class AreaListScreen extends StatefulWidget {
  const AreaListScreen({super.key});

  @override
  State<AreaListScreen> createState() => _AreaListScreenState();
}

class _AreaListScreenState extends State<AreaListScreen> {
  late AreaService _areaService;
  List<Area> _areas = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeServiceAndLoadData();
  }

  Future<void> _initializeServiceAndLoadData() async {
    final token = await AuthService.getToken();
    _areaService = AreaService(token: token ?? '');
    await _loadAreas();
  }

  Future<void> _loadAreas() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final areas = await _areaService.getAllAreas();
      setState(() {
        _areas = areas;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _showAddAreaDialog() {
    final districts = _areaService.getAllDistricts();
    String? selectedDistrict;
    String? selectedThana;
    List<Map<String, dynamic>> thanas = [];
    bool isLoadingThanas = false;

    final areaNameController = TextEditingController();
    final detailsAreaController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Add New Area'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
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
                      items: districts.map((district) {
                        return DropdownMenuItem(
                          value: district,
                          child: Text(district),
                        );
                      }).toList(),
                      onChanged: (value) async {
                        // Set loading state
                        setDialogState(() {
                          selectedDistrict = value;
                          selectedThana = null;
                          isLoadingThanas = true;
                          thanas = [];
                        });

                        // Fetch thanas for selected district
                        final fetchedThanas = await _areaService.getThanasByDistrict(value!);

                        // Update with fetched data
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
                        return thanas.map((thana) {
                          return DropdownMenuItem<String>(
                            value: thana['thana_name'],
                            child: Text(thana['thana_name']),
                          );
                        }).toList();
                      }(),
                      onChanged: (selectedDistrict != null && !isLoadingThanas && thanas.isNotEmpty)
                          ? (value) {
                        setDialogState(() {
                          selectedThana = value;
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

                  // Area Name
                  TextField(
                    controller: areaNameController,
                    decoration: const InputDecoration(
                      labelText: 'Area Name *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.house),
                      hintText: 'Enter area name',
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Details Area
                  TextField(
                    controller: detailsAreaController,
                    decoration: const InputDecoration(
                      labelText: 'Detailed Area *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.description),
                      hintText: 'Enter detailed area description',
                    ),
                    maxLines: 3,
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
                  if (selectedDistrict == null) {
                    _showSnackBar('Please select district', Colors.orange);
                    return;
                  }
                  if (selectedThana == null) {
                    _showSnackBar('Please select thana', Colors.orange);
                    return;
                  }
                  final areaName = areaNameController.text.trim();
                  if (areaName.isEmpty) {
                    _showSnackBar('Please enter area name', Colors.orange);
                    return;
                  }
                  final detailsArea = detailsAreaController.text.trim();
                  if (detailsArea.isEmpty) {
                    _showSnackBar('Please enter detailed area', Colors.orange);
                    return;
                  }

                  Navigator.pop(context);

                  final areaData = {
                    'district': selectedDistrict,
                    'thana_name': selectedThana,
                    'area_name': areaName,
                    'details_area': detailsArea,
                  };

                  await _addArea(areaData);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: const Text('Add Area'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showEditAreaDialog(Area area) {
    final districts = _areaService.getAllDistricts();
    String? selectedDistrict = area.district;
    String? selectedThana = area.thanaName;
    List<Map<String, dynamic>> thanas = [];
    bool isLoadingThanas = false;
    bool isInitialLoad = true;

    final areaNameController = TextEditingController(text: area.areaName);
    final detailsAreaController = TextEditingController(text: area.detailsArea);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        // Create a StatefulBuilder that will handle the dialog state
        return StatefulBuilder(
          builder: (context, setDialogState) {
            // Load thanas on first build
            if (isInitialLoad && selectedDistrict != null) {
              isInitialLoad = false;
              // Use Future.microtask to load after build
              Future.microtask(() async {
                setDialogState(() {
                  isLoadingThanas = true;
                });
                final fetchedThanas = await _areaService.getThanasByDistrict(selectedDistrict!);
                setDialogState(() {
                  thanas = fetchedThanas;
                  isLoadingThanas = false;
                });
              });
            }

            return AlertDialog(
              title: const Text('Edit Area'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
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
                        items: districts.map((district) {
                          return DropdownMenuItem(
                            value: district,
                            child: Text(district),
                          );
                        }).toList(),
                        onChanged: (value) async {
                          setDialogState(() {
                            selectedDistrict = value;
                            selectedThana = null;
                            isLoadingThanas = true;
                            thanas = [];
                          });

                          final fetchedThanas = await _areaService.getThanasByDistrict(value!);

                          setDialogState(() {
                            thanas = fetchedThanas;
                            isLoadingThanas = false;
                          });
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
                          return thanas.map((thana) {
                            return DropdownMenuItem<String>(
                              value: thana['thana_name'],
                              child: Text(thana['thana_name']),
                            );
                          }).toList();
                        }(),
                        onChanged: (!isLoadingThanas && selectedDistrict != null)
                            ? (value) {
                          setDialogState(() {
                            selectedThana = value;
                          });
                        }
                            : null,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Area Name
                    TextField(
                      controller: areaNameController,
                      decoration: const InputDecoration(
                        labelText: 'Area Name *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.house),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Details Area
                    TextField(
                      controller: detailsAreaController,
                      decoration: const InputDecoration(
                        labelText: 'Detailed Area *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                      ),
                      maxLines: 3,
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
                    if (selectedDistrict == null) {
                      _showSnackBar('Please select district', Colors.orange);
                      return;
                    }
                    if (selectedThana == null) {
                      _showSnackBar('Please select thana', Colors.orange);
                      return;
                    }
                    final areaName = areaNameController.text.trim();
                    if (areaName.isEmpty) {
                      _showSnackBar('Please enter area name', Colors.orange);
                      return;
                    }
                    final detailsArea = detailsAreaController.text.trim();
                    if (detailsArea.isEmpty) {
                      _showSnackBar('Please enter detailed area', Colors.orange);
                      return;
                    }

                    Navigator.pop(context);

                    final areaData = {
                      'district': selectedDistrict,
                      'thana_name': selectedThana,
                      'area_name': areaName,
                      'details_area': detailsArea,
                    };

                    await _updateArea(area.id, areaData);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text('Update'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _addArea(Map<String, dynamic> areaData) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final newArea = await _areaService.createArea(areaData);
      setState(() {
        _areas.insert(0, newArea);
        _isLoading = false;
      });
      _showSnackBar('Area added successfully', Colors.green);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showSnackBar('Error: ${e.toString()}', Colors.red);
    }
  }

  Future<void> _updateArea(int id, Map<String, dynamic> areaData) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final updatedArea = await _areaService.updateArea(id, areaData);
      setState(() {
        final index = _areas.indexWhere((a) => a.id == id);
        if (index != -1) {
          _areas[index] = updatedArea;
        }
        _isLoading = false;
      });
      _showSnackBar('Area updated successfully', Colors.green);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showSnackBar('Error: ${e.toString()}', Colors.red);
    }
  }

  void _showDeleteDialog(Area area) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete area "${area.areaName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteArea(area.id, area.areaName);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteArea(int id, String areaName) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _areaService.deleteArea(id);
      setState(() {
        _areas.removeWhere((a) => a.id == id);
        _isLoading = false;
      });
      _showSnackBar('$areaName deleted successfully', Colors.green);
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
        title: const Text('Area List'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddAreaDialog,
            tooltip: 'Add Area',
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
              onPressed: _loadAreas,
              child: const Text('Retry'),
            ),
          ],
        ),
      )
          : _areas.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text(
              'No Area Found',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              'Click the + button to add a new area',
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: _loadAreas,
        child: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: _areas.length,
          itemBuilder: (context, index) {
            final area = _areas[index];
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
                    area.areaName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    '${area.thanaName}, ${area.district}',
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
                            icon: Icons.location_city,
                            label: 'District',
                            value: area.district,
                          ),
                          const Divider(),
                          _InfoRow(
                            icon: Icons.location_on,
                            label: 'Thana',
                            value: area.thanaName,
                          ),
                          const Divider(),
                          _InfoRow(
                            icon: Icons.description,
                            label: 'Details',
                            value: area.detailsArea,
                          ),
                          if (area.createdAt != null) ...[
                            const Divider(),
                            _InfoRow(
                              icon: Icons.calendar_today,
                              label: 'Created',
                              value: _formatDate(area.createdAt!),
                            ),
                          ],
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _showEditAreaDialog(area),
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
                                  onPressed: () => _showDeleteDialog(area),
                                  icon: const Icon(Icons.delete, size: 18),
                                  label: const Text('Delete'),
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