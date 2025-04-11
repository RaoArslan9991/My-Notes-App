import 'package:first_app/constants/routes.dart';
import 'package:first_app/services/auth/auth_services.dart';

import 'package:first_app/views/login_view.dart';
import 'package:first_app/views/notes/create_update_note_view.dart';
import 'package:first_app/views/notes/notes_view.dart';
import 'package:first_app/views/register_view.dart';
import 'package:first_app/views/verify_email_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey,
        )
      ),
      home: const HomePage(),
      routes: {
        loginRoute : (context)=> const LoginView(),
        registerRoute : (context)=> const RegisterView(),
        notesRoute: (context)=> const NotesView(),
        verifyEmailRoute : (context)=> const VerifyEmailView(),
        createOrUpdateNoteRoute : (context) => const CreateUpdateNoteView()
      },
    ),
  );
}

// class HomePage extends StatelessWidget {
//   const HomePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder(
//         future: AuthServices.firebase().initialize(),
//         builder: (context, snapshot) {
//           switch(snapshot.connectionState) {
//             case ConnectionState.done:
//             final user = AuthServices.firebase().currentUser;

//             if(user != null){
//               if(user.isEmailVerified){
//                 return const NotesView();
//               }else{
//                 return const VerifyEmailView();
//               }
//             }else{
//               return LoginView();
//             }

//             // if(user?.emailVerified ?? false){
//             //   // print('User is verified ');
//             //   return const Text('Done');
//             // }else{
//             //   // print('You need to verify first');
//             //   return const VerifyEmailView();
//             // }
            
//             default:
//               return const CircularProgressIndicator();
//           }
          
          
//         },
        
//       );
//   }
// }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CounterBloc(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Testing bloc'),
        ),
        body: BlocConsumer<CounterBloc,CounterState>(
          listener: (context, state){
            _controller.clear();
          },
          builder: (context, state){
            final invalidValue = (state is CounterStateInvalidNumber)? state.invalidNumber : '';
            
            return Column(
              children: [
                Text('The current value -> ${state.value}'),

                Visibility(
                  visible: state is CounterStateInvalidNumber,
                  child: Text('invalid value $invalidValue')
                ),

                TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: 'Enter number here '
                  ),

                  keyboardType: TextInputType.number
                ),
                
                Row(
                  children: [
                    TextButton(
                      onPressed: (){
                        context.read<CounterBloc>().add(DecrementEvent(_controller.text));
                      }, 
                      child: Text('-')
                    ),
                    TextButton(
                      onPressed: (){
                        context.read<CounterBloc>().add(IncrementEvent(_controller.text));
                      }, 
                      child: Text('+')
                    )
                  ],
                )
              ],
            );
          }
        )
      )
    );
  }
}

@immutable
abstract class CounterState{
  final int value;
  const CounterState(this.value);
}

class CounterStateValid extends CounterState{
  const CounterStateValid(int value) : super(value);
}

class CounterStateInvalidNumber extends CounterState{
  final String invalidNumber;
  const CounterStateInvalidNumber({
    required this.invalidNumber,
    required int previousValue,
  }): super(previousValue);
}

@immutable
abstract class CounterEvent{
  final String value;
  const CounterEvent(this.value);
}

class IncrementEvent extends CounterEvent{
  const IncrementEvent(String value) : super(value);
}

class DecrementEvent extends CounterEvent{
  const DecrementEvent(String value) : super(value);
}

class CounterBloc extends Bloc<CounterEvent,CounterState>{
  CounterBloc() : super(CounterStateValid(0)){
    on<IncrementEvent>((event,emit){
      final integer = int.tryParse(event.value);
      if(integer == null){
        emit(CounterStateInvalidNumber(
          invalidNumber: event.value, 
          previousValue: state.value
          ));
      }else{
        emit(CounterStateValid(state.value + integer));
      }
    });
    on<DecrementEvent>((event,emit){
      final integer = int.tryParse(event.value);
      if(integer == null){
        emit(CounterStateInvalidNumber(
          invalidNumber: event.value, 
          previousValue: state.value
          ));
      }else{
        emit(CounterStateValid(state.value - integer));
      }
    });
  }
}