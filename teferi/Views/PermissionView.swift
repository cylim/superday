import UIKit
import RxSwift

class PermissionView : UIView
{
    //MARK: Fields
    private let titleKey = "LocationDisabledTitle"
    private let descriptionKey = "LocationDisabledDescription"
    private let titleFirstUseKey = "LocationDisabledTitleFirstUse"
    private let descriptionFirstUseKey = "LocationDisabledDescriptionFirstUse"
    
    private var isFirstTimeUser = false
    private var remindMeLaterCallback : (() -> ())!
    
    private var titleText : String
    {
        return (self.isFirstTimeUser ? titleFirstUseKey : titleKey).translate()
    }
    
    private var descriptionText : String
    {
        return (self.isFirstTimeUser ? descriptionFirstUseKey : descriptionKey).translate()
    }
    
    @IBOutlet private weak var blur : UIView!
    @IBOutlet private weak var titleLabel : UILabel!
    @IBOutlet private weak var descriptionLabel : UILabel!
    @IBOutlet private weak var remindLaterButton : UIButton!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        let layer = CAGradientLayer()
        layer.frame = self.blur.frame
        layer.colors = [ Color.white.withAlphaComponent(0).cgColor, Color.white.cgColor]
        layer.locations = [0.0, 1.0]
        self.blur.layer.addSublayer(layer)
    }
    
    //MARK: Methods
    @IBAction func enableLocation()
    {
        let url = URL(string: UIApplicationOpenSettingsURLString)!
        UIApplication.shared.openURL(url)
    }
    
    @IBAction func remindMeLater()
    {
        self.remindMeLaterCallback()
        self.fadeView()
    }
    
    func fadeView()
    {
        UIView.animate(withDuration: Constants.editAnimationDuration,
                       animations: { self.alpha = 0 },
                       completion: { _ in self.removeFromSuperview() })
    }
    
    func inject(_ frame: CGRect, _ remindMeLaterCallback: @escaping () -> (), isFirstTimeUser: Bool) -> PermissionView
    {
        self.frame = frame
        self.isFirstTimeUser = isFirstTimeUser
        self.remindMeLaterCallback = remindMeLaterCallback
        
        self.titleLabel.text = self.titleText
        self.descriptionLabel.text = self.descriptionText
        self.remindLaterButton.isHidden = self.isFirstTimeUser
        return self
    }
}
