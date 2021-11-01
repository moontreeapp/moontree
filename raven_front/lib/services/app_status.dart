//class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
//  AppLifecycleState _notification; 
//  @override
//  void didChangeAppLifecycleState(AppLifecycleState state) {
//    setState(() {
//      _notification = state;
//    });
//  }
//
//  @override
//  initState() {
//    super.initState();
//    WidgetsBinding.instance.addObserver(this);
//    ...
//  }
//
//  @override
//  void dispose() {
//    WidgetsBinding.instance.removeObserver(this);
//    super.dispose();
//  }
//}
//
//@override
//  void didChangeAppLifecycleState(AppLifecycleState state) {
//    switch (state) {
//      case AppLifecycleState.resumed:
//        print("app in resumed");
//        break;
//      case AppLifecycleState.inactive:
//        print("app in inactive");
//        break;
//      case AppLifecycleState.paused:
//        print("app in paused");
//        break;
//      case AppLifecycleState.detached:
//        print("app in detached");
//        break;
//    }
//}