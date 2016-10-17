import UIKit

class OnboardingPager: UIView
{
    @IBOutlet private weak var nextButton: UIButton!
    
    func clearButtonText()
    {
        self.nextButton.setTitle(" ", for: .normal)
    }
    
    func hideNextButton()
    {
        self.nextButton.isEnabled = false
        UIView.animate(withDuration: 0.2)
        {
            self.nextButton.alpha = 0
            self.nextButton.setTitle(" ", for: .normal)
        }
    }
    
    func showNextButton(withText text: String)
    {
        self.nextButton.isEnabled = true
        UIView.animate(withDuration: 0.2)
        {
            self.nextButton.setTitle(text, for: .normal)
            self.nextButton.alpha = 1
        }
    }
}
