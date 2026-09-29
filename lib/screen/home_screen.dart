
import 'package:flutter/material.dart';
import 'package:localnotification/setup/notification_services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async
  {
    await NotificationServices().requestNotificationPermission();
    await NotificationServices().requestExactAlarmPermission();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notification"),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(
                onPressed: (){
                  NotificationServices().showNotification(
                      title: "Water",
                      body: "Drink water"
                  );

                },
                child: Text("Send Notification")
            ),

            SizedBox(height: 10,),
            ElevatedButton(
                onPressed: () async {
                  await NotificationServices().showScheduleNotification(
                    id: 104,
                    title: "Schedule",
                    body: "This is a scheduled notification",
                  );

                },
                child: Text("Send Scheduled Notification")
            )

          ],
        ),
      )
    );
  }
}
