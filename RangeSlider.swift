//
//  RangeSlider.swift
//
//  Created by Barry Chen on 2019/11/28.

import UIKit

class RangeSlider: UIControl {
    /// The minimum possible value in range
    var minimumValue: CGFloat = 100 {
        didSet {
            updateLayerFrames()
        }
    }
    /// The maximum possible value in range
    var maximumValue: CGFloat = 10000 {
        didSet {
            updateLayerFrames()
        }
    }
    /// The current lower value, must be less than upperValue.
    var lowerValue: CGFloat = 200 {
        didSet {
            if lowerValue < minimumValue {
                lowerValue = minimumValue
            }
            sendActions(for: .valueChanged)
            layoutSubviews()
        }
    }
    /// The current upper value, must be greater than lowerValue.
    var upperValue: CGFloat = 9000 {
        didSet {
            if upperValue > maximumValue {
                upperValue = maximumValue
            }
            sendActions(for: .valueChanged)
            layoutSubviews()
        }
    }

    /// This represent the minimum gap percentage between two handles.
    /// The default value is 0, and the maximum value is 0.2.
    var minimumGapPercentage: CGFloat = 0 {
        didSet {
            if minimumGapPercentage < 0 {
                minimumGapPercentage = 0
            } else if minimumGapPercentage > 0.2 {
                minimumGapPercentage = 0.2
            }
        }
    }
    /// Set the slider line height, defalut value is 2.
    var lineHeight: CGFloat = 2 {
        didSet {
            if lineHeight < 1 {
                lineHeight = 1
            }
        }
    }
    /// Set the slider tint color.
    var trackTintColor = UIColor(white: 0.9, alpha: 1) {
        didSet {
            updateColors()
        }
    }
    /// Set the slider tint color between two handle.
    var trackHighlightTintColor = UIColor(red: 0, green: 0.45, blue: 0.94, alpha: 1) {
        didSet {
            updateColors()
        }
    }
    /// The custom handle image, defult is nil.
    var handleImage: UIImage? = nil {
        didSet {
            guard let image = handleImage else { return }

            var handleFrame: CGRect = .zero
            handleFrame.size = image.size

            leftHandle.frame = handleFrame
            leftHandle.contents = image.cgImage

            rightHandle.frame = handleFrame
            rightHandle.contents = image.cgImage
        }
    }

    /// The handle diameter, default is 20.
    var handleDiameter: CGFloat = 20 {
        didSet {
            updateLayerFrames()
        }
    }
    /// The handle border width, default is 2.
    var handleBorderWidth: CGFloat = 2
    /// The handle bordder color, default is theme color.
    var handleBorderColor: UIColor? = ColorPalette.shared.theme {
        didSet {
            updateLayerFrames()
        }
    }
    var handleFillColor: UIColor? = .white {
        didSet {
            updateLayerFrames()
        }
    }


    private let trackLayer = CALayer()
    private let trackHighlightLayer = CALayer()

    private let leftHandle = CALayer()
    private let rightHandle = CALayer()

    private let padding: CGFloat = 16

    private enum HandleTracking { case none, left, right }
    private var handleTracking: HandleTracking = .none

    override var frame: CGRect {
        didSet {
            updateLayerFrames()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if handleTracking == .none {
            updateLineHeight()
            updateHandlePosition()
        }
    }

    private func setUp() {
        trackLayer.contentsScale = UIScreen.main.scale
        trackLayer.cornerRadius = 4
        trackHighlightLayer.contentsScale = UIScreen.main.scale
        layer.addSublayer(trackLayer)
        layer.addSublayer(trackHighlightLayer)

        layer.addSublayer(leftHandle)
        layer.addSublayer(rightHandle)

        updateLayerFrames()
        updateColors()
    }

    private func updateLayerFrames() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)

        updateLineHeight()
        trackLayer.setNeedsDisplay()
        leftHandle.backgroundColor = handleFillColor?.cgColor
        rightHandle.backgroundColor = handleFillColor?.cgColor
        leftHandle.borderColor = handleBorderColor?.cgColor
        rightHandle.borderColor = handleBorderColor?.cgColor
        leftHandle.borderWidth = handleBorderWidth
        rightHandle.borderWidth = handleBorderWidth
        leftHandle.cornerRadius = handleDiameter / 2.0
        rightHandle.cornerRadius = handleDiameter / 2.0
        leftHandle.frame = CGRect(
            origin: handleOriginForValue(lowerValue),
            size: CGSize(width: handleDiameter, height: handleDiameter))
        rightHandle.frame = CGRect(
            origin: handleOriginForValue(upperValue),
            size: CGSize(width: handleDiameter, height: handleDiameter))
        trackHighlightLayer.frame = CGRect(x: leftHandle.frame.center.x,
                                           y: trackLayer.frame.minY,
                                           width: rightHandle.frame.center.x - leftHandle.frame.center.x,
                                           height: trackLayer.frame.height)
        trackHighlightLayer.setNeedsDisplay()
        CATransaction.commit()
    }

    private func updateLineHeight() {
        let midY = (bounds.height / 2) - (lineHeight / 2)
        trackLayer.frame = CGRect(x: padding, y: midY, width: bounds.width - (padding*2), height: lineHeight)
        trackLayer.cornerRadius = lineHeight / 2
    }

    private func updateHandlePosition() {
        rightHandle.position = CGPoint(x: handleOriginForValue(upperValue).x + handleDiameter / 2, y: trackLayer.frame.midY)
        leftHandle.position = CGPoint(x: handleOriginForValue(lowerValue).x + handleDiameter / 2, y: trackLayer.frame.midY)
        trackHighlightLayer.frame = CGRect(x: leftHandle.frame.center.x,
                                           y: trackLayer.frame.minY,
                                           width: rightHandle.frame.center.x - leftHandle.frame.center.x,
                                           height: trackLayer.frame.height)
    }

    private func percentageAlongTrack(for value: CGFloat) -> CGFloat {
        guard minimumValue < maximumValue else { return 0 }
        let totalValue = maximumValue - minimumValue
        let valueSubstracted = value - minimumValue
        return valueSubstracted / totalValue
    }

    private func positionForValue(_ value: CGFloat) -> CGFloat {
        let offset = trackLayer.frame.width * percentageAlongTrack(for: value)
        let position = trackLayer.frame.minX + offset - handleDiameter / 2
        return position
    }

    private func handleOriginForValue(_ value: CGFloat) -> CGPoint {
        let x = positionForValue(value)
        return CGPoint(x: x, y: (bounds.height - handleDiameter) / 2.0)
    }

    private func updateColors() {
        trackLayer.backgroundColor = trackTintColor.cgColor
        trackHighlightLayer.backgroundColor = trackHighlightTintColor.cgColor
    }
}

extension RangeSlider {
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let touchLocation = touch.location(in: self)
        // Expand the handle touch detectable area
        let insetExpansion: CGFloat = -30
        let leftHandleCenterPoint = leftHandle.frame.center
        let rightHandleCenterPoint = rightHandle.frame.center
        let distanceFromLeftHandle: CGFloat = hypot(touchLocation.x - leftHandleCenterPoint.x, touchLocation.y - leftHandleCenterPoint.y)
        let distanceFromRightHandle: CGFloat = hypot(touchLocation.x - rightHandleCenterPoint.x, touchLocation.y - rightHandleCenterPoint.y)

        let isTouchingLeftHandle: Bool = leftHandle.frame.insetBy(dx: insetExpansion, dy: insetExpansion).contains(touchLocation)
        let isTouchingRightHandle: Bool = rightHandle.frame.insetBy(dx: insetExpansion, dy: insetExpansion).contains(touchLocation)
        guard isTouchingLeftHandle || isTouchingRightHandle else { return false }

        if  distanceFromLeftHandle < distanceFromRightHandle {
            handleTracking = .left
        } else if upperValue == maximumValue && leftHandleCenterPoint == rightHandleCenterPoint {
            handleTracking = .left
        } else {
            handleTracking = .right
        }
        return true
    }

    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let location = touch.location(in: self)
        let percentage: CGFloat = (location.x - trackLayer.frame.minX - handleDiameter / 2) / (trackLayer.frame.width)
        let selectValue = percentage * (maximumValue - minimumValue) + minimumValue
        // 2
        let isHaveMinimumGap: Bool = minimumGapPercentage > 0
        if handleTracking == .left {
            let maxValue = isHaveMinimumGap ? upperValue - (minimumGapPercentage * (maximumValue - minimumValue) + minimumValue) : upperValue
            lowerValue = min(selectValue, maxValue)
        } else if handleTracking == .right {
            let minValue = isHaveMinimumGap ? lowerValue + (minimumGapPercentage * (maximumValue - minimumValue) + minimumValue) : lowerValue
            upperValue = max(selectValue, minValue)
        }
        updateLayerFrames()
        sendActions(for: .valueChanged)
        return true
    }

    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        handleTracking = .none
    }
}

// MARK: - CGRect
private extension CGRect {
    var center: CGPoint {
        return CGPoint(x: midX, y: midY)
    }
}
