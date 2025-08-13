extends Node
class_name XRange

var centerX: float
var leftX: float
var rightX: float
var radius: float

func set_from_center(centerX_: float, radius_: float) -> void:
    self.centerX = centerX_
    self.radius = radius_
    self.leftX = centerX - radius_
    self.rightX = centerX + radius_

func refresh() -> void:
    centerX = (leftX + rightX) / 2
    radius = (rightX - leftX) / 2

func in_range(targetX: float) -> bool:
    return targetX > leftX and targetX < rightX

func is_overlapping(other: XRange) -> bool:
    return in_range(other.leftX) or in_range(other.rightX)

func substract(target: XRange): # 호출자가 차지하는 범위 중 target이 차지하는 범위를 제외
    if in_range(target.leftX):
        rightX = target.leftX
    elif in_range(target.rightX):
        leftX = target.rightX
    refresh()

# pond, bush, hdf, tdf