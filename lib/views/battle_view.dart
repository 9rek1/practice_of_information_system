import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../views/widgets/user1.dart';
import '../views/widgets/user2.dart';
import '../views/widgets/3_buttons.dart';

class BattlePage extends StatelessWidget {
  const BattlePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
        child: Stack(
      children: <Widget>[
        Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [User1(), User2()],
          ),
          Buttons(),
        ])
      ],
    ));
  }
}

@immutable
class BattlePageState {
  const BattlePageState({
    this.user1Hp = 0,
    this.user1State = 1,
    this.user1Status1 = 0,
    this.user1Status2 = 0,
    this.user1Status3 = 0,
    this.user1Item = 0,
    this.user2Hp = 0,
    this.user2Status1 = 0,
    this.user2Status2 = 0,
    this.user2Status3 = 0,
    this.user2Item = 0,
    this.winner = '',
  });
  final int user1Hp;
  final int user1State;
  final int user1Status1;
  final int user1Status2;
  final int user1Status3;
  final int user1Item;
  final int user2Hp;
  final int user2Status1;
  final int user2Status2;
  final int user2Status3;
  final int user2Item;
  final String winner;

  BattlePageState copyWith({
    int? user1Hp,
    int? user1State,
    int? user1Status1,
    int? user1Status2,
    int? user1Status3,
    int? user1Item,
    int? user2Hp,
    int? user2Status1,
    int? user2Status2,
    int? user2Status3,
    int? user2Item,
    String? winner,
  }) {
    return BattlePageState(
      user1Hp: user1Hp ?? this.user1Hp,
      user1State: user1State ?? this.user1State,
      user1Status1: user1Status1 ?? this.user1Status1,
      user1Status2: user1Status2 ?? this.user1Status2,
      user1Status3: user1Status3 ?? this.user1Status3,
      user1Item: user1Item ?? this.user1Item,
      user2Hp: user2Hp ?? this.user2Hp,
      user2Status1: user2Status1 ?? this.user2Status1,
      user2Status2: user2Status2 ?? this.user2Status2,
      user2Status3: user2Status3 ?? this.user2Status3,
      user2Item: user2Item ?? this.user2Item,
      winner: winner ?? this.winner,
    );
  }
}

class BattlePageStateNotifier extends StateNotifier<BattlePageState>
    with WidgetsBindingObserver {
  BattlePageStateNotifier() : super(const BattlePageState());

  void initBattle(stateNumber, status1, status2, status3) {
    // state = state.copyWith(user1Hp: 100,user1Status1:Random().nextInt(50),user1Status2:Random().nextInt(50),user1Status3: Random().nextInt(50),user1Item: 0);
    state = state.copyWith(
        user1Hp: 100,
        user1State: stateNumber,
        user1Status1: status1 * 5,
        user1Status2: status2 * 5,
        user1Status3: status3 * 5,
        user1Item: 0);
    state = state.copyWith(
        user2Hp: 100,
        user2Status1: Random().nextInt(5) * 5,
        user2Status2: Random().nextInt(5) * 5,
        user2Status3: Random().nextInt(5) * 5,
        user2Item: 0,
        winner: '');
    print('initbattle $state,$status1,$status2,$status3');
  }

  void rock() {
    state = state.copyWith(user1Item: 1, user2Item: Random().nextInt(3) + 1);
    print('rock:');
    if (state.user2Item == 1) {
    } else if (state.user2Item == 2) {
      state = state.copyWith(user2Hp: state.user2Hp - state.user1Status1);
    } else if (state.user2Item == 3) {
      state = state.copyWith(user1Hp: state.user1Hp - state.user2Status3);
    }
    if (state.user1Hp <= 0) {
      state = state.copyWith(
          user1Hp: 0,
          user1Status1: 0,
          user1Status2: 0,
          user1Status3: 0,
          winner: 'User2の勝利');
    }
    if (state.user2Hp <= 0) {
      state = state.copyWith(
          user2Hp: 0,
          user2Status1: 0,
          user2Status2: 0,
          user2Status3: 0,
          winner: 'あなたの勝利');
    }
  }

  void scis() {
    state = state.copyWith(user1Item: 2, user2Item: Random().nextInt(3) + 1);
    if (state.user2Item == 1) {
      state = state.copyWith(user1Hp: state.user1Hp - state.user2Status1);
    } else if (state.user2Item == 2) {
    } else if (state.user2Item == 3) {
      state = state.copyWith(user2Hp: state.user2Hp - state.user1Status2);
    }
    if (state.user1Hp <= 0) {
      state = state.copyWith(
          user1Hp: 0,
          user1Status1: 0,
          user1Status2: 0,
          user1Status3: 0,
          winner: 'User2の勝利');
    }
    if (state.user2Hp <= 0) {
      state = state.copyWith(
          user2Hp: 0,
          user2Status1: 0,
          user2Status2: 0,
          user2Status3: 0,
          winner: 'あなたの勝利');
    }
  }

  void paper() {
    state = state.copyWith(user1Item: 3, user2Item: Random().nextInt(3) + 1);
    if (state.user2Item == 1) {
      state = state.copyWith(user2Hp: state.user2Hp - state.user1Status3);
    } else if (state.user2Item == 2) {
      state = state.copyWith(user1Hp: state.user1Hp - state.user2Status2);
    } else if (state.user2Item == 3) {}
    if (state.user1Hp <= 0) {
      state = state.copyWith(
          user1Hp: 0,
          user1Status1: 0,
          user1Status2: 0,
          user1Status3: 0,
          winner: 'User2の勝利');
    }
    if (state.user2Hp <= 0) {
      state = state.copyWith(
          user2Hp: 0,
          user2Status1: 0,
          user2Status2: 0,
          user2Status3: 0,
          winner: 'あなたの勝利');
    }
  }
  // void updatelist()

}

final battlePageProvider =
    StateNotifierProvider<BattlePageStateNotifier, BattlePageState>((ref) {
  return BattlePageStateNotifier();
});
