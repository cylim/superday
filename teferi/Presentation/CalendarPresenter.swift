import Foundation
import UIKit

class CalendarPresenter
{
    static func hideCalendar(mainViewController: MainViewController,
                             calendarViewController: CalendarViewController?,
                             completion:(() -> Void)? )
    {
        if let calendarController = calendarViewController
        {
            calendarController.didMove(toParentViewController: mainViewController)
            mainViewController.view.isUserInteractionEnabled = false
            calendarController.view.snp.removeConstraints()
            UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations:
                {
                    calendarController.view.alpha = 0.0
                    calendarController.view.snp.makeConstraints(
                        {   (make) in
                            make.top.equalTo(64)
                            make.left.equalTo(mainViewController.view.snp.left)
                            make.width.equalTo(mainViewController.view.snp.width)
                            make.height.equalTo(0)
                    })
                    mainViewController.view.layoutIfNeeded()
            }, completion:
                {   (finished) in
                    calendarController.isVisble = false
                    calendarController.view.snp.removeConstraints()
                    calendarController.willMove(toParentViewController: nil)
                    calendarController.view.removeFromSuperview()
                    calendarController.removeFromParentViewController()
                    mainViewController.view.isUserInteractionEnabled = true
                    completion?()
            })
        }
    }

    static func showCalendar(mainViewController: MainViewController,
                              calendarViewController: CalendarViewController?,
                              aboveView: UIView)
    {
        if let calendarController = calendarViewController
        {
            mainViewController.view.insertSubview(calendarController.view, aboveSubview:aboveView)
            mainViewController.addChildViewController(calendarController)
            calendarController.didMove(toParentViewController: mainViewController)
            mainViewController.view.isUserInteractionEnabled = false
            calendarController.view.snp.makeConstraints
                {   make in
                    make.top.equalTo(64)
                    make.left.equalTo(mainViewController.view.snp.left)
                    make.width.equalTo(mainViewController.view.snp.width)
                    make.height.equalTo(0)
            }
            mainViewController.view.layoutIfNeeded()
            calendarController.view.snp.removeConstraints()
            UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5,
                           initialSpringVelocity: 1,
                           options: .curveEaseInOut,
                           animations:
                {
                    calendarController.view.snp.makeConstraints(
                        { (make) in
                            make.top.equalTo(64)
                            make.left.equalTo(mainViewController.view.snp.left)
                            make.width.equalTo(mainViewController.view.snp.width)
                            make.bottom.equalTo(mainViewController.view.snp.bottom)
                    })
                    calendarController.view.alpha = 1.0
                    mainViewController.view.layoutIfNeeded()
            }, completion:
                { (finished) in
                    calendarController.isVisble = true
                    mainViewController.view.isUserInteractionEnabled = true
            })
        }
    }
}
