import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/chat_message.dart';
import 'package:flutter_chat_app/text_composer.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  final GoogleSignIn googleSignIn = GoogleSignIn();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final db = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;
  bool isLoading = false;
  bool isSendingMessage = false;
  Map<String,dynamic>? referenceState;
  User? currentUser;


  @override
  void initState() {
    super.initState();

    FirebaseAuth.instance.authStateChanges().listen((user) {
      setState(() =>
      {
        currentUser = user
      });
    });
  }

  Future<User?> getUser() async {
    if (currentUser != null) return currentUser;

    try {
      final GoogleSignInAccount? googleSignInAccount =
      await GoogleSignIn().signIn();

      final GoogleSignInAuthentication? googleSignInAuthentication =
      await googleSignInAccount?.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleSignInAuthentication?.idToken,
          accessToken: googleSignInAuthentication?.accessToken
      );

      final UserCredential authResult =
      await FirebaseAuth.instance.signInWithCredential(credential);

      final User? user = authResult.user;

      return user;
    } catch (error) {
      return null;
    }
  }

  void _sendMsg({String? text, XFile? imgFile}) async{

    final User? user = await getUser();

    if(user == null){
      scaffoldKey.currentState?.showSnackBar(
          const SnackBar(
            content: Text("Não foi possivel fazer o login. Tente novamente mais tarde!"),
            backgroundColor: Colors.red,
          )
      );
    }

    Map<String, dynamic> data = {
      "uid":user?.uid,
      "senderName": user?.displayName,
      "senderPhotoUrl":user?.photoURL,
      "time":Timestamp.now(),
      "text":"",
      "referenceTo":referenceState,
    };

    if(imgFile != null && text == null){
      final task = storage.ref().child(
          DateTime.now().millisecondsSinceEpoch.toString()
      ).putFile(File(imgFile.path));

      setState(()=>{
        isLoading = true,
        referenceState = null,
      });


      task.then((p0) async => {
        db.collection("messages").get().then((value) async =>
        {
          if (currentUser != null) db.collection("messages").add({
            ...data,
            "imgUrl": await p0.ref.getDownloadURL()
          }),

          setState(() =>
          {
            isLoading = false,
            referenceState = null,
          })
        })
      });



    }

    if(imgFile == null && text != null){
      if (currentUser != null) {
        db.collection("messages").get().then((value) async =>
          db.collection("messages").add({...data,"text": text})
      );
      }

      setState(() =>
      {
        isLoading = false,
        referenceState = null,
      });
    }
  }

  StreamBuilder someoneIsTyping(){
    return StreamBuilder<QuerySnapshot>(

        stream: db.collection("activities").snapshots(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return const Center(
                child: LinearProgressIndicator(),
              );
            default:
              List? documents = snapshot.data?.docs.first.get("content");
              final documentsAmount = documents?.length;

              switch(documentsAmount){
                case 0:
                  return Container();
                case 1:
                  return Text('${documents?.join(", ")} está digitando...');
                default:
                  return Text('${documents?.join(", ")} estão digitando...');
              }
          }
        },
      );

  }

  ClipRRect referenceTo(Map<String,dynamic> reference){

    return ClipRRect(
        borderRadius: const BorderRadius.only(topRight: Radius.circular(20),topLeft: Radius.circular(20) ),
    child: Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFFA0A0A0),
        borderRadius: BorderRadius.only(topRight: Radius.circular(20),topLeft: Radius.circular(20) ),
      ),
      child: Padding(
      padding: const EdgeInsets.only(top: 12,bottom: 12, right: 15,left: 15),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children:[
    Padding(
      padding: const EdgeInsets.only(right: 15),
        child: CircleAvatar(
          backgroundImage: NetworkImage(reference['senderPhotoUrl']),
        ),
    ),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children:[
            Row(
            children:[
              Text(reference['senderName'],

              style: const TextStyle(
                fontSize: 16,
                color: Color(0xAA550033),
                fontWeight: FontWeight.w600,
              ),
            ),

      ]            ),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(2),
          child:
        reference['text']!=null?
        Text(reference["text"]):
        Image.network(reference['imgUrl']),
        ),
      ],

        ),

        Padding(
            padding: const EdgeInsets.only(left: 28),
            child: IconButton(onPressed: (){
              setState(()=>{
                referenceState = null,
              });
            }, icon: const Icon(Icons.close,size: 28))
        ),


      ],
    ),
    ),
    ),
    );
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
            elevation: 0,
            centerTitle: true ,
            backgroundColor: const Color(0xFF808080),
            title: Row(
              children: <Widget>[
                currentUser!=null ?
                Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child:CircleAvatar(
                      backgroundImage: NetworkImage(currentUser!.photoURL!),
                    )): Container(),

                Text(
                  currentUser!=null ? "${currentUser!.displayName} (Group Chat) ":"Chat App",
                  style: const TextStyle(color: Colors.black87),
                ),
              ],
            ),

            actions: <Widget>[
              currentUser !=null ?
              IconButton(
                onPressed: (){
                  FirebaseAuth.instance.signOut();
                  googleSignIn.signOut();
                  scaffoldKey.currentState?.showSnackBar(
                      const SnackBar(
                        content: Text("Você saiu com sucesso!!"),
                      )
                  );
                },
                icon: const Icon(Icons.exit_to_app),
              ):Container(),
            ]
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: db.collection("messages").orderBy("time").snapshots(),
                builder: (context, snapshot){
                  switch(snapshot.connectionState){
                    case ConnectionState.none:
                    case ConnectionState.waiting:
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    default:
                      List<DocumentSnapshot> documents = snapshot.data!.docs.reversed.toList();
                      return ListView.builder(
                          itemCount: documents.length,
                          reverse: true,
                          itemBuilder: (context, index){
                            Map<String,dynamic> document = documents[index].data() as Map<String,dynamic>;
                            return FocusedMenuHolder(

                              menuItems:

                              documents[index].get("senderName") != currentUser?.displayName?

                              <FocusedMenuItem>[
                                FocusedMenuItem(title: const Text("Responder"),trailingIcon: const Icon(Icons.reply) ,onPressed: ()async{

                                  setState(()=>{
                                    referenceState = document,
                                  });
                                }),

                              ]:
                              <FocusedMenuItem>[
                                FocusedMenuItem(title: const Text("Citar"),trailingIcon: const Icon(Icons.reply) ,onPressed: ()async{

                                  setState(()=>{
                                    referenceState = document,
                                  });
                                }),
                                FocusedMenuItem(title: const Text("Apagar",style: TextStyle(color: Colors.redAccent),),trailingIcon: const Icon(Icons.delete,color: Colors.redAccent,) ,onPressed: (){
                                 db.collection("messages").doc(documents[index].id).delete();
                                 db.collection("messages").add({
                                   'senderName':"Chat App (Bot) - ${currentUser?.displayName}",
                                   'senderPhotoUrl':currentUser?.photoURL,
                                   'text':'A mensagem de ${currentUser?.displayName}, foi apagada!!',
                                   'time':DateTime.now(),
                                   'uid':"",
                                 });
                                }),
                              ],
                              onPressed: (){
                                setState(()=>{

                                });
                              },
                              menuOffset: 12.0,
                              openWithTap: false,
                                child: ListTile(
                              title: ChatMessage(
                                  documents[index].data() as Map<String, dynamic>,
                                  documents[index].get("uid") == currentUser?.uid
                              ),
                            ),
                            );

                          }
                      );
                  }
                },
              ),
            ),
            isLoading? const LinearProgressIndicator():Container(),
            someoneIsTyping(),
            referenceState != null? referenceTo(referenceState!):Container(),
            TextComposer(_sendMsg, currentUser?.displayName),

          ],
        )
    );
  }
}
