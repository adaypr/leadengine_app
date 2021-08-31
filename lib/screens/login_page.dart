import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_authentication/screens/channel_chat_page.dart';
import 'package:flutter_authentication/screens/register_page.dart';
import 'package:flutter_authentication/utils/fire_auth.dart';
import 'package:flutter_authentication/utils/validator.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart' as getstream;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flip_card/flip_card.dart';
import '../config/globals.dart' as globals;

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _formStoreKey = GlobalKey<FormState>();

  final _storeTextController = TextEditingController();
  final _emailTextController = TextEditingController();
  final _passwordTextController = TextEditingController();

  final _focusEmail = FocusNode();
  final _focusPassword = FocusNode();
  final _focusStore = FocusNode();
  var storeInformation = LoginStoreInformation(apiKey: '');

  bool _isProcessing = false;
  GlobalKey<FlipCardState> _cardKey = GlobalKey<FlipCardState>();

  Future<FirebaseApp> _initializeFirebase() async {
    FirebaseApp firebaseApp = await Firebase.initializeApp();

    User? user = FirebaseAuth.instance.currentUser;
    //getstream.StreamChatClient? client = await connectUser();

    if (user != null) {
      /*
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => MyChatPage(client: client),
        ),
      );*/
    }

    return firebaseApp;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _focusEmail.unfocus();
        _focusPassword.unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text('Login'),
        ),
        body: FutureBuilder(
          future: _initializeFirebase(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Padding(
                padding: const EdgeInsets.only(left: 24.0, right: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FlipCard(
                      direction: FlipDirection.VERTICAL,
                      flipOnTouch: false,
                      key: _cardKey,
                      speed: 500,
                      onFlipDone: (status) {
                        print(status);
                      },
                      front: Container(
                          decoration: BoxDecoration(
                            color: Color(0xFFE8E4E3),
                            borderRadius:
                                BorderRadius.all(Radius.circular(8.0)),
                          ),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Form(
                                  key: _formStoreKey,
                                  child: Column(children: <Widget>[
                                    TextFormField(
                                      controller: _storeTextController,
                                      focusNode: _focusStore,
                                      validator: (value) =>
                                          Validator.validateName(
                                        name: value,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: "Store Name",
                                        errorBorder: UnderlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(6.0),
                                          borderSide: BorderSide(
                                            color: Colors.red,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ]),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    this.storeInformation =
                                        await getStoreInformation(
                                            _storeTextController.text);
                                    if ((_formStoreKey.currentState!
                                            .validate()) &&
                                        (storeInformation.apiKey != '')) {
                                      _cardKey.currentState!.toggleCard();
                                    }
                                  },
                                  child: Text(
                                    'Check Store',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ])),
                      back: Container(
                        decoration: BoxDecoration(
                          color: Color(0xFFE8E4E3),
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Form(
                              key: _formKey,
                              child: Column(
                                children: <Widget>[
                                  TextFormField(
                                    controller: _storeTextController,
                                    enabled: true,
                                    onTap: () =>
                                        _cardKey.currentState!.toggleCard(),
                                  ),
                                  SizedBox(height: 8.0),
                                  TextFormField(
                                    controller: _emailTextController,
                                    focusNode: _focusEmail,
                                    validator: (value) =>
                                        Validator.validateEmail(
                                      email: value,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: "Email",
                                      errorBorder: UnderlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(6.0),
                                        borderSide: BorderSide(
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 8.0),
                                  TextFormField(
                                    controller: _passwordTextController,
                                    focusNode: _focusPassword,
                                    obscureText: true,
                                    validator: (value) =>
                                        Validator.validatePassword(
                                      password: value,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: "Password",
                                      errorBorder: UnderlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(6.0),
                                        borderSide: BorderSide(
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 24.0),
                                  _isProcessing
                                      ? CircularProgressIndicator()
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: ElevatedButton(
                                                onPressed: () async {
                                                  _focusEmail.unfocus();
                                                  _focusPassword.unfocus();

                                                  if (_formKey.currentState!
                                                      .validate()) {
                                                    setState(() {
                                                      _isProcessing = true;
                                                    });

                                                    User? user = await FireAuth
                                                        .signInUsingEmailPassword(
                                                      email:
                                                          _emailTextController
                                                              .text,
                                                      password:
                                                          _passwordTextController
                                                              .text,
                                                    );

                                                    setState(() {
                                                      _isProcessing = false;
                                                    });

                                                    if (user != null) {
                                                      LoginUserInformation
                                                          userInformation =
                                                          await getUserInformation(
                                                              this
                                                                  .storeInformation
                                                                  .apiKey,
                                                              user);

                                                      getstream
                                                              .StreamChatClient?
                                                          client =
                                                          await connectUser(
                                                              this.storeInformation,
                                                              user,
                                                              userInformation);
                                                      Navigator.of(context)
                                                          .pushReplacement(
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              MyChatPage(
                                                                  client:
                                                                      client),
                                                        ),
                                                      );
                                                    }
                                                  }
                                                },
                                                child: Text(
                                                  'Sign In',
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 24.0)
                                          ],
                                        )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            return Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }
}

Future<getstream.StreamChatClient> connectUser(LoginStoreInformation store,
    User user, LoginUserInformation userInformation) async {
  final client = getstream.StreamChatClient(
    store.apiKey,
    logLevel: getstream.Level.INFO,
  );
  await client.connectUser(
    getstream.User(id: user.uid),
    userInformation.userToken,
  );
  return client;
}

class LoginUserInformation {
  final String userToken;

  LoginUserInformation({
    required this.userToken,
  });

  factory LoginUserInformation.fromJson(Map<String, dynamic> json) {
    return LoginUserInformation(userToken: json['userToken']);
  }
}

class LoginStoreInformation {
  final String apiKey;

  LoginStoreInformation({
    required this.apiKey,
  });

  factory LoginStoreInformation.fromJson(Map<String, dynamic> json) {
    return LoginStoreInformation(
      apiKey: json['apiKey'],
    );
  }
}

Future<LoginUserInformation> getUserInformation(
    String apiKey, User user) async {
  final response = await http.get(Uri.parse(globals.backendServer +
      '/userlogininformation?userid=' +
      user.uid +
      '&apikey=' +
      apiKey));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return LoginUserInformation.fromJson(jsonDecode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load LoginChatInformation');
  }
}

Future<LoginStoreInformation> getStoreInformation(String storeName) async {
  final response = await http.get(Uri.parse(
      globals.backendServer + '/storelogininformation?storeName=' + storeName));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return LoginStoreInformation.fromJson(jsonDecode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load LoginChatInformation');
  }
}
