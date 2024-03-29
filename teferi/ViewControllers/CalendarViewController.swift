import UIKit
import JTAppleCalendar
import RxSwift

class CalendarViewController : UIViewController, UIGestureRecognizerDelegate, JTAppleCalendarViewDelegate, JTAppleCalendarViewDataSource
{
    // MARK: Fields
    private let calendarCell = "CalendarCell"
    
    @IBOutlet weak private var monthLabel : UILabel!
    @IBOutlet weak private var leftButton : UIButton!
    @IBOutlet weak private var rightButton : UIButton!
    @IBOutlet weak private var dayOfWeekLabels : UIStackView!
    @IBOutlet weak private var calendarView : JTAppleCalendarView!
    
    private lazy var viewsToAnimate : [ UIView ] =
    {
        let result : [ UIView ] = [
            self.calendarView,
            self.monthLabel,
            self.dayOfWeekLabels,
            self.leftButton,
            self.rightButton
        ]
            
        return result
    }()
    
    private var layer = CAGradientLayer()
    private var disposeBag = DisposeBag()
    private var viewModel : CalendarViewModel!
    private var calendarCellsShouldAnimate = false
    
    // MARK: Properties
    var isVisible = false
    
    func inject(viewModel: CalendarViewModel)
    {
        self.viewModel = viewModel
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        let layerWhiteFadePoint = Float(self.calendarView.frame.maxY / UIScreen.main.bounds.height)
        
        self.layer.frame = self.view.frame
        self.layer.colors = [ Color.white.cgColor,
                              Color.white.cgColor,
                              Color.white.withAlphaComponent(0.5).cgColor,
                              Color.white.withAlphaComponent(0.5).cgColor]
        
        self.layer.locations = [0.0,
                                NSNumber(value: layerWhiteFadePoint),
                                NSNumber(value: layerWhiteFadePoint + 0.001),
                                1.0]
        
        self.view.layer.insertSublayer(layer, at: 0)
        
        //Configures the calendar
        self.calendarView.dataSource = self
        self.calendarView.delegate = self
        self.calendarView.registerCellViewXib(file: self.calendarCell)
        self.calendarView.cellInset = CGPoint(x: 1.5, y: 2)
        self.calendarView.scrollToDate(self.viewModel.maxValidDate)
        
        self.leftButton.rx.tap
            .subscribe(onNext: self.onLeftClick)
            .addDisposableTo(self.disposeBag)
        
        self.rightButton.rx.tap
            .subscribe(onNext: self.onRightClick)
            .addDisposableTo(self.disposeBag)
        
        self.viewModel
            .currentVisibleCalendarDateObservable
            .subscribe(onNext: self.onCurrentCalendarDateChanged)
            .addDisposableTo(self.disposeBag)
        
        self.viewModel
            .dateObservable
            .subscribe(onNext: self.onCurrentlySelectedDateChanged)
            .addDisposableTo(self.disposeBag)
        
        self.calendarView.reloadData()
    }
    
    func hide()
    {
        guard self.isVisible else { return }
        
        DelayedSequence
            .start()
            .then(self.fadeOverlay(fadeIn: false))
            .then(self.fadeElements(fadeIn: false))
            .then(self.toggleInteraction(enable: false))
    }
    
    func show()
    {
        guard !self.isVisible else { return }
        
        self.slideCalendarCells()
        
        DelayedSequence
            .start()
            .then(self.fadeOverlay(fadeIn: true))
            .after(0.105, self.fadeElements(fadeIn: true))
            .then(self.toggleInteraction(enable: true))
    }
    
    //MARK: Animations
    private func fadeOverlay(fadeIn: Bool) -> (TimeInterval) -> ()
    {
        let alpha = CGFloat(fadeIn ? 1 : 0)
        return { delay in UIView.animate(withDuration: 0.225, delay: delay) { self.view.alpha = alpha } }
    }
    
    private func fadeElements(fadeIn: Bool) -> (TimeInterval) -> ()
    {
        let yDiff = CGFloat(fadeIn ? 0 : -20)
        let alpha = CGFloat(fadeIn ? 1.0 : 0.0)
        
        return { delay in
            
            UIView.animate(withDuration: 0.225, delay: delay)
            {
                self.viewsToAnimate.forEach { v in
                    v.alpha = alpha
                    v.transform = CGAffineTransform(translationX: 0, y: yDiff)
                }
            }
        }
    }
    
    private func slideCalendarCells()
    {
        self.calendarCellsShouldAnimate = true
        self.calendarView.reloadData()
        DispatchQueue.main.async { self.calendarCellsShouldAnimate = false }
    }
    
    private func toggleInteraction(enable: Bool) -> (Double) -> ()
    {
        return { delay in
            
            Timer.schedule(withDelay: delay)
            {
                self.isVisible = enable
                self.view.isUserInteractionEnabled = enable
                self.view.superview?.isUserInteractionEnabled = enable
            }
        }
    }
    
    //MARK: Rx methods
    private func onLeftClick()
    {
        self.calendarView.scrollToPreviousSegment(true, animateScroll: true, completionHandler: nil)
    }
    
    private func onRightClick()
    {
        self.calendarView.scrollToNextSegment(true, animateScroll: true, completionHandler: nil)
    }
    
    private func onCurrentCalendarDateChanged(_ date: Date)
    {
        let layerWhiteFadePoint = self.calculateWhiteFadePoint(forDate: date)
        
        self.layer.locations = [0.0,
                                NSNumber(value: layerWhiteFadePoint),
                                NSNumber(value: layerWhiteFadePoint + 0.001),
                                1.0]
        
        self.monthLabel.attributedText = self.getHeaderName(forDate: date)
        
        self.leftButton.alpha = date.month == self.viewModel.minValidDate.month ? 0.2 : 1.0
        self.rightButton.alpha =  date.month == self.viewModel.maxValidDate.month ? 0.2 : 1.0
    }
    
    private func onCurrentlySelectedDateChanged(_ date: Date)
    {
        self.calendarView.selectDates([date])
        self.hide()
    }
    
    private func calculateWhiteFadePoint(forDate date: Date) -> Float
    {
        let startDay = (date.dayOfWeek + 6) % 7
        let daysInMonth = date.daysInMonth
        var numberOfRows = (startDay + daysInMonth) / 7
        
        if (startDay + daysInMonth) % 7 != 0 { numberOfRows += 1 }
        
        return Float(CGFloat(140 + 39 * numberOfRows) / UIScreen.main.bounds.height)
    }
    
    private func getHeaderName(forDate date: Date) -> NSMutableAttributedString
    {
        let monthName = DateFormatter().monthSymbols[(date.month - 1) % 12]
        let result = NSMutableAttributedString(string: "\(monthName) ",
                                               attributes: [ NSForegroundColorAttributeName: UIColor.black ])
        
        result.append(NSAttributedString(string: String(date.year),
                                         attributes: [ NSForegroundColorAttributeName: Color.offBlackTransparent ]))
        
        return result
    }
    
    //MARK: UIGestureRecognizerDelegate implementation
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool
    {
        if let view = touch.view,
            view.isDescendant(of: self.calendarView) ||
            view.isDescendant(of: self.leftButton) ||
            view.isDescendant(of: self.rightButton)
        {
            return false
        }
        
        self.hide()
        return true
    }
    
    //MARK: JTAppleCalendarDelegate implementation
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters
    {
        let parameters = ConfigurationParameters(startDate: self.viewModel.minValidDate,
                                                 endDate: self.viewModel.maxValidDate,
                                                 numberOfRows: 6,
                                                 calendar: nil,
                                                 generateInDates: .forAllMonths,
                                                 generateOutDates: .tillEndOfGrid,
                                                 firstDayOfWeek: .monday)
        return parameters
    }
    
    func calendar(_ calendar: JTAppleCalendarView, willDisplayCell cell: JTAppleDayCellView, date: Date, cellState: CellState)
    {
        guard let calendarCell = cell as? CalendarCell else { return }
        
        self.update(cell: calendarCell, toDate: date, row: cellState.row(), belongsToMonth: cellState.dateBelongsTo == .thisMonth)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleDayCellView?, cellState: CellState)
    {
        self.viewModel.selectedDate = date
        calendar.reloadData()
        
        guard let calendarCell = cell as? CalendarCell else { return }
        
        self.update(cell: calendarCell, toDate: date, row: cellState.row(), belongsToMonth: cellState.dateBelongsTo == .thisMonth)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo)
    {
        guard let startDate = visibleDates.monthDates.first else { return }
        
        self.viewModel.currentVisibleCalendarDate = startDate
    }
    
    private func update(cell: CalendarCell, toDate date: Date, row: Int, belongsToMonth: Bool)
    {
        guard belongsToMonth else
        {
            cell.reset(allowScrollingToDate: false)
            return
        }
        
        let canScrollToDate = self.viewModel.canScroll(toDate: date)
        let activities = self.viewModel.getActivities(forDate: date)
        let isSelected = Calendar.current.isDate(date, inSameDayAs: self.viewModel.selectedDate)
        
        cell.bind(toDate: date, isSelected: isSelected, allowsScrollingToDate: canScrollToDate, dailyActivity: activities)
        
        guard self.calendarCellsShouldAnimate else { return }
        
        cell.alpha = 0
        cell.transform = CGAffineTransform(translationX: -20, y: 0)
        
        UIView.animate(withDuration: 0.225, delay: 0.05 + (Double(row) / 20.0))
        {
            cell.alpha = 1
            cell.transform = CGAffineTransform(translationX: 0, y: 0)
        }
    }
}
