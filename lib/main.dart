import 'package:flutter/material.dart';
import 'package:resq/home.dart';
import 'package:resq/screens/add_members.dart';
import 'package:resq/screens/agriculture.dart';
import 'package:resq/screens/assistance_support.dart';
import 'package:resq/screens/education_livielhoood.dart';
import 'package:resq/screens/emp_status.dart';
import 'package:resq/screens/foodand_health.dart';
import 'package:resq/screens/helthnew.dart';
import 'package:resq/screens/incom_andlose.dart';
import 'package:resq/screens/kudumbasree.dart';
import 'package:resq/screens/personal_loan.dart';
import 'package:resq/screens/shelter.dart';
import 'package:resq/screens/skill.dart';
import 'package:resq/screens/social.dart';
import 'package:resq/screens/special_category.dart';
import 'screens/login_screen.dart';
import 'screens/admin_dashboard.dart';
import 'screens/camp_status.dart';
import 'screens/create_notice.dart';
import 'screens/families.dart';
import 'screens/add_famili.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
        '/otp': (context) => AddFamilies(),
        '/admin-dashboard': (context) => AdminDashboard(),
        '/families': (context) => FamiliesScreen(),
        '/camp-status': (context) => CampStatusScreen(),
        '/create-notice': (context) => CreateNoticeScreen(),
        '/foodand-health': (context) => FoodandHealth(),  
         '/shelter':(context)=>Shelter(),
         '/education-livilehood':(context)=>EducationLivielhoood(),
         '/agriculture':(context)=>Agriculture(),
         '/social':(context)=>Social(),
         '/personal-loan':(context)=>PersonalLoan(),
         '/special':(context)=>SpecialCategory(),
         '/kudumbasree':(context)=>Kudumbasree(),
         '/assistance':(context)=>AssistanceSupport(),
         '/incomandlose':(context)=>IncomAndlose(),
         '/emp-status':(context)=>EmpStatus(),
         '/add-members':(context)=>AddMembers(),
         '/helthnew':(context)=>HealthNew(),
         '/skill':(context)=>Skill(),
         '/home':(context)=>Home()
         

            },
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (context) => Scaffold(body: Center(child: Text('Page Not Found'))),
      ),
    );
  }
}