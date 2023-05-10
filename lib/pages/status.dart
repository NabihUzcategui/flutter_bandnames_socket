

import 'package:flutter/material.dart';
import 'package:flutter_band_name/services/socket_service.dart';
import 'package:provider/provider.dart';

class StatusPage extends StatelessWidget {
   
  const StatusPage({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {

    final socketService = Provider.of<SocketService>(context);

    return  Scaffold(
      body: Center(
         child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('ServerStatus: ${ socketService.serverStatus} ')
          ],
         ),
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 1,
        child: Icon(Icons.message_outlined),
        onPressed: () {
          socketService.emit('emitir-mensaje', {
            'nombre': 'Flutter', 
            'mensaje': 'Hola desde flutter'
          });
        },
      ),
    );
  }
}