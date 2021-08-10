import 'package:flutter/material.dart';

PreferredSize balanceHeader(context, data) {
  return PreferredSize(
    preferredSize: Size.fromHeight(MediaQuery.of(context).size.height * 0.34),
    child: AppBar(
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
              child: Icon(Icons.more_horiz),
            )),
      ],
      elevation: 2,
      centerTitle: false,
      title: Text(
        (data['account'] ?? 'Unknown') + ' Wallet',
        style: TextStyle(
          fontSize: 18.0,
          letterSpacing: 2.0,
        ),
      ),
      flexibleSpace: Container(
        color: Colors.blue[900],
        alignment: Alignment.center,
        child: Text(
          '\n\$ 0',
          style: TextStyle(
            fontSize: 24.0,
            letterSpacing: 2.0,
            color: Colors.white,
          ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(50.0),
        child: TabBar(
          labelColor: Colors.grey[200],
          indicatorColor: Colors.grey[400],
          tabs: [
            Tab(
              text: 'Holdings',
            ),
            Tab(
              text: 'Transactions',
            )
          ],
        ),
      ),
    ),
  );
}

TabBarView holdingsTransactionsView() {
  // if full return list of holdings and transactions with RVN being special...
  // if empty return empty message:
  return TabBarView(
    children: [
      Container(
        color: Colors.grey,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.savings, size: 50.0, color: Colors.grey[100]),
            Text(
              '\nYour holdings will appear here.',
              style: TextStyle(
                fontSize: 18.0,
                letterSpacing: 2.0,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      Container(
        color: Colors.grey,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.public, size: 50.0, color: Colors.grey[100]),
            Text(
              '\nYour transactions will appear here.',
              style: TextStyle(
                fontSize: 18.0,
                letterSpacing: 2.0,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
