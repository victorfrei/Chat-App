import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';



class GalleryWidget extends StatefulWidget {
  final String imgUrl;

  const GalleryWidget({Key? key,
    required this.imgUrl,
}) : super(key: key);

  @override
  State<GalleryWidget> createState() => _GalleryWidgetState();
}

class _GalleryWidgetState extends State<GalleryWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PhotoViewGallery.builder(
          itemCount: 1,
          builder: (context,index) {
            final imgUrl = widget.imgUrl;
            return PhotoViewGalleryPageOptions(
                imageProvider: NetworkImage(imgUrl),
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.contained*5,
              heroAttributes: PhotoViewHeroAttributes(
                tag: index
              )
            );
          }
      ),
    );
  }
}



class ChatMessage extends StatelessWidget {

  final Map<String, dynamic> data;
  final bool mine;

  ChatMessage(
        this.data,
        this.mine,
  );

  void openGallery(context) => Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => GalleryWidget(
          imgUrl: data['imgUrl']
      )
  ));



  ClipRRect referenceTo(Map<String,dynamic> reference){

    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(20)),
      child: Container(
        margin: const EdgeInsets.all(5),
        decoration: const BoxDecoration(
          color: Color(0xFFA0A0A0),
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 12,bottom: 12, right: 15,left: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children:[
              Padding(
                padding: const EdgeInsets.only(right: 15),
                child:
                CircleAvatar(
                  backgroundImage: NetworkImage(reference['senderPhotoUrl']),
                ),
               ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children:[
                  Row(
                      children:[
                        Row(
                        children:[

                          const Icon(Icons.reply),
                          SizedBox(
                            width: 120,
                            child: Text(reference['senderName'],

                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xAA550033),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                          ),
                        ],
                          ),

                      ]            ),

                  Container(
                    width: 120,
                    padding: const EdgeInsets.all(2),
                    child:
                    reference['imgUrl']!=null?
                    Image.network(reference['imgUrl']):
                    Text(reference["text"]),
                  ),
],
              ),
            ],
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return
      Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: mine? const Radius.circular(20): Radius.zero,
            bottomRight: mine?  Radius.zero: const Radius.circular(20) ,
          ),
          color: const Color(0xFFD0D0D0),

        ),
        margin: const EdgeInsets.symmetric(vertical: 5,horizontal: 5),
        padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 20),

      child: Row(
        children: [
          !mine?
          Padding(
            padding: const EdgeInsets.only(right: 16),
          child: CircleAvatar(
            backgroundImage: NetworkImage(data['senderPhotoUrl']),
          ),
          ) : Container(),
          Expanded(
              child: Column(
                crossAxisAlignment: mine?CrossAxisAlignment.end:CrossAxisAlignment.start,

                children: [
                  Text(data['senderName'],
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xAA550033),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  data['imgUrl']!= null?
                    Column(
                        crossAxisAlignment: mine?CrossAxisAlignment.end:CrossAxisAlignment.start,
                      children:[
                      data['referenceTo']!=null?referenceTo(data['referenceTo']):Container(),
                        InkWell(
                            child:  ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.network(
                                data['imgUrl'],
                                width: 250,
                              fit: BoxFit.cover,
                            ),
    ),
                          onTap: (){
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder:(_) => GalleryWidget(
                                        imgUrl: data['imgUrl']
                                    )
                                ),
                              );
                          }
                        ),
                        Text(
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF000000),
                            fontWeight: FontWeight.w400,
                          ),
                            DateFormat.yMMMd().add_jm().format(
                                DateTime.fromMicrosecondsSinceEpoch(
                                    data['time'].microsecondsSinceEpoch
                                )
                            ),
                        )
                      ]
                      )

                  :
                  data['referenceTo']!=null?referenceTo(data['referenceTo']):Container(),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                      child: Column(
                          crossAxisAlignment: mine?CrossAxisAlignment.end:CrossAxisAlignment.start,
                  children:[ Text(data['text']!=null?
                        data['text'].toString():"",
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    Text(
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                      DateFormat.yMMMd().add_jm().format(
                          DateTime.fromMicrosecondsSinceEpoch(
                              data['time']?.microsecondsSinceEpoch
                          )
                      ),
                    )
    ]
                  ),
          )


                ],
              ),
                ),
          mine ?
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: CircleAvatar(
              backgroundImage: NetworkImage(data['senderPhotoUrl']),
            ),
          ) : Container()
        ],
      ),
    );

  }
}

