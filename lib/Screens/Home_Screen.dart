import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../Screens/Profile_Screen.dart';
import '../Screens/Search_Screen.dart';
import '../Screens/recent_Conversation.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  double _height;
  double _width;
  TabController _tabController;
  _HomeScreenState() {
    _tabController = TabController(length: 3, vsync: this, initialIndex: 1);
  }
  @override
  Widget build(BuildContext context) {
    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).backgroundColor,
        textTheme: TextTheme(
          // ignore: deprecated_member_use
          title: TextStyle(
            fontSize: 16,
          ),
        ),
        title: Align(
          alignment: Alignment.center,
          child: Text(
            'Social Spark',
            style: TextStyle(
                fontWeight: FontWeight.normal, fontStyle: FontStyle.normal),
          ),
        ),
        bottom: TabBar(
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.blue,
          labelColor: Colors.blue,
          controller: _tabController,
          tabs: [
            Tab(
              //text: "Peoples",
              icon: Icon(
                Icons.people_outline,
                size: 25,
              ),
            ),
            Tab(
              //text: "Chat",
              icon: Icon(
                Icons.chat_bubble_outline,
                size: 25,
              ),
            ),
            Tab(
              //text: "Info",
              icon: Icon(
                Icons.person_outline,
                size: 25,
              ),
            ),
          ],
        ),
      ),
      body: _tabBarPages(),
    );
  }

  Widget _tabBarPages() {
    return TabBarView(
      controller: _tabController,
      children: <Widget>[
        SearchPage(_height, _width),
        RecentConversationsPage(_height, _width),
        ProfileScreen(_height, _width),
      ],
    );
  }
}
