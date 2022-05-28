import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../cubits/cubits.dart';
import '../../../data/response/status_code.dart';
import '../../../widgets/widgets.dart';

class LoadMoreCircular extends StatelessWidget {
  const LoadMoreCircular({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeCubit, HomeState>(
      builder: (context, state) {
        if (state.loadStatus == LoadStatus.loaded && state.loadingMore == true) {
          return Center(
            child: Container(
              width: 48,
              height: 48,
              margin: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.grey,),
            ),
          );
        } else if (state.loadingMore == false) {
          return GestureDetector(
            onTap: () => context.read<HomeCubit>().loadMore(),
            child: Container(
              width: 50,
              height: 50,
              alignment: Alignment.center,
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey, width: 2),
              ),
              child: const Icon(
                Icons.add,
                size: 20,
                color: Colors.grey,
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
      listenWhen: (oldState, newState) {
        return oldState != newState;
      },
      listener: (context, state) {
        if (state.errorStatus == StatusCode.requestTimeout) {
          Toast.makeText(context: context, message: 'Have an error!');
        }
      },
    );
  }
}
