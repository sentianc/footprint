import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:footprint/api/dio_web.dart';
import 'package:footprint/model/category.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:footprint/pages/category.dart';
import 'package:footprint/pages/detail.dart';
import 'package:footprint/pages/edit_page.dart';
import 'package:footprint/widgets/left_drawer/left_drawer_avatar.dart';
import 'package:footprint/widgets/left_drawer/left_drawer_list_item.dart';
import 'package:footprint/widgets/list/list_image.dart';
import 'package:footprint/widgets/list/list_mask.dart';
import 'package:footprint/widgets/list/list_text.dart';
import 'package:footprint/widgets/list/list_empty_image.dart';
import 'package:footprint/widgets/list/list_empty_mask.dart';
import 'package:footprint/widgets/list/list_empty_text.dart';
import 'package:footprint/widgets/common/smart_drawer.dart'; 

import 'package:footprint/enum/left_drawer_nav.dart';


class Home extends StatefulWidget {

  final String id;
  final String name;

  Home({this.id, this.name});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  BuildContext test;

  List<CategoryDetail> footprintList = new List<CategoryDetail>();

  String token = '';
  String userName = '';
  String avatar = '';

  @override
  void initState() { 
    super.initState();
    getFootprintList();
    getFootprintUserInfo();
  }

  void getFootprintUserInfo() async {
    var sp = await SharedPreferences.getInstance();
    var tokenData = sp.getString('token');
    var userNameData = sp.getString('userName');    
    var avatarData = sp.getString('avatar');
    setState(() {
      token = tokenData;
      userName = userNameData;
      avatar = avatarData;
    });
  }

  Future getFootprintList() async {
    DioWeb.getFootprintList(widget.id, true)
      .then((data) { 
        setState(() {
          footprintList = data;
        });
        getFootprintUserInfo();
      });
  }

  void loginOut() async{
    await DioWeb.loginOut();
    getFootprintUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name, style: TextStyle(color: Color(0xFFFFFFFF), fontSize: 16)),
        backgroundColor: Color(0xFF4abdcc),
        elevation: 0.8,
        leading: Builder(builder: (context) {
          return IconButton(
            icon: Image.asset('assets/img/menu.png', width: 18.0, height: 18.0),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            }
          );
        })
      ),
      drawer: _leftDrawer(context, widget.id, loginOut, token, userName, avatar, (result) {
        setState(() {
          footprintList = result;
        });
      }),
      body: _lists(footprintList, token, userName, context),
      backgroundColor: Color(0xFFfbf7ed),
    );
  }
}

Widget _leftDrawer(
  BuildContext context, 
  String id, 
  Function loginOut, 
  String token, 
  String userName, 
  String avatar,
  Function callback
) {
  return SmartDrawer(
    widthPercent: 0.5,
    child: FlutterEasyLoading(
      child: Container(
        child: Padding(
          padding: EdgeInsets.only(left: 10.0, right: 10.0),
          child: Column(
            mainAxisAlignment:MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                children: <Widget>[
                  LeftDrawerAvatar(token: token, userName: userName, avatar: avatar),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: LeftDrawerNav.leftDrawerNavList[0].length,
                    itemBuilder: (BuildContext context, int index) {
                      return LeftDrawerListItem(
                        imgUrl: LeftDrawerNav.leftDrawerNavList[0][index],
                        text: LeftDrawerNav.leftDrawerNavList[1][index],
                        link: LeftDrawerNav.leftDrawerNavList[2][index],
                        callback: (link) {
                          Navigator.pop(context);
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (BuildContext context) {
                              switch (link) {
                                case 'footprint':
                                  return CategoryPage();
                                default:
                                  break;
                              }
                            }
                          ));
                        }
                      );
                    }
                  )
                ],
              ),
              token != '' && token != null ? Container(
                margin: EdgeInsets.only(bottom: 44.0),
                child: InkWell(
                  child: Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.only(top: 60.0),
                    width: 164.0,
                    height: 40.0,
                    decoration: BoxDecoration(
                      color: Color(0xFF4abdcc),
                      border: Border.all(
                        color: Colors.white,
                      )
                    ),
                    child: Text('注销登录', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w300, fontSize: 16.0)),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    Fluttertoast.showToast(
                      msg: '注销登录中',
                      gravity: ToastGravity.CENTER,
                      timeInSecForIosWeb: 1
                    );
                    loginOut();
                    List<CategoryDetail> result = await DioWeb.getFootprintList(id, false);
                    callback(result);
                  },
                )
              ) : Container()
            ],
          )  
        ),
        color: Color(0xFF4abdcc),
      )
    ) 
  );
}

Widget _lists(List<CategoryDetail> footprintList, String token, String userName, BuildContext context) {
  return Container(
    margin: EdgeInsets.only(top: 15.0),
    child: ListView.builder(
      itemCount: footprintList.length,
      itemBuilder: (BuildContext context, int index) {
        return InkWell(
          onTap: () {
            if (
              token != '' && 
              token != null && 
              userName != '' && 
              userName != null 
            ) {
              showCupertinoModalPopup (
                context: context,
                builder: (BuildContext context) {
                  return CupertinoActionSheet(
                    actions: <Widget>[
                      CupertinoActionSheetAction(
                        child: Text('编辑'),
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (BuildContext context) {
                              var footprintListItem = footprintList[index];
                              return EditPage(id: footprintListItem.id, categoryId: footprintListItem.categoryId, userId: footprintListItem.userId);
                            }
                          ));
                        },
                        isDefaultAction: true,
                      ),
                      CupertinoActionSheetAction(
                        child: Text('查看详情'),
                        onPressed: () {},
                        isDestructiveAction: true,
                      ),
                    ],
                    cancelButton: CupertinoActionSheetAction(
                      child: Text('取消'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  );
                }
              );
            } else {
              Fluttertoast.showToast(
                msg: '请先登录后再操作',
                gravity: ToastGravity.CENTER,
                timeInSecForIosWeb: 1
              );
            }
          },
          child: Padding(
            padding: EdgeInsets.only(left: 15.0, right: 15.0, bottom: 15.0),
            child: Stack(
              children: <Widget>[
                footprintList.length != 0 && footprintList[index].imageUrl != '' ? 
                ListImage(imageUrl: footprintList[index].imageUrl) : 
                ListEmptyImage(),
                footprintList.length != 0 && footprintList[index].imageUrl != '' ? 
                ListMask() : 
                ListEmptyMask(),
                footprintList.length != 0 ? 
                ListText(categoryDetail: footprintList[index]) : 
                ListEmptyText()
              ],
            )
          )
        );
      },
    )
  ); 
}