import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';


class TextComposer extends StatefulWidget {

  TextComposer(this.sendMessage, this.user);
  final Function({String text, XFile imgFile}) sendMessage;
  final String? user;


  @override
  State<TextComposer> createState() => _TextComposerState();
}

class _TextComposerState extends State<TextComposer> {

  bool _isComposing = false;
  final TextEditingController _controller = TextEditingController();
  final db = FirebaseFirestore.instance;

  void reset(){
    _controller.clear();
    setState(() {
      _isComposing = false;
    });
  }



  void activitiesMsgController(bool isComposing) async{
    List<dynamic> content = [];

    await db.collection("activities").doc("SendingMessages").get().then((value) =>
    {
      if(value.data() != null){
        content.addAll(value.data()!.values.first)
      }});

    if (isComposing) {
      final isUserAlreadyTyping = content.contains(widget.user);
      isUserAlreadyTyping? null:
      db.collection("activities").doc("SendingMessages").set({'content': [...content,widget.user]});
    }else{
      content.removeAt(content.indexOf(widget.user));
      db.collection("activities").doc("SendingMessages").set({'content': [...content]});

    }
  }




  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          IconButton(
        onPressed: () async{
          final XFile? imgFile =
          await ImagePicker().pickImage(source: ImageSource.camera);
         if(imgFile != null) {
           widget.sendMessage(imgFile: imgFile);
         }else{
           return;
         }
          },
    icon:const Icon(Icons.photo_camera),

          ),
          Expanded(child: TextField(
            controller: _controller,
            decoration: const InputDecoration.collapsed(hintText: 'Enviar uma menssagem',fillColor: Color(0xFFA0A0A0),),
            onChanged: (text){
              setState(() {
                _isComposing = text.isNotEmpty;
              });
              widget.user != null? activitiesMsgController(_isComposing) : null;
            },
            onSubmitted: (text){
              widget.sendMessage(text:text);
              reset();
              widget.user != null? activitiesMsgController(_isComposing) : null;
            },
          )
          ),
          IconButton(
              onPressed: _isComposing ? (){
                widget.sendMessage(text: _controller.text);
                reset();
                widget.user != null? activitiesMsgController(_isComposing) : null;
              }:null,
              icon: const Icon(Icons.send))
        ],
      ),
    );
  }
}
