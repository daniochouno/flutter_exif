import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

import 'package:flutter_exif/flutter_exif.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Example',
        home: HomeScreen()
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  int startingAt = 1574679600;
  int endingAt = 1575370800;

  Map<String,Uint8List> images = Map<String,Uint8List>();
  List<FlutterExifData> items = List<FlutterExifData>();

  @override
  void initState() {
    super.initState();
    _checkPermissions().then( (granted) {
      if (granted) {
        _updateList();
      } else {
        _requestPermissions().then( (granted) {
          _updateList();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app')
        ),
        body: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric( horizontal: 32 ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text("Starting at:"),
                  ),
                  FlatButton(
                      onPressed: () {
                        DatePicker.showDateTimePicker(context,
                            showTitleActions: true,
                            onConfirm: (datetime) {
                              setState((){
                                this.startingAt = (datetime.millisecondsSinceEpoch~/1000);
                              });
                              _updateList();
                            },
                            currentTime: DateTime.fromMillisecondsSinceEpoch( this.startingAt * 1000 )
                        );
                      },
                      child: Text(
                        '${ _format( this.startingAt * 1000 ) }',
                        style: TextStyle(color: Colors.blue),
                      )
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric( horizontal: 32 ).add( EdgeInsets.only( bottom: 16 ) ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text("Ending at:"),
                  ),
                  FlatButton(
                      onPressed: () {
                        DatePicker.showDateTimePicker(context,
                            showTitleActions: true,
                            onConfirm: (datetime) {
                              setState((){
                                this.endingAt = (datetime.millisecondsSinceEpoch~/1000);
                              });
                              _updateList();
                            },
                            currentTime: DateTime.fromMillisecondsSinceEpoch( this.endingAt * 1000 )
                        );
                      },
                      child: Text(
                        '${ _format( this.endingAt * 1000 ) }',
                        style: TextStyle(color: Colors.blue),
                      )
                  )
                ],
              )
            ),
            Expanded(
              child: _list( context ),
            )
          ],
        )
    );
  }

  Widget _list( BuildContext context ) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: this.items.length,
      itemBuilder: (BuildContext context, int index) {
        FlutterExifData item = this.items[index];
        if (!images.containsKey( item.identifier )) {
          FlutterExif.image( item.identifier, width: 64, height: 64 ).then( (imageData) {
            setState(() {
              this.images[ item.identifier ] = imageData;
            });
          });
        }
        return Padding(
          padding: EdgeInsets.all( 4 ),
          child: ListTile(
              title: Text( _format( item.createdAt * 1000 ) ),
              subtitle: Text( "${item.latitude} ,\n${item.longitude}" ),
              leading: _imageView( item.identifier )
          ),
        );
      },
    );
  }

  Widget _imageView( String identifier ) {
    if (images.containsKey( identifier )) {
      return Container(
        width: 64,
        child: Image.memory( images[ identifier ] )
      );
    } else {
      return Container(
          width: 64,
          height: 64,
          color: Colors.red
      );
    }
  }

  Future<bool> _checkPermissions() async {
    PermissionStatus permission = await PermissionHandler().checkPermissionStatus( PermissionGroup.storage );
    return (permission == PermissionStatus.granted);
  }

  Future<bool> _requestPermissions() async {
    Map<PermissionGroup,PermissionStatus> permissions = await PermissionHandler().requestPermissions([ PermissionGroup.storage ]);
    return (permissions[PermissionGroup.storage] == PermissionStatus.granted);
  }

  _updateList() {
    setState(() {
      this.items = List<FlutterExifData>();
    });
    _load().then( (list) {
      setState(() {
        this.items = list;
      });
    });
  }

  Future<List<FlutterExifData>> _load() async {
    if (this.startingAt == null) {
      return null;
    }
    if (this.endingAt == null) {
      return null;
    }
    var list = await FlutterExif.list(
        this.startingAt,
        this.endingAt );
    return list;
  }

  String _format( int milliseconds ) {
    if (milliseconds == null) {
      return "";
    }
    DateTime datetime = DateTime.fromMillisecondsSinceEpoch( milliseconds );
    var formatter = DateFormat( "dd MMM yyyy, HH:mm" );
    return formatter.format( datetime );
  }

}
