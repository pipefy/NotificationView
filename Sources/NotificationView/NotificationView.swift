//
//  NotificationView.swift
//  NotificationView
//
//

import UIKit

//  MARK: - UTILITY
public extension NotificationView {
    
    class func show(
        data: NotificationData?,
        onTap: (() -> Void)? = nil,
        onDidDismiss: (() -> Void)? = nil
    ) -> NotificationView? {
        
        guard let _data = data else {
            return nil
        }
        
        /// New notification view
        let notiView = NotificationView(
            appearance: NotificationAppearance.defaultAppearance,
            notiData: _data
        )
        
        notiView.onTabHandleBlock = onTap
        notiView.onDidDismissBlock = onDidDismiss
        
        notiView.notiData = data
        notiView.loadingNotificationData()
        
        notiView.show(onComplete: nil)
        
        return notiView
    }
}

//  MARK: - NOTIFICATION VIEW
public class NotificationView: UIView {
    
    fileprivate static var _curNotiView: NotificationView?
    
    var appearance: NotificationAppearance
    var notiData: NotificationData?
    
    var constraintMarginTop: NSLayoutConstraint?
    var viewBorderedContainer: UIView!
    var imgIcon: UIImageView!
    var lblTitle: UILabel!
    var lblMessage: UILabel!
    var lblTime: UILabel!
    var imgThumb: UIImageView?
    
    var tapGesture: UITapGestureRecognizer?
    var panGesture: UIPanGestureRecognizer?
    
    var onTabHandleBlock: (() -> Void)?
    var onDidDismissBlock: (() -> Void)?
    

    init(appearance: NotificationAppearance, notiData: NotificationData?) {
        
        self.appearance = appearance
        self.notiData = notiData
        
        super.init(frame: appearance.viewInitRect(notiData: notiData))
        self._layoutSubViews()
    }
    required init?(coder aDecoder: NSCoder) {
        
        self.appearance = NotificationAppearance.defaultAppearance
        
        super.init(coder: aDecoder)
        self._layoutSubViews()
    }
    
    //  MARK: - LAYOUT SUBVIEWS

    private func _layoutSubViews() {
        
        _layoutBackground()
        _layoutImageIcon()
        _layoutLabelTitle()
        _layoutLabelMessage()
        _layoutLabelTime()
        _layoutImageThumb()
        
        _setUpTapGesture()
        _setUpPanGesture()
    }
    private func _layoutBackground() {
        
        let _appearance = self.appearance
        
        /// Bordered view container
        self.viewBorderedContainer = UIView()
        self.viewBorderedContainer.layer.cornerRadius = _appearance.viewRoundCornerRadius
        self.viewBorderedContainer.clipsToBounds = true
        
        self.addSubview(self.viewBorderedContainer)
        self.viewBorderedContainer.pinEdgesToSuperview()
        
        /// Blur view
        let blurView = UIVisualEffectView()
        blurView.effect = UIBlurEffect(style: _appearance.backgroundType.blurEffectType())
        self.viewBorderedContainer.addSubview(blurView)
        blurView.pinEdgesToSuperview()
        
        /// Shadown
        self.clipsToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.3
        self.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
    }
    private func _layoutImageIcon() {
        
        let _appearance = self.appearance
        
        let imgIcon = UIImageView(frame: CGRect(origin: CGPoint.zero, size: _appearance.iconSize))
        imgIcon.layer.cornerRadius = _appearance.iconRoundCornerRadius
        imgIcon.clipsToBounds = true
        self.imgIcon = imgIcon
        imgIcon.translatesAutoresizingMaskIntoConstraints = false
        self.viewBorderedContainer.addSubview(imgIcon)
        let margin = _appearance.iconMargin
        if let superview = imgIcon.superview {
            NSLayoutConstraint.activate([
                imgIcon.topAnchor.constraint(equalTo: superview.topAnchor, constant: margin.top),
                imgIcon.leftAnchor.constraint(equalTo: superview.leftAnchor, constant: margin.left),
                imgIcon.heightAnchor.constraint(equalToConstant: _appearance.iconSize.height),
                imgIcon.widthAnchor.constraint(equalToConstant: _appearance.iconSize.width)
            ])

        }
    }
    private func _layoutLabelTitle() {
        
        let _appearance = self.appearance
        
        let lblTitle = UILabel()
        lblTitle.textColor = _appearance.titleTextColor
        lblTitle.font = _appearance.titleTextFont
        self.lblTitle = lblTitle
        lblTitle.translatesAutoresizingMaskIntoConstraints = false
        
        self.viewBorderedContainer.addSubview(lblTitle)

        NSLayoutConstraint.activate([
            lblTitle.centerYAnchor.constraint(equalTo: self.imgIcon.centerYAnchor),
            lblTitle.leadingAnchor.constraint(equalTo: self.imgIcon.trailingAnchor,
                                              constant: _appearance.titleMargin.left)
        ])
    }
    private func _layoutLabelMessage() {
        
        let _appearance = self.appearance
        
        let lblMessage = UILabel()
        lblMessage.textColor = _appearance.messageTextColor
        lblMessage.numberOfLines = _appearance.messageTextLineNum
        self.lblMessage = lblMessage
        lblMessage.translatesAutoresizingMaskIntoConstraints = false
        
        self.viewBorderedContainer.addSubview(lblMessage)
        let margin = _appearance.messageMargin
        if let superview = lblMessage.superview {
            NSLayoutConstraint.activate([
                lblMessage.leadingAnchor.constraint(equalTo: superview.leadingAnchor,
                                                    constant: margin.left),
                lblMessage.trailingAnchor.constraint(equalTo: superview.trailingAnchor,
                                                     constant: margin.right),
                lblMessage.topAnchor.constraint(equalTo: self.imgIcon.bottomAnchor,
                                                constant: margin.top),
                lblMessage.bottomAnchor.constraint(lessThanOrEqualTo: superview.bottomAnchor)
            ])
        }
    }
    private func _layoutLabelTime() {
        
        let _appearance = self.appearance
        
        let lblTime = UILabel()
        lblTime.textColor = _appearance.timeTextColor
        lblTime.font = _appearance.timeTextFont
        self.lblTime = lblTime
        
        let layoutPriority = lblTime.contentCompressionResistancePriority(for: .horizontal)
        let newLayoutPriority = UILayoutPriority(layoutPriority.rawValue + 1.0)
        lblTime.setContentCompressionResistancePriority(newLayoutPriority, for: .horizontal)
        lblTime.translatesAutoresizingMaskIntoConstraints = false
        self.viewBorderedContainer.addSubview(lblTime)

        let margin = _appearance.timeMargin
        if let superview = lblTime.superview {
            NSLayoutConstraint.activate([
                lblTime.trailingAnchor.constraint(equalTo: superview.trailingAnchor,
                                                    constant: -margin.right),
                lblTime.centerYAnchor.constraint(equalTo: self.lblTitle.centerYAnchor),
                lblTime.leadingAnchor.constraint(greaterThanOrEqualTo: self.lblTitle.trailingAnchor,
                                                 constant: margin.left)
            ])
        }
    }
    private func _layoutImageThumb() {
        
    }
    
    //  MARK: - LOADING CONTENT
    /// ----------------------------------------------------------------------------------
    func loadingNotificationData() {
        
        guard let _notiData = self.notiData else {
            return
        }
        
        let _appearance = self.appearance
        
        /// Icon
        self.imgIcon.image = _notiData.iconImage
        
        /// App Title
        self.lblTitle.text = _notiData.appTitle
        
        /// Title + Message
        self.lblMessage.attributedText = _appearance.messageAttributedStringFrom(title: _notiData.title, message: _notiData.message)
        
        /// Time
        self.lblTime.text = _notiData.time
    }
    
    //  MARK: - TAP GESTURE
    /// ----------------------------------------------------------------------------------
    private func _setUpTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(_handleTapGesture(gesture:)))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.numberOfTouchesRequired = 1
        
        self.addGestureRecognizer(tapGesture)
        self.tapGesture = tapGesture
    }
    @objc private func _handleTapGesture(gesture: UITapGestureRecognizer) {
        
        switch gesture.state {
        case .began:
            break
            
        case .ended:
            /// Dismiss
            self.dismiss(animated: true, onComplete: nil)
            
            /// Callback
            self.onTabHandleBlock?()
            self.onTabHandleBlock = nil
            
        case .possible, .cancelled, .failed, .changed:
            break

        }
    }
    
    //  MARK: - PAN GESTURE
    /// ----------------------------------------------------------------------------------
    private func _setUpPanGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(_handlePanGesture(gesture:)))
        panGesture.delegate = self
        
        self.addGestureRecognizer(panGesture)
        self.panGesture = panGesture
    }
    @objc private func _handlePanGesture(gesture: UIPanGestureRecognizer) {
        
        switch gesture.state {
        case .began:
            self._invalidateTimer()
            
        case .changed:
            guard let _constraintMarginTop = self.constraintMarginTop else {
                return
            }
            let translation = gesture.translation(in: self)
            var newConstraintConstant = _constraintMarginTop.constant + translation.y
            newConstraintConstant = min(newConstraintConstant, self.appearance.viewMargin.top)
            _constraintMarginTop.constant = newConstraintConstant
            
            gesture.setTranslation(CGPoint.zero, in: self)
            
        case .ended:
            /// Dismiss
            if self.frame.minY < -35.0 {
                self.dismiss(animated: true, onComplete: nil)
            }
                
            /// No dimiss
            else {
                self._setUpTimerScheduleToDismiss(halfTime: true)
                self._returnToDisplayPosition(animated: true, onComplete: nil)
            }
            
        case .possible, .cancelled, .failed:
            self._setUpTimerScheduleToDismiss(halfTime: true)
        }
    }
    
    //  MARK: - SHOW
    /// ----------------------------------------------------------------------------------
    public func show(onComplete: (() -> Void)?) {
        
        /// Hide current notification view if needed
        if let __curNotiView = NotificationView._curNotiView {
            __curNotiView.dismiss(animated: false, onComplete: nil)
        }
        
        /// Pre-condition
        guard let _notiData = self.notiData else {
            return
        }
        guard let _keyWindow = UIApplication.shared.keyWindow else {
            return
        }
        let _appearance = self.appearance
        
        _keyWindow.windowLevel = .statusBar
        
        _keyWindow.addSubview(self)
        self.translatesAutoresizingMaskIntoConstraints = false

        let margin = _appearance.viewMargin
        if let superview = self.superview {
            NSLayoutConstraint.activate([
                self.leadingAnchor.constraint(equalTo: superview.leadingAnchor,
                                              constant: margin.left),
                self.trailingAnchor.constraint(equalTo: superview.trailingAnchor,
                                              constant: margin.right),
                self.heightAnchor.constraint(
                    equalToConstant: _appearance.viewSizeHeigth(notiData: _notiData)
                )
            ])
            self.constraintMarginTop = self.topAnchor.constraint(
                equalTo: superview.topAnchor,
                constant: _appearance.viewMarginTopPreDisplay(notiData: _notiData)
            )
            self.constraintMarginTop?.isActive = true
        }

        self.layoutIfNeeded()
        
        /// Saving
        NotificationView._curNotiView = self
        
        /// Animation
        self.constraintMarginTop?.constant = _appearance.viewMargin.top
        UIView.animate(
            withDuration: _appearance.animationDuration,
            delay: 0.0,
            options: .curveEaseOut,
            animations: {
                _keyWindow.layoutIfNeeded()
        },
            completion: { (finished) in

        })
        
        /// Shedule to dismiss
        self._setUpTimerScheduleToDismiss(halfTime: false)
    }
    
    //  MARK: - DISMISS
    /// ----------------------------------------------------------------------------------
    public func dismiss(animated: Bool, onComplete: (() -> Void)?) {
        
        self._invalidateTimer()
        
        guard let _notiData = self.notiData else {
            return
        }
        guard let _keyWindow = UIApplication.shared.keyWindow else {
            return
        }
        let _appearance = self.appearance
        
        /// Reset and callback
        func _resetAndCallback() {
            self.removeFromSuperview()
            UIApplication.shared.keyWindow?.windowLevel = .normal
            
            self.onDidDismissBlock?()
            onComplete?()
        }
        
        /// Animate dismiss
        if animated {
            NotificationView._curNotiView = nil
            
            self.constraintMarginTop?.constant = _appearance.viewMarginTopPreDisplay(notiData: _notiData)
            UIView.animate(
                withDuration: _appearance.animationDuration,
                delay: 0.0,
                options: .curveEaseOut,
                animations: {
                    _keyWindow.layoutIfNeeded()
                },
                completion: { (finished) in
                    _resetAndCallback()
                })
        }
        else {
            NotificationView._curNotiView = nil
            _resetAndCallback()
        }
    }
    
    private func _returnToDisplayPosition(animated: Bool, onComplete: (() -> Void)?) {
        
        guard let _keyWindow = UIApplication.shared.keyWindow else {
            return
        }
        let _appearance = self.appearance
        
        /// Animation
        self.constraintMarginTop?.constant = _appearance.viewMargin.top
        if animated {
            UIView.animate(
                withDuration: _appearance.returnPositionAnimationDuration,
                delay: 0.0,
                options: .curveEaseOut,
                animations: {
                    _keyWindow.layoutIfNeeded()
            },
                completion: { (finished) in
                    onComplete?()
            })
        }
        else {
            onComplete?()
        }
    }
    
    //  MARK: - TIMER
    /// ----------------------------------------------------------------------------------
    private var _timer: Timer?
    private func _invalidateTimer() {
        self._timer?.invalidate()
        self._timer = nil
    }
    private func _setUpTimerScheduleToDismiss(halfTime: Bool) {
        self._invalidateTimer()
        
        let _appearance = self.appearance
        self._timer = Timer.scheduledTimer(
            timeInterval: !halfTime ? _appearance.appearingDuration : _appearance.appearingDuration/2.0,
            target: self,
            selector: #selector(_handleTimerSheduleToDismiss),
            userInfo: nil,
            repeats: false)
        
    }
    @objc private func _handleTimerSheduleToDismiss() {
        self.dismiss(animated: true, onComplete: nil)
    }
}

/// ----------------------------------------------------------------------------------
//  MARK: - GESTURE DELEGATE
/// ----------------------------------------------------------------------------------
extension NotificationView: UIGestureRecognizerDelegate {
    
    public override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        guard let _panGesture = self.panGesture, gestureRecognizer == _panGesture else {
            return super.gestureRecognizerShouldBegin(gestureRecognizer)
        }

        return _panGesture.velocity(in: self).y < 0.0
    }
}
