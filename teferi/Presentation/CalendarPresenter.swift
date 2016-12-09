import Foundation
import UIKit

class CalendarPresenter
{
    static func hideCalendar(mainViewController: MainViewController, calendarViewController: CalendarViewController)
    {
        calendarViewController.view.superview!.isUserInteractionEnabled = false
        calendarViewController.view.isHidden = true
        calendarViewController.view.isUserInteractionEnabled = false
    }
    
    static func showCalendar(mainViewController: MainViewController,
                             calendarViewController: CalendarViewController,
                             aboveView: UIView)
    {
        calendarViewController.view.superview!.isUserInteractionEnabled = true
        calendarViewController.view.isHidden = false
        calendarViewController.view.isUserInteractionEnabled = true
    }
}
