import UIKit
import JTAppleCalendar
import RxSwift
let kCalendarViewController = "kCalendarViewController"

class CalendarViewController: UIViewController
{
    // MARK: Fields
    @IBOutlet weak fileprivate var calendarView: JTAppleCalendarView!
    @IBOutlet weak private var monthLabel: UILabel!
    @IBOutlet weak fileprivate var leftButton: UIButton!
    @IBOutlet weak fileprivate var rightButton: UIButton!
    fileprivate let endDate = Date().getStart()
    fileprivate var startDate: Date = Date().getStart()
    fileprivate var viewModel: CalendarViewModel!
    
    // MARK: Properties
    var isVisble: Bool = false
    var dateObservable: Observable<Date> { return self.viewModel.dateObservable }
    var shouldHideObservable: Observable<Bool> { return self.viewModel.shouldHideObservable }

    func inject(startDate: Date,
        currentDate: Date, timeSlotService: TimeSlotService)
    {
        self.viewModel = CalendarViewModel(timeSlotService: timeSlotService)
        self.startDate = startDate
        self.viewModel.selectedDate = currentDate
    }

    func update(startDate: Date, currentDate: Date)
    {
        self.startDate = startDate
        self.viewModel.selectedDate = currentDate
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.setCalendar()
    }

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        self.setDate()
        self.calendarView.reloadData()
    }

    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
    }

    private func setDate()
    {
        self.setupHeader(date: self.viewModel.selectedDate)
    }

    private func setCalendar()
    {
        self.calendarView.dataSource = self
        self.calendarView.delegate = self
        self.calendarView.registerCellViewXib(file: "CalendarCellView")
        self.calendarView.cellInset = CGPoint(x: 1.5, y: 2)
    }
    
    func setupHeader(date: Date)
    {
        self.monthLabel.attributedText = self.viewModel.getAttributedHeaderName(date: date)
        if date.month == self.startDate.month
        {
            self.leftButton.alpha = 0.2
        } else
        {
            self.leftButton.alpha = 1
        }
        if date.month == self.endDate.month
        {
            self.rightButton.alpha = 0.2
        } else
        {
            self.rightButton.alpha = 1
        }
    }
    
    fileprivate func setupViewsOfCalendar(from visibleDates: DateSegmentInfo)
    {
        guard let startDate = visibleDates.monthDates.first else
        {
            return
        }
        self.setupHeader(date: startDate)
    }

    @IBAction func onPrevMonthPressed(_ sender: Any)
    {
        self.calendarView.scrollToPreviousSegment(true, animateScroll: true, completionHandler: nil)
    }

    @IBAction func onNextMonthPressed(_ sender: Any)
    {
        self.calendarView.scrollToNextSegment(true, animateScroll: true, completionHandler: nil)
    }
}
extension CalendarViewController: UIGestureRecognizerDelegate
{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool
    {
        if let view = touch.view,
            view.isDescendant(of: self.calendarView) ||
            view.isDescendant(of: self.leftButton) ||
            view.isDescendant(of: self.rightButton)
        {
                return false
        }
        self.viewModel.shouldHide = true
        return true
    }
}
// MARK : JTAppleCalendarDelegate
extension CalendarViewController: JTAppleCalendarViewDelegate, JTAppleCalendarViewDataSource
{
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters
    {
        let parameters = ConfigurationParameters(startDate: self.startDate,
                                                 endDate: self.endDate,
                                                 numberOfRows: 6,
                                                 calendar: nil,
                                                 generateInDates: .forAllMonths,
                                                 generateOutDates: .tillEndOfGrid,
                                                 firstDayOfWeek: .monday)
        return parameters
    }

    func calendar(_ calendar: JTAppleCalendarView,
                  willDisplayCell cell: JTAppleDayCellView,
                  date: Date, cellState: CellState)
    {
        (cell as? CalendarCellView)?.updateCell(
            cellState: cellState,
            startDate: self.startDate,
            date: date,
            selectedDate: self.viewModel.selectedDate,
            categorySlots: self.viewModel.getCategoriesSlots(date: date))
    }
    
    func calendar(_ calendar: JTAppleCalendarView,
                  didSelectDate date: Date,
                  cell: JTAppleDayCellView?,
                  cellState: CellState)
    {
        self.viewModel.selectedDate = date
        calendar.reloadData()
        (cell as? CalendarCellView)?.updateCell(
            cellState: cellState,
            startDate: self.startDate,
            date: date,
            selectedDate: date,
            categorySlots: self.viewModel.getCategoriesSlots(date: date))
    }

    func calendar(_ calendar: JTAppleCalendarView,
                  didScrollToDateSegmentWith visibleDates: DateSegmentInfo)
    {
        self.setupViewsOfCalendar(from: visibleDates)
    }
}
