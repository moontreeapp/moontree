import 'package:flutter/material.dart';

import 'account_view.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  dynamic data = {};

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    data = data.isNotEmpty ? data : ModalRoute.of(context)!.settings.arguments;

    // set background image
    //String bgImage = 'ravenbg.png';
    Color? bgColor = Colors.blueAccent[50];

//PreferredSize(preferredSize: Size.fromHeight(MediaQuery.of(context).size.height * 0.34), child:
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        automaticallyImplyLeading: true,
        actions: <Widget>[
          Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () {},
                child: Icon(
                  Icons.add,
                  size: 26.0,
                ),
              )),
          Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () {},
                child: Icon(Icons.more_vert),
              )),
        ],
        elevation: 0,
        centerTitle: false,
        title: Text(
          (data['account'] ?? 'unknown'),
          style: TextStyle(
            fontSize: 18.0,
            letterSpacing: 2.0,
          ),
        ),
      ),
      body: SafeArea(
        child: Container(
          //decoration: BoxDecoration(
          //  image: DecorationImage(
          //    image: AssetImage('assets/$bgImage'),
          //    fit: BoxFit.cover,
          //  ),
          //),
          child: Column(
            children: <Widget>[
              Container(
                color: Colors.blue[900],
                width: double.infinity,
                height: 100.0,
                alignment: Alignment.center,
                child: Text(
                  '\$ 0',
                  style: TextStyle(
                    fontSize: 24.0,
                    letterSpacing: 2.0,
                    color: Colors.white,
                  ),
                ),
              ),
              DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    TabBar(
                      labelColor: Colors.blue[900],
                      indicatorColor: Colors.blue[700],
                      tabs: [
                        Tab(
                          text: 'Holdings',
                        ),
                        Tab(
                          text: 'Transactions',
                        )
                      ],
                    ),
                    //TabBarView(
                    //  children: [
                    //    Text(
                    //      'Tab View 1',
                    //      style: TextStyle(
                    //        fontSize: 18.0,
                    //        letterSpacing: 2.0,
                    //        color: Colors.white70,
                    //      ),
                    //    ),
                    //    Text(
                    //      'Tab View 2',
                    //      style: TextStyle(
                    //        fontSize: 18.0,
                    //        letterSpacing: 2.0,
                    //        color: Colors.white70,
                    //      ),
                    //    )
                    //  ],
                    //),
                  ],
                ),
              ),
            ],
          ),
          //Padding(
          //    padding: const EdgeInsets.fromLTRB(0, 20.0, 0, 0),
          //    child: AccountView(data: data)),
        ),
      ),
    );
  }
}
