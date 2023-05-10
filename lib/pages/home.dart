import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_band_name/models/band.dart';
import 'package:flutter_band_name/services/socket_service.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List<Band> bands = [ ];

  @override
  void initState() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    
    socketService.socket.on('active-bands', _handleActiveBands);
    super.initState();
  }

  _handleActiveBands( dynamic payload ) {
    this.bands = (payload as List)
      .map((band) => Band.fromMap(band))
      .toList();

      setState(() { });
  }

  @override
  void dispose() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.off('active-bands');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final socketService = Provider.of<SocketService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Band Names', style:  TextStyle(color: Colors.black87),),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 10),
            child: (socketService.serverStatus == ServerStatus.Online) 
              ? const Icon(Icons.check_circle, color: Colors.green,)
              : const Icon(Icons.offline_bolt, color: Colors.red,),
          )
        ],
      ),
      body: Column(
        children: [

          _showGraph(),

          Expanded(
            child: ListView.builder(
              itemCount: bands.length,
              itemBuilder: (context, index) => _bandTitle(bands[index])       
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 1,
        onPressed: addNewBand,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _bandTitle(Band band) {

    final socketService = Provider.of<SocketService>(context, listen: false);

    return Dismissible(
      key: Key(band.id),
      direction: DismissDirection.startToEnd,
      onDismissed: (_) => socketService.emit('delete-band', {'id': band.id}),
      background: Container(
        padding: const EdgeInsets.only( left: 8.0),
        color: Colors.red,
        child: const Align(
          alignment: Alignment.centerLeft,
          child: Text('Delete Band',style: TextStyle( color: Colors.white),),
        ),
      ),
      child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue.shade100,
              child: Text(band.name.substring(0,2)),
            ),
            title: Text(band.name),
            trailing: Text('${band.votes}', style: const TextStyle(fontSize: 20),),
            onTap: () => socketService.socket.emit('vote-band', {'id': band.id}),
            
          ),
    );
  }

  addNewBand() {

    final textController = new TextEditingController();

    if(Platform.isAndroid) {
      //Android
      return showDialog(
        context: context, 
        builder: (_) {
          return AlertDialog(
            title: const Text('New Band Name'),
            content: TextField(
              controller: textController,
            ),
            actions: [
              MaterialButton(
                elevation: 5,
                textColor: Colors.blue,
                onPressed: () => addBandToList(textController.text),
                child: const Text('Add')
              ),
            ],
          );
        },
      );
    }

    //IOS
    showCupertinoDialog(
      context: context, 
      builder: (_) {
        return CupertinoAlertDialog(
          title: const Text('New Band Name'),
          content: CupertinoTextField(
            controller: textController,
          ),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              child: const Text('Add'),
              onPressed: () => addBandToList(textController.text),
            ),

            CupertinoDialogAction(
              isDestructiveAction: true,
              child: const Text('Dismiss'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      }
    );
  }

  void addBandToList(String name) {

    if (name.length > 1) {
      //podemos agregar
      final socketService = Provider.of<SocketService>(context, listen: false);

      socketService.emit('add-band', {'name': name});
      
    }

    Navigator.pop(context);
  }


  //Widget de grafica
     Widget _showGraph() {

      Map<String, double> dataMap = new Map();
        // dataMap.putIfAbsent('Flutter', () => 5);

        for (var band in bands) {
          dataMap.putIfAbsent(band.name, () => band.votes.toDouble());
        }
        // bands.forEach((band) {
          
        //   dataMap.putIfAbsent(band.name, () => band.votes.toDouble());
        // });
        

        return SizedBox(
          width: double.infinity,
          height: 200,
          child: PieChart(dataMap: dataMap)
        );
    }

}

