import '../../data/data.dart';
import '../base/base.dart';

class SettingState extends BaseState implements Copyable<SettingState> {
  final bool? isMeow;
  final OrderType? orderType;
  final List<ImageType>? imageTypes;
  final bool? isChange;
  final int? patternIndex;

  SettingState({
    this.isMeow,
    this.orderType,
    this.imageTypes,
    this.isChange,
    this.patternIndex,
  });

  @override
  SettingState copy() {
    return this;
  }

  @override
  SettingState copyWith({
    bool? isMeow,
    OrderType? orderType,
    List<ImageType>? imageTypes,
    bool? isChange,
    int? patternIndex,
  }) {
    return SettingState(
      isMeow: isMeow ?? this.isMeow,
      orderType: orderType ?? this.orderType,
      imageTypes: imageTypes ?? this.imageTypes,
      isChange: isChange ?? this.isChange,
      patternIndex: patternIndex ?? this.patternIndex,
    );
  }

  @override
  // TODO: implement props
  List<Object?> get props => [
        isMeow,
        orderType,
        imageTypes?.hashCode,
        isChange,
        patternIndex,
      ];
}
