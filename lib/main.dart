import 'package:edith/auth_services.dart';
import 'package:edith/components/yourVideos.dart';
import 'package:edith/firebase_options.dart';
import 'package:edith/trendingPage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'getStarted.dart';
import 'login.dart';
import 'signIn.dart';
import 'studyTracks.dart';
import 'subjectPage.dart';
import 'components/edithCard.dart';
import 'package:fl_chart/fl_chart.dart';

// Global variable to store the username
String? globalUsername;

void main() async {
  // Ensure Flutter bindings are initialized before running the app
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase with the current platform's options
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  // Run the Flutter app
  runApp(MyApp());
}

// Main application widget
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Define the initial route for the app
      initialRoute: '/getstarted',
      
      // Define named routes for navigation
      routes: {
        '/getstarted': (context) => getStarted(),
        '/login': (context) => const Login(),
        '/signin': (context) => const SignIn(),
        '/main': (context) => const MainScreen(username: "User"),
        '/studytracks': (context) => studyTracks(),
        '/subjectpage': (context) => const subjectPage(sub: ""),
      },
      
      // Disable the debug banner in the top-right corner
      debugShowCheckedModeBanner: false,
    );
  }
}

// Main screen widget that displays after login
class MainScreen extends StatefulWidget {
  final String username;
  
  const MainScreen({super.key, required this.username});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0; // Tracks the selected index of the bottom navigation bar

  @override
  void initState() {
    super.initState();
    
    // Set the global username when the widget initializes
    globalUsername = widget.username;
  }

  // Builds the appropriate page based on the selected index
  Widget _buildPage(int index) {
    switch (index) {
      case 1:
        return _buildTrendingPage(); // Trending page
      case 2:
        return _buildYourVideosPage(); // Your Videos page
      default:
        return _buildHomePage(context); // Home page
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // Prevent back navigation by overriding the back button behavior
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 87, 108, 214),
        
        // App bar with dynamic sizing and a logout popup menu
        appBar: AppBar(
          automaticallyImplyLeading: false,
          toolbarHeight: MediaQuery.of(context).size.height * 0.09, // Dynamic height
          title: LayoutBuilder(
            builder: (context, constraints) {
              return FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  "Hello, ${widget.username}!",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: MediaQuery.of(context).size.width * 0.06, // Dynamic font size
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            },
          ),
          backgroundColor: const Color.fromARGB(255, 87, 108, 214),
          actions: [
            const SizedBox(width: 10),
            
            // Profile image avatar
            CircleAvatar(
              backgroundImage: const AssetImage('assets/images/thala.jpg'),
              radius: MediaQuery.of(context).size.width * 0.05, // Dynamic radius
            ),
            
            // Popup menu for logout functionality
            PopupMenuButton<String>(
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Colors.white,
              ),
              onSelected: (value) async {
                if (value == 'logout') {
                  // Call the signOut method from AuthService
                  await authService.value.signOut();
                  
                  // Navigate to the get started screen after logging out
                  Navigator.pushReplacementNamed(context, '/getstarted');
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem<String>(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: Colors.red),
                      SizedBox(width: MediaQuery.of(context).size.width * 0.02), // Dynamic spacing
                      Text(
                        'Logout',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: MediaQuery.of(context).size.width * 0.04, // Dynamic font size
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(width: 10),
          ],
        ),
        
        // Body content based on the selected index
        body: _buildPage(_selectedIndex),
        
        // Bottom navigation bar for switching between pages
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          backgroundColor: Colors.white,
          selectedItemColor: const Color.fromARGB(255, 87, 108, 214),
          unselectedItemColor: const Color.fromARGB(255, 87, 108, 214).withOpacity(0.5),
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.trending_up), label: "Trending"),
            BottomNavigationBarItem(icon: Icon(Icons.video_library), label: "Your Videos"),
          ],
        ),
      ),
    );
  }

  // Builds the home page with dynamic layout elements
  Widget _buildHomePage(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04), // Dynamic padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: screenWidth * 0.05), // Dynamic spacing
            
            // Welcome card with gradient background
            Container(
              padding: EdgeInsets.all(screenWidth * 0.04), // Dynamic padding
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(screenWidth * 0.05), // Dynamic radius
                gradient: const LinearGradient(
                  colors: [
                    Color.fromARGB(255, 35, 35, 35),
                    Color.fromARGB(255, 169, 165, 170),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Start Your\nLearning\nJourney Now!",
                          style: TextStyle(
                            fontSize: screenWidth * 0.08, // Dynamic font size
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: screenWidth * 0.1), // Dynamic spacing
                        
                        // Button to navigate to study tracks
                        Container(
                          padding: EdgeInsets.symmetric(
                            vertical: screenWidth * 0.02, // Dynamic padding
                            horizontal: screenWidth * 0.005, // Dynamic padding
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(screenWidth * 0.05), // Dynamic radius
                          ),
                          child: TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/studytracks');
                            },
                            child: Row(
                              children: [
                                Text(
                                  "View tracks",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: screenWidth * 0.05, // Dynamic font size
                                  ),
                                ),
                                SizedBox(width: screenWidth * 0.01), // Dynamic spacing
                                Icon(
                                  Icons.arrow_circle_right_outlined,
                                  color: Colors.white,
                                  size: screenWidth * 0.06, // Dynamic icon size
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Image asset for visual appeal
                  Image.asset(
                    'assets/images/success.png',
                    height: screenWidth * 0.4, // Dynamic height
                  ),
                ],
              ),
            ),
            
            SizedBox(height: screenWidth * 0.1), // Dynamic spacing
            
            // Gradient card with motivational text
            GradientCard(
              text: "Use Edith to Create Your Personalized Learning Content!",
            ),
            
            SizedBox(height: screenWidth * 0.08), // Dynamic spacing
            
            // Progress section header
            Text(
              "Your Progress:",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: screenWidth * 0.07, // Dynamic font size
                color: Colors.black,
              ),
            ),
            
            SizedBox(height: screenWidth * 0.05), // Dynamic spacing
            
            // Graph cards for Focus Score, Consistency, and Completion Rate
            _buildGraphCard("Focus Score", "Pie Chart", {
              "Science": 80,
              "Maths": 70,
              "Visual Arts": 60,
              "CS": 90,
              "Financial Literacy": 50,
              "Performance Arts": 75,
            }),
            SizedBox(height: screenWidth * 0.05), // Dynamic spacing
            _buildGraphCard("Consistency", "Bar Graph", {
              "Science": 4,
              "Maths": 3,
              "Visual Arts": 2,
              "CS": 5,
              "Financial Literacy": 1,
              "Performance Arts": 3,
            }),
            SizedBox(height: screenWidth * 0.05), // Dynamic spacing
            _buildGraphCard("Completion Rate", "Line Graph", {
              "Science": 90,
              "Maths": 80,
              "Visual Arts": 70,
              "CS": 95,
              "Financial Literacy": 60,
              "Performance Arts": 75,
            }),
          ],
        ),
      ),
    );
  }

  // Builds a graph card with dynamic layout
  Widget _buildGraphCard(String title, String type, Map<String, dynamic> data) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.05), // Dynamic radius
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(255, 60, 60, 60),
            Color.fromARGB(255, 120, 120, 120),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04), // Dynamic padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.width * 0.05, // Dynamic font size
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.width * 0.02), // Dynamic spacing
          
          // Conditional rendering of pie chart, bar graph, or line graph
          if (type == "Pie Chart") _buildPieChart(data),
          if (type == "Bar Graph") _buildBarGraph(data),
          if (type == "Line Graph") _buildLineGraph(data),
        ],
      ),
    );
  }

  // Builds a pie chart with legend
  Widget _buildPieChart(Map<String, dynamic> data) {
    List<PieChartSectionData> pieSections = [];
    int totalValue = data.values.reduce((a, b) => a + b);
    
    // Build pie chart sections dynamically
    data.forEach((key, value) {
      final percentage = ((value / totalValue) * 100).round(); // Round to integer
      pieSections.add(
        PieChartSectionData(
          color: _getColorFromKey(key),
          value: percentage.toDouble(), // Use rounded percentage
          title: '$percentage%', // Display as integer
          radius: MediaQuery.of(context).size.width * 0.2, // Dynamic radius
          titleStyle: TextStyle(
            fontSize: MediaQuery.of(context).size.width * 0.03, // Dynamic font size
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    });
    
    return Column(
      children: [
        // Pie Chart
        AspectRatio(
          aspectRatio: 1, // Maintain square aspect ratio
          child: PieChart(
            PieChartData(
              sections: pieSections,
              centerSpaceRadius: MediaQuery.of(context).size.width * 0.15, // Dynamic center space
            ),
          ),
        ),
        
        // Legend for the pie chart
        Padding(
          padding: EdgeInsets.only(top: MediaQuery.of(context).size.width * 0.02), // Dynamic spacing
          child: Wrap(
            spacing: MediaQuery.of(context).size.width * 0.02, // Dynamic spacing
            runSpacing: MediaQuery.of(context).size.width * 0.01, // Dynamic spacing
            children: data.entries.map((entry) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.03, // Dynamic size
                    height: MediaQuery.of(context).size.width * 0.03, // Dynamic size
                    decoration: BoxDecoration(
                      color: _getColorFromKey(entry.key), // Color of the subject
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.01), // Dynamic spacing
                  Text(
                    entry.key, // Subject name
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.03, // Dynamic font size
                      color: Colors.black,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // Builds a bar graph with dynamic layout
  Widget _buildBarGraph(Map<String, dynamic> data) {
    List<BarChartGroupData> barGroups = [];
    data.entries.toList().asMap().forEach((index, entry) {
      barGroups.add(
        BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: entry.value.toDouble(),
              color: _getColorFromKey(entry.key),
              width: MediaQuery.of(context).size.width * 0.05, // Dynamic width
            ),
          ],
        ),
      );
    });
    
    return AspectRatio(
      aspectRatio: 1.5,
      child: BarChart(
        BarChartData(
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final key = data.keys.elementAt(value.toInt());
                  return Transform.rotate(
                    angle: -0.5, // Rotate text by -30 degrees
                    child: Text(
                      _truncateText(key), // Truncate long text
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.02, // Dynamic font size
                        color: Colors.white,
                      ), // Smaller font size
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: barGroups,
        ),
      ),
    );
  }

  // Helper function to truncate long text
  String _truncateText(String text) {
    if (text.length > 8) {
      return '${text.substring(0, 6)}...'; // Truncate to 6 characters and add "..."
    }
    return text;
  }

  // Builds a line graph with dynamic layout
  Widget _buildLineGraph(Map<String, dynamic> data) {
    List<FlSpot> spots = [];
    data.entries.toList().asMap().forEach((index, entry) {
      spots.add(FlSpot(index.toDouble(), entry.value.toDouble()));
    });
    
    return AspectRatio(
      aspectRatio: 1.5,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  // Ensure value is an integer and within bounds
                  if (value % 1 == 0 && value >= 0 && value < data.length) {
                    final key = data.keys.elementAt(value.toInt());
                    return Transform.rotate(
                      angle: -0.5, // Rotate text by -30 degrees
                      child: Text(
                        _truncateText(key), // Truncate long text
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width * 0.02, // Dynamic font size
                          color: Colors.white,
                        ), // Smaller font size
                      ),
                    );
                  }
                  return Container(); // Return an empty container for non-integer values
                },
              ),
            ),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: Colors.blue,
              barWidth: MediaQuery.of(context).size.width * 0.01, // Dynamic width
              dotData: FlDotData(show: true),
            ),
          ],
        ),
      ),
    );
  }

  // Returns a color based on the subject key
  Color _getColorFromKey(String key) {
    switch (key) {
      case "Science":
        return Colors.red;
      case "Maths":
        return Colors.green;
      case "Visual Arts":
        return Colors.blue;
      case "CS":
        return Colors.orange;
      case "Financial Literacy":
        return Colors.purple;
      case "Performance Arts":
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  // Builds the trending page
  Widget _buildTrendingPage() {
    return TrendingPage();
  }

  // Builds the your videos page
  Widget _buildYourVideosPage() {
    return YourVideosPage();
  }
}