import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:online_traffic_offense_management_system/screens/admin/thana_list_screen.dart';
import 'package:online_traffic_offense_management_system/screens/admin/verify_officers_screen.dart';
import 'dart:convert';
import '../../services/auth_service.dart';
import '../../urls/urls.dart';
import '../drivers/driver_profile.dart';
import '../login_screen.dart';
import 'admin_home_screen.dart';
import 'area_list_screen.dart';
import 'assigned_officers_screen.dart';
import 'package:fl_chart/fl_chart.dart';

class AdminDashboardScreen extends StatefulWidget {
  final String userName;
  final String email;
  final String role;
  final int id;

  const AdminDashboardScreen({
    super.key,
    required this.userName,
    required this.email,
    required this.role,
    required this.id,
  });

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int currentIndex = 0;
  String? token;

  // Offense counts
  int totalOffenseCount = 0;
  int todayOffenseCount = 0;
  int userOffenseCount = 0;
  int unpaidOffenseCount = 0;

  bool isLoading = true;
  String? errorMessage;

  final List<String> pages = [
    "Home",
    "Verify Officers",
    "Thana List",
    "Area List",
    "Assigned Officers",
    "Profile",
  ];

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  Future<void> initializeData() async {
    await loadToken();
    await fetchOffenseCounts();
  }

  Future<void> loadToken() async {
    try {
      final t = await AuthService.getToken();
      if (mounted) {
        setState(() {
          token = t;
        });
        print('Token loaded: ${token != null ? "Present" : "Missing"}');
      }
    } catch (e) {
      print('Error loading token: $e');
      if (mounted) {
        setState(() {
          errorMessage = 'Failed to load authentication token';
          isLoading = false;
        });
      }
    }
  }

  Future<void> fetchOffenseCounts() async {
    if (token == null) {
      print('Token is null, cannot fetch data');
      if (mounted) {
        setState(() {
          errorMessage = 'Authentication token not available';
          isLoading = false;
        });
      }
      return;
    }

    try {
      final url = widget.role == 'user'
          ? Uri.parse("${Urls.baseUrl}/user/offenses/counts")
          : Uri.parse("${Urls.baseUrl}/admin/offenses/counts");

      print('Fetching from URL: $url');
      print('Using token: $token');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        // Extract data from response
        Map<String, dynamic> data = {};

        if (responseData.containsKey('data')) {
          data = responseData['data'];
        } else {
          data = responseData;
        }

        print('Parsed data: $data');

        if (mounted) {
          setState(() {
            // Handle different key names (total_offense vs total_offenses)
            if (widget.role == 'user') {
              userOffenseCount = data['total_offense'] ?? data['total_offenses'] ?? 0;
              unpaidOffenseCount = data['unpaid_offense'] ?? data['unpaid_offenses'] ?? 0;
              todayOffenseCount = data['today_offense'] ?? data['today_offenses'] ?? 0;
              totalOffenseCount = data['all_total_offense'] ?? data['all_total_offenses'] ??
                  data['total_offense'] ?? data['total_offenses'] ?? 0;
            } else {
              // For admin role - handle both singular and plural keys
              totalOffenseCount = data['total_offense'] ?? data['total_offenses'] ?? 0;
              todayOffenseCount = data['today_offense'] ?? data['today_offenses'] ?? 0;
              userOffenseCount = data['user_offense'] ?? data['user_offenses'] ?? 0;
              unpaidOffenseCount = data['unpaid_offense'] ?? data['unpaid_offenses'] ?? 0;
            }

            print('Parsed values - totalOffenseCount: $totalOffenseCount, todayOffenseCount: $todayOffenseCount');
            print('userOffenseCount: $userOffenseCount, unpaidOffenseCount: $unpaidOffenseCount');

            isLoading = false;
            errorMessage = null;
          });
        }
      } else if (response.statusCode == 401) {
        print('Authentication failed, redirecting to login...');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Session expired. Please login again.'),
              backgroundColor: Colors.red,
            ),
          );
          await AuthService.logout();
          if (mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
            );
          }
        }
      } else {
        if (mounted) {
          setState(() {
            errorMessage = 'Failed to load data. Please try again.';
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error fetching offense counts: $e');
      if (mounted) {
        setState(() {
          errorMessage = 'Network error. Please check your connection.';
          isLoading = false;
        });
      }
    }
  }

  Future<void> refreshData() async {
    if (mounted) {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });
    }
    await fetchOffenseCounts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          pages[currentIndex],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(
                widget.userName,
                style: const TextStyle(fontSize: 18),
              ),
              accountEmail: Text(widget.email),
              currentAccountPicture: CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white,
                child: Text(
                  widget.userName.isNotEmpty ? widget.userName[0].toUpperCase() : 'U',
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green),
                ),
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green, Colors.lightGreen],
                ),
              ),
            ),
            _drawerItem(Icons.home, "Home", 0),
            _drawerItem(Icons.verified_user, "Verify Officers", 1),
            _drawerItem(Icons.location_city, "Thana List", 2),
            _drawerItem(Icons.map, "Area List", 3),
            _drawerItem(Icons.assignment_ind, "Assigned Officers", 4),
            _drawerItem(Icons.person, "Profile", 5),
            const Spacer(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Logout", style: TextStyle(color: Colors.red)),
              onTap: logout,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      body: getPage(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          if (mounted) {
            setState(() => currentIndex = index);
          }
        },
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.verified_user), label: "Verify Officers"),
          BottomNavigationBarItem(icon: Icon(Icons.location_city), label: "Thana List"),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: "Area List"),
          BottomNavigationBarItem(icon: Icon(Icons.assignment_ind), label: "Assigned Officers"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, int index) {
    return ListTile(
      leading: Icon(icon, color: currentIndex == index ? Colors.green : Colors.grey),
      title: Text(
        title,
        style: TextStyle(
          color: currentIndex == index ? Colors.green : Colors.black87,
          fontWeight: currentIndex == index ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: currentIndex == index,
      onTap: () {
        if (mounted) {
          setState(() => currentIndex = index);
          Navigator.pop(context);
        }
      },
    );
  }

  Widget getPage() {
    switch (currentIndex) {
      case 0:
        return homePage();
      case 1:
        return const VerifyOfficersScreen();
      case 2:
        return const ThanaListScreen();
      case 3:
        return const AreaListScreen();
      case 4:
        return const AssignedOfficersScreen();
      case 5:
        if (token == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return DriverProfileScreen(token: token!);
      default:
        return homePage();
    }
  }

  Widget homePage() {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            ),
            SizedBox(height: 16),
            Text(
              'Loading dashboard...',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              errorMessage!,
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: refreshData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final bool isAdmin = widget.role != 'user';

    // For admin role, show total and today's offenses
    final int displayCount1 = totalOffenseCount;
    final int displayCount2 = todayOffenseCount;
    final String label1 = 'Total Offenses';
    final String label2 = "Today's Offenses";
    final Color color1 = Colors.blue;
    final Color color2 = Colors.orange;

    // Calculate percentage for insight
    final double percentage = displayCount1 > 0
        ? (displayCount2 / displayCount1) * 100
        : 0;
    final bool isAboveAverage = displayCount2 > (displayCount1 / 30);
    final String trendMessage = isAboveAverage
        ? 'Above average'
        : 'Below average';
    final IconData trendIcon = isAboveAverage
        ? Icons.trending_up
        : Icons.trending_down;
    final Color trendColor = isAboveAverage ? Colors.red : Colors.green;

    // Debug print to verify data
    print('Display Data - Count1: $displayCount1, Count2: $displayCount2');
    print('Labels - $label1, $label2');

    return RefreshIndicator(
      onRefresh: refreshData,
      color: Colors.green,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(widget.userName, widget.role),
            const SizedBox(height: 20),
            _buildStatsGrid(label1, label2, displayCount1, displayCount2, color1, color2),
            const SizedBox(height: 20),
            _buildChartSection(
              label1, label2, displayCount1, displayCount2,
              color1, color2, percentage, trendMessage, trendIcon, trendColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String userName, String userRole) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.green, Colors.lightGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 25,
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Colors.green, size: 30),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Welcome Back,",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      userName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.white, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      _getFormattedDate(),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              userRole.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(String label1, String label2, int count1, int count2, Color color1, Color color2) {
    return Row(
      children: [
        Expanded(child: _buildStatCard(label1, count1, Icons.gavel, color1, 'Total records')),
        const SizedBox(width: 15),
        Expanded(child: _buildStatCard(label2, count2, Icons.today, color2, 'Today\'s records')),
      ],
    );
  }

  Widget _buildStatCard(String label, int count, IconData icon, Color color, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _formatNumber(count),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection(
      String label1, String label2, int count1, int count2,
      Color color1, Color color2, double percentage,
      String trendMessage, IconData trendIcon, Color trendColor,
      ) {
    final double maxY = (max(count1, count2) * 1.2).toDouble();

    // If no data, show empty state
    if (count1 == 0 && count2 == 0) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Center(
          child: Column(
            children: [
              Icon(Icons.bar_chart, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No offense data available',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.bar_chart, color: Colors.green, size: 24),
              SizedBox(width: 8),
              Text(
                'Offense Analytics',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 280,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY > 0 ? maxY : 10,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${rod.toY.toInt()} offenses',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        switch (value.toInt()) {
                          case 0:
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(label1, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
                            );
                          case 1:
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(label2, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
                            );
                          default:
                            return const Text('');
                        }
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 45,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          _formatNumber(value.toInt()),
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY > 0 ? maxY / 5 : 2,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.shade200,
                      strokeWidth: 1,
                      dashArray: [5, 5],
                    );
                  },
                ),
                borderData: FlBorderData(show: false),
                barGroups: [
                  BarChartGroupData(
                    x: 0,
                    barRods: [
                      BarChartRodData(
                        toY: count1.toDouble(),
                        color: color1,
                        width: 50,
                        borderRadius: BorderRadius.circular(8),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: maxY,
                          color: color1.withOpacity(0.1),
                        ),
                      ),
                    ],
                    showingTooltipIndicators: [],
                  ),
                  BarChartGroupData(
                    x: 1,
                    barRods: [
                      BarChartRodData(
                        toY: count2.toDouble(),
                        color: color2,
                        width: 50,
                        borderRadius: BorderRadius.circular(8),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: maxY,
                          color: color2.withOpacity(0.1),
                        ),
                      ),
                    ],
                    showingTooltipIndicators: [],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Divider(color: Colors.grey.shade200),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Today's Ratio",
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${percentage.toStringAsFixed(1)}%",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: trendColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Trend Analysis',
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(trendIcon, color: trendColor, size: 16),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              trendMessage,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: trendColor,
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
              const SizedBox(width: 12),
              InkWell(
                onTap: refreshData,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.refresh, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    }
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    return '${_getMonth(now.month)} ${now.day}, ${now.year}';
  }

  String _getMonth(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  Future<void> logout() async {
    await AuthService.logout();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
      );
    }
  }
}