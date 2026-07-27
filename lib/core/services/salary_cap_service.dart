import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/team.dart';

enum CapStatus { underCap, overCap, firstApron, secondApron }

class CapSnapshot {
  const CapSnapshot({
    required this.payroll,
    required this.cap,
    required this.firstApron,
    required this.secondApron,
    required this.status,
    required this.taxOwed,
    required this.capSpace,
  });

  final int payroll;
  final int cap;
  final int firstApron;
  final int secondApron;
  final CapStatus status;
  final int taxOwed;
  final int capSpace;
}

class SalaryCapService {
  const SalaryCapService({this.balance = BalanceConfig.defaults});

  final BalanceConfig balance;

  CapSnapshot snapshot(Team team) {
    final b = balance.salaryCap;
    final payroll = team.roster.fold<int>(0, (s, p) => s + p.contract.salary);
    final CapStatus status;
    if (payroll >= b.secondApron) {
      status = CapStatus.secondApron;
    } else if (payroll >= b.firstApron) {
      status = CapStatus.firstApron;
    } else if (payroll > b.salaryCap) {
      status = CapStatus.overCap;
    } else {
      status = CapStatus.underCap;
    }
    return CapSnapshot(
      payroll: payroll,
      cap: b.salaryCap,
      firstApron: b.firstApron,
      secondApron: b.secondApron,
      status: status,
      taxOwed: taxFor(payroll),
      capSpace: b.salaryCap - payroll,
    );
  }

  int taxFor(int payroll) {
    final b = balance.salaryCap;
    if (payroll <= b.salaryCap) return 0;
    var tax = 0.0;
    final overCap = (payroll - b.salaryCap).clamp(0, b.firstApron - b.salaryCap);
    tax += overCap * b.taxToFirstApron;
    if (payroll > b.firstApron) {
      final overFirst = (payroll - b.firstApron).clamp(
        0,
        b.secondApron - b.firstApron,
      );
      tax += overFirst * b.taxToSecondApron;
    }
    if (payroll > b.secondApron) {
      tax += (payroll - b.secondApron) * b.taxAboveSecondApron;
    }
    return tax.round();
  }

  bool canSign({
    required Team team,
    required int salary,
    CapExceptionType? exception,
  }) {
    final snap = snapshot(team);
    if (snap.payroll + salary <= snap.cap) return true;
    if (exception == CapExceptionType.birdRights &&
        team.finance.activeExceptions.any(
          (e) =>
              e.type == CapExceptionType.birdRights &&
              e.amountRemaining >= salary,
        )) {
      return true;
    }
    if (exception == CapExceptionType.midLevelException &&
        team.finance.midLevelExceptionAvailable &&
        salary <= team.finance.midLevelExceptionAmount) {
      return true;
    }
    if (exception == CapExceptionType.rookieScale) return true;
    return false;
  }

  Team applyPayroll(Team team) {
    final payroll = team.roster.fold<int>(0, (s, p) => s + p.contract.salary);
    return team.copyWith(finance: team.finance.copyWith(totalPayroll: payroll));
  }
}
