import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sample_app/views/pages/base_page/base_page.dart';

import '../../../cubits/cubits.dart';

class EventPage extends StatefulWidget {
  const EventPage({Key? key, required this.cubit}) : super(key: key);

  final EventCubit cubit;

  @override
  _EventPageState createState() => _EventPageState();
}

class _EventPageState extends CustomState<EventPage, EventCubit> {
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();

    _subscription =cubit.stream.map<String?>((event) => event.data).distinct().listen((event) {
      print('stream listen only data: ${event}');
    });

    cubit.stream.listen((event) {
      print('stream listen all state: ${event.data}');
    });
  }

  @override
  PreferredSizeWidget? buildAppbar(BuildContext context) {
    return AppBar(
      title: Text('Event Page'),
    );
  }

  @override
  Widget buildContent(BuildContext context) {
    return _Content();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  EventCubit get cubit => widget.cubit;
}

class _Content extends StatelessWidget {
  const _Content({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BlocConsumer<EventCubit, EventState>(
          listener: (context, state) {
            // print('listen: ${state.data}');
          },
          builder: (context, state) {



            if (state.data?.isEmpty ?? true) {
              return Text('No data');
            }

            return Text('Data: ${state.data}');
          },
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {
                context.read<EventCubit>().addText('A');
              },
              child: Text('Add text A'),
            ),
            TextButton(
              onPressed: () {
                context.read<EventCubit>().addText('B');
              },
              child: Text('Add text B'),
            ),
            TextButton(
              onPressed: () {},
              child: Text('Show loading'),
            ),
            TextButton(
              onPressed: () {},
              child: Text('Show popup'),
            ),
          ],
        ),
      ],
    );
  }
}
