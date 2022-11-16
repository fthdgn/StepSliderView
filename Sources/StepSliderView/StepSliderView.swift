import Foundation
import UIKit

@IBDesignable
public class StepSliderView: UIControl {
    @IBInspectable
    public var knobSize: CGFloat = 10 {
        didSet {
            invalidateIntrinsicContentSize()
            setNeedsLayout()
        }
    }
    
    @IBInspectable
    public var trackCircleSize: CGFloat = 5 {
        didSet {
            invalidateIntrinsicContentSize()
            setNeedsLayout()
        }
    }
    
    @IBInspectable
    public var trackHeight: CGFloat = 2 {
        didSet {
            invalidateIntrinsicContentSize()
            setNeedsLayout()
        }
    }
    
    @IBInspectable
    public var knobColor: UIColor? = nil {
        didSet {
            knobView.backgroundColor = knobColor ?? tintColor
        }
    }
    
    @IBInspectable
    public var trackColor: UIColor? = nil {
        didSet {
            trackView.backgroundColor = trackColor ?? tintColor
        }
    }
    
    @IBInspectable
    public var trackCircleColor: UIColor? = nil {
        didSet {
            trackCircleViews.forEach { $0.backgroundColor = trackCircleColor ?? tintColor }
        }
    }
    
    @IBInspectable
    public var minimumValue: Int = 0 {
        didSet {
            validateValue()
            setNeedsLayout()
        }
    }
    
    @IBInspectable
    public var maximumValue: Int = 10 {
        didSet {
            validateValue()
            setNeedsLayout()
        }
    }
    
    public var stepValue: Int = 1 {
        didSet {
            setNeedsLayout()
        }
    }
    
    @IBInspectable
    public var value: Int = 0 {
        didSet {
            if value == oldValue {
                return
            }
            validateValue()
            setNeedsLayout()
            sendActions(for: .valueChanged)
        }
    }
    
    @IBInspectable
    public var contentInsets: UIEdgeInsets = .init(top: 10, left: 0, bottom: 10, right: 0) {
        didSet {
            invalidateIntrinsicContentSize()
            setNeedsLayout()
        }
    }
    
    private func validateValue() {
        if value > maximumValue {
            value = maximumValue
        } else if value < minimumValue {
            value = minimumValue
        }
    }
    
    private let trackView: UIView = .init()
    private let knobView: UIView = .init()
    private var trackCircleViews: [UIView] = []
    
    override public var intrinsicContentSize: CGSize {
        return .init(width: UIView.noIntrinsicMetric, height: max(knobSize, trackHeight, trackCircleSize) + contentInsets.bottom + contentInsets.top)
    }
    
    init() {
        super.init(frame: .zero)
        initialized()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialized()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialized()
    }
    
    private func initialized() {
        addSubview(trackView)
        addSubview(knobView)
        
        addGestureRecognizer(GestureRecognizer(target: self, action: #selector(gestureRecognized(_:))))
    }
    
    @objc private func gestureRecognized(_ sender: GestureRecognizer) {
        let x = sender.location(in: self).x
        let baseStart = knobSize / 2 + contentInsets.left
        let baseEnd = bounds.width - knobSize / 2 - contentInsets.right
        let increment = (baseEnd - baseStart) / CGFloat(trackCircleViews.count - 1)
        value = minimumValue + Int(round((x - baseStart) / increment)) * stepValue
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        trackView.frame.size = .init(width: bounds.width - knobSize - contentInsets.left - contentInsets.right, height: trackHeight)
        trackView.center = .init(x: contentInsets.left + (bounds.width - contentInsets.left - contentInsets.right) / 2,
                                 y: contentInsets.top + (bounds.height - contentInsets.top - contentInsets.bottom) / 2)
        trackView.backgroundColor = trackColor ?? tintColor
        
        let trackCircleCount = (maximumValue - minimumValue) / stepValue + 1
        
        while trackCircleCount != trackCircleViews.count {
            if trackCircleCount > trackCircleViews.count {
                let view = UIView()
                addSubview(view)
                trackCircleViews.append(view)
            } else if trackCircleCount < trackCircleViews.count {
                trackCircleViews.popLast()?.removeFromSuperview()
            }
        }
        
        let baseStart = knobSize / 2 + contentInsets.left
        let baseEnd = bounds.width - knobSize / 2 - contentInsets.right
        let increment = (baseEnd - baseStart) / CGFloat(trackCircleViews.count - 1)
        for (index, view) in trackCircleViews.enumerated() {
            view.frame.size = .init(width: trackCircleSize, height: trackCircleSize)
            view.center = .init(x: baseStart + increment * CGFloat(index),
                                y: contentInsets.top + (bounds.height - contentInsets.top - contentInsets.bottom) / 2)
            view.layer.cornerRadius = trackCircleSize / 2
            view.backgroundColor = trackCircleColor ?? tintColor
        }
        
        knobView.frame.size = .init(width: knobSize, height: knobSize)
        knobView.center = .init(x: baseStart + increment * CGFloat(value - minimumValue) / CGFloat(stepValue),
                                y: contentInsets.top + (bounds.height - contentInsets.top - contentInsets.bottom) / 2)
        knobView.layer.cornerRadius = knobSize / 2
        knobView.backgroundColor = knobColor ?? tintColor
        bringSubviewToFront(knobView)
    }
    
    private class GestureRecognizer: UIGestureRecognizer {
        override func touchesBegan(_: Set<UITouch>, with _: UIEvent) {
            state = .began
        }
        
        override func touchesMoved(_: Set<UITouch>, with _: UIEvent) {
            state = .changed
        }
        
        override func touchesEnded(_: Set<UITouch>, with _: UIEvent) {
            state = .ended
        }
    }
}
