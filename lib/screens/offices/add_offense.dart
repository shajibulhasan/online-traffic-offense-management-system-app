import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/officer_service.dart';
import '../model/driver_model.dart';
import '../model/offense_model.dart';

class AddOffenseScreen extends StatefulWidget {
  final String token;
  final String officerName;
  final int officerId;
  final String officerThana;

  const AddOffenseScreen({
    super.key,
    required this.token,
    required this.officerName,
    required this.officerId,
    required this.officerThana,
  });

  @override
  State<AddOffenseScreen> createState() => _AddOffenseScreenState();
}

class _AddOffenseScreenState extends State<AddOffenseScreen> {
  // Controllers
  late TextEditingController _searchController;
  late TextEditingController _offenseDetailsController;

  // Variables
  String _selectedSearchType = '';
  bool _isSearching = false;
  bool _isSubmitting = false;
  DriverModel? _selectedDriver;
  String? _searchError;

  // Officer data with persistence
  late String _officerName;
  late String _officerId;
  late String _officerThana;

  // Offense data
  String _selectedOffenseType = '';
  int _fineAmount = 0;
  int _pointAmount = 0;

  // Offense types with fine and point
  final Map<String, Map<String, int>> _offenseData = {
    "Speeding": {"fine": 500, "point": 5},
    "Illegal Parking": {"fine": 400, "point": 4},
    "Running Red Light": {"fine": 300, "point": 3},
    "Reckless Driving": {"fine": 500, "point": 5},
    "Driving Under Influence": {"fine": 400, "point": 4},
    "Using Mobile While Driving": {"fine": 600, "point": 6},
    "Not Wearing Seatbelt": {"fine": 500, "point": 5},
    "Overloading": {"fine": 400, "point": 4},
    "Without License": {"fine": 700, "point": 7},
    "License Expired": {"fine": 300, "point": 3},
    "Without Helmet": {"fine": 400, "point": 4},
    "Other": {"fine": 500, "point": 5},
  };

  final List<String> _searchTypes = ['Phone', 'Email', 'License', 'NID'];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _offenseDetailsController = TextEditingController();

    // Initialize with widget values
    _officerName = widget.officerName;
    _officerId = widget.officerId.toString();
    _officerThana = widget.officerThana;

    // Save to SharedPreferences for persistence
    _saveOfficerData();

    // Load from SharedPreferences (in case of refresh)
    _loadOfficerData();
  }

  // Save officer data to SharedPreferences
  Future<void> _saveOfficerData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('officer_name', _officerName);
      await prefs.setString('officer_id', _officerId);
      await prefs.setString('officer_thana', _officerThana);
      print('Officer data saved: $_officerName, $_officerThana');
    } catch (e) {
      print('Error saving officer data: $e');
    }
  }

  // Load officer data from SharedPreferences
  Future<void> _loadOfficerData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _officerName = prefs.getString('officer_name') ?? widget.officerName;
        _officerId = prefs.getString('officer_id') ?? widget.officerId.toString();
        _officerThana = prefs.getString('officer_thana') ?? widget.officerThana;
      });
      print('Officer data loaded: $_officerName, $_officerThana');
    } catch (e) {
      print('Error loading officer data: $e');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _offenseDetailsController.dispose();
    super.dispose();
  }

  // Search Driver
  Future<void> _searchDriver() async {
    if (_selectedSearchType.isEmpty || _searchController.text.isEmpty) {
      setState(() {
        _searchError = 'Please select search type and enter value';
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _searchError = null;
    });

    try {
      OfficerService service = OfficerService(token: widget.token);

      String type = _selectedSearchType.toLowerCase();
      String value = _searchController.text.trim();

      print('Searching driver with type: $type, value: $value');

      DriverModel? driver = await service.searchDriver(
        type: type,
        value: value,
      );

      if (driver != null) {
        setState(() {
          _selectedDriver = driver;
          _searchError = null;
          _searchController.clear();
          _selectedSearchType = '';
        });

        _showSnackBar('Driver found: ${driver.name}', Colors.green);

        print('Driver details:');
        print('ID: ${driver.id}');
        print('Name: ${driver.name}');
        print('Email: ${driver.email}'); // This should now show
        print('Phone: ${driver.phone}');
      } else {
        setState(() {
          _selectedDriver = null;
          _searchError = 'Driver not found';
        });
      }
    } catch (e) {
      print('Search error caught in UI: $e');
      setState(() {
        _searchError = e.toString().replaceAll('Exception:', '').trim();
      });
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  // Clear selected driver
  void _clearSelectedDriver() {
    setState(() {
      _selectedDriver = null;
      _selectedOffenseType = '';
      _fineAmount = 0;
      _pointAmount = 0;
      _offenseDetailsController.clear();
    });
  }

  // Update fine and point based on offense type
  void _updateOffenseValues(String offenseType) {
    if (offenseType.isNotEmpty && _offenseData.containsKey(offenseType)) {
      setState(() {
        _fineAmount = _offenseData[offenseType]!['fine']!;
        _pointAmount = _offenseData[offenseType]!['point']!;
      });
    } else {
      setState(() {
        _fineAmount = 0;
        _pointAmount = 0;
      });
    }
  }

  // Submit offense
  // Submit offense
  Future<void> _submitOffense() async {
    // Validation
    if (_selectedDriver == null) {
      _showSnackBar('Please search and select a driver first', Colors.red);
      return;
    }

    if (_selectedOffenseType.isEmpty) {
      _showSnackBar('Please select offense type', Colors.red);
      return;
    }

    if (_offenseDetailsController.text.isEmpty) {
      _showSnackBar('Please enter offense details', Colors.red);
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Save driver info locally before API call
      final currentDriver = _selectedDriver;

      print('Submitting offense for driver: ${currentDriver?.name} (ID: ${currentDriver?.id})');

      OffenseModel offense = OffenseModel(
        offenseType: _selectedOffenseType,
        detailsOffense: _offenseDetailsController.text.trim(),
        fine: _fineAmount,
        point: _pointAmount,
        driverId: currentDriver!.id,
        thana: _officerThana,
        officerName: _officerName,
        officerId: int.parse(_officerId),
      );

      OfficerService service = OfficerService(token: widget.token);
      OffenseModel added = await service.addOffense(offense);

      // প্রথমে সাকসেস ডায়ালগ দেখান (currentDriver ব্যবহার করে)
      _showSuccessDialog(added, currentDriver);

      // তারপর ফর্ম ক্লিয়ার করুন
      _clearSelectedDriver();
      _selectedOffenseType = '';
      _offenseDetailsController.clear();

      setState(() {
        _fineAmount = 0;
        _pointAmount = 0;
      });

    } catch (e) {
      print('Error submitting offense: $e');
      _showSnackBar('Error: ${e.toString()}', Colors.red);
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessDialog(OffenseModel offense, DriverModel driver) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Success'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Offense added successfully!'),
            const SizedBox(height: 10),
            Text('Driver: ${driver.name}'),  // সরাসরি driver parameter ব্যবহার করুন
            Text('Email: ${driver.email.isEmpty ? "Not provided" : driver.email}'),
            const SizedBox(height: 5),
            Text('Offense: ${offense.offenseType}'),
            Text('Fine: ৳${offense.fine}'),
            Text('Point: ${offense.point}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Offense'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Officer Info Card - Using persisted values
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green.shade400, Colors.green.shade700],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.person, color: Colors.white),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Officer: $_officerName',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.white),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Thana: $_officerThana',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Search Driver Section
            const Text(
              'Search Driver *',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedSearchType.isEmpty ? null : _selectedSearchType,
                        hint: const Text('Select Type'),
                        isExpanded: true,
                        items: _searchTypes.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedSearchType = value ?? '';
                          });
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Search Input
                Expanded(
                  flex: 5,
                  child: TextField(
                    controller: _searchController,
                    enabled: _selectedSearchType.isNotEmpty,
                    decoration: InputDecoration(
                      hintText: _selectedSearchType.isEmpty
                          ? 'Select type first'
                          : 'Enter ${_selectedSearchType.toLowerCase()}...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Search Button
                ElevatedButton(
                  onPressed: (_selectedSearchType.isNotEmpty &&
                      _searchController.text.isNotEmpty &&
                      !_isSearching)
                      ? _searchDriver
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isSearching
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : const Icon(Icons.search),
                ),
              ],
            ),

            // Search Error
            if (_searchError != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _searchError!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),

            const SizedBox(height: 16),

            // Selected Driver Info
            if (_selectedDriver != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  border: Border.all(color: Colors.green),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Selected Driver:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: _clearSelectedDriver,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Name: ${_selectedDriver!.name}'),
                    Text('Email: ${_selectedDriver!.email}'), // This will now show
                    if (_selectedDriver!.phone != null && _selectedDriver!.phone!.isNotEmpty)
                      Text('Phone: ${_selectedDriver!.phone}'),
                    if (_selectedDriver!.nid != null && _selectedDriver!.nid!.isNotEmpty)
                      Text('NID: ${_selectedDriver!.nid}'),
                    if (_selectedDriver!.license != null && _selectedDriver!.license!.isNotEmpty)
                      Text('License: ${_selectedDriver!.license}'),
                  ],
                ),
              ),

            const SizedBox(height: 20),

            if (_selectedDriver != null) ...[
              const Divider(thickness: 1),
              const SizedBox(height: 10),

              // Offense Type
              const Text(
                'Offense Type *',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedOffenseType.isEmpty ? null : _selectedOffenseType,
                    hint: const Text('Select Offense Type'),
                    isExpanded: true,
                    items: _offenseData.keys.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedOffenseType = value ?? '';
                        _updateOffenseValues(_selectedOffenseType);
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Offense Details
              const Text(
                'Detailed Offense *',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _offenseDetailsController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Enter detailed offense description...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Fine Amount
              const Text(
                'Fine *',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: TextEditingController(text: _fineAmount.toString()),
                readOnly: true,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.attach_money),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                ),
              ),

              const SizedBox(height: 16),

              // Point
              const Text(
                'Point *',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: TextEditingController(text: _pointAmount.toString()),
                readOnly: true,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.stars),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                ),
              ),

              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submitOffense,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: _isSubmitting
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : const Icon(Icons.add),
                  label: Text(
                    _isSubmitting ? 'Adding...' : 'Add Offense',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}