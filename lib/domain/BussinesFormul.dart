import 'dart:async';

import 'package:flutter_app/presentation/Data.dart';
import 'package:flutter_app/presentation/Models.dart';
import 'package:flutter_app/utils/Prefs.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

List<ModelTimer> getListTrain(SharedPreferences prefs) {
  String name ="Flutter";
  int preparationTime = prefs.getInt(Prefs.PREPARATION_TIME.toString()) ?? 2;
  int setCount = prefs.getInt(Prefs.SET_COUNT.toString()) ?? 2;
  int cycleCount = prefs.getInt(Prefs.CYCLE_COUNT.toString()) ?? 2;
  int workTime = prefs.getInt(Prefs.WORK_TIME.toString()) ?? 2;
  int restTime = prefs.getInt(Prefs.REST_TIME.toString()) ?? 2;
  int restBetweenSetsCount =
      prefs.getInt(Prefs.REST_BETWEEN_SETS_COUNT.toString()) ?? 2;

  ModelHistory historyModel = new ModelHistory(
    name: name,
    cycleCount: cycleCount,
    restTime: restTime,
    setCount: setCount,
    workTime: workTime,
    time: new DateTime.now().millisecondsSinceEpoch,
  );
  DB.save(historyModel);
  NW.save(historyModel);

  List<ModelTimer> trainList = new List();

  for (int currentPreparationTime = 1;
      currentPreparationTime <= preparationTime;
      currentPreparationTime++) {
    var timeInterval;
    if (currentPreparationTime == 1) {
      timeInterval = TIME_INTERVAL.START;
    } else {
      timeInterval = TIME_INTERVAL.NORMAL;
    }

    ModelTimer modelTimer = new ModelTimer();
    modelTimer.type = TYPE.PREPARATION_TIME;
    modelTimer.maxValue = preparationTime;
    modelTimer.timeSec = preparationTime + 1 - currentPreparationTime;
    modelTimer.timeInterval = timeInterval;
    trainList.add(modelTimer);
  }

  for (int curSetCount = 1; curSetCount <= setCount; curSetCount++) {
    for (int curCycleCount = 1; curCycleCount <= cycleCount; curCycleCount++) {
      for (int curWorkTime = 1; curWorkTime <= workTime; curWorkTime++) {
        var timeInterval;
        if (curWorkTime == 1) {
          timeInterval = TIME_INTERVAL.START;
        } else {
          timeInterval = TIME_INTERVAL.NORMAL;
        }
        ModelTimer modelTimer = new ModelTimer();
        modelTimer.type = TYPE.WORK_TIME;
        modelTimer.maxValue = workTime;
        modelTimer.timeSec = workTime + 1 - curWorkTime;
        modelTimer.timeInterval = timeInterval;
        modelTimer.cycleCount = curCycleCount;
        modelTimer.setCount = curSetCount;
        trainList.add(modelTimer);
      }

      for (int curRestTime = 1; curRestTime <= restTime; curRestTime++) {
        var timeInterval;
        if (curRestTime == 1) {
          timeInterval = TIME_INTERVAL.START;
        } else {
          timeInterval = TIME_INTERVAL.NORMAL;
        }
        ModelTimer modelTimer = new ModelTimer();
        modelTimer.type = TYPE.REST_TIME;
        modelTimer.maxValue = restTime;
        modelTimer.timeSec = restTime + 1 - curRestTime;
        modelTimer.timeInterval = timeInterval;
        modelTimer.cycleCount = curCycleCount;
        modelTimer.setCount = curSetCount;
        trainList.add(modelTimer);
      }
    }

    for (int curBetweenTime = 1;
        curBetweenTime <= restBetweenSetsCount;
        curBetweenTime++) {
      var timeInterval;
      if (curBetweenTime == 1) {
        timeInterval = TIME_INTERVAL.START;
      } else {
        timeInterval = TIME_INTERVAL.NORMAL;
      }
      ModelTimer modelTimer = new ModelTimer();
      modelTimer.maxValue = restBetweenSetsCount;
      modelTimer.type = TYPE.REST_BETWEEN_SETS_COUNT;
      modelTimer.timeSec = restBetweenSetsCount + 1 - curBetweenTime;
      modelTimer.timeInterval = timeInterval;
      modelTimer.setCount = curSetCount;
      trainList.add(modelTimer);
    }
  }
  print(trainList.length.toString());
  new Observable<ModelTimer>.fromIterable(trainList)
      .listen((modelTimer) => print(modelTimer.type.toString()));
  return trainList;
}
