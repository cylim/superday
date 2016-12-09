import UIKit
import JTAppleCalendar
import RxSwift
let kCalendarViewController = "kCalendarViewController"

class CalendarViewController : UIViewController, UIGestureRecognizerDelegate, JTAppleCalendarViewDelegate, JTAppleCalendarViewDataSource
{
    // MARK: Fields
    @IBOutlet weak private var calendarView: JTAppleCalendarView!
    @IBOutlet weak private var monthLabel: UILabel!
    @IBOutlet weak private var leftButton: UIButton!
    @IBOutlet weak private var rightButton: UIButton!
    
    private var viewModel : CalendarViewModel!
    private var disposeBag : DisposeBag? = DisposeBag()
    
    // MARK: Properties
    var isVisible = false
    var shouldHideObservable: Observable<Bool> { return self.viewModel.shouldHideObservable }
    
    func inject(settingsService: SettingsService,
                timeSlotService: TimeSlotService,
                selectedDateService: SelectedDateService)
    {
        self.viewModel = CalendarViewModel(settingsService: settingsService,
                                           timeSlotService: timeSlotService,
                                           selectedDateService: selectedDateService)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        
        let layer = CAGradientLayer()
        layer.frame = self.view.frame
        layer.colors = [ Color.white.cgColor, Color.white.cgColor, Color.white.withAlphaComponent(0).cgColor]
        layer.locations = [0.0, 0.5, 1.0]
        self.view.layer.insertSublayer(layer, at: 0)
        
        
        //Configures the calendar
        self.calendarView.dataSource = self
        self.calendarView.delegate = self
        self.calendarView.registerCellViewXib(file: "CalendarCellView")
        self.calendarView.cellInset = CGPoint(x: 1.5, y: 2)
        
        self.leftButton.rx.tap
            .subscribe(onNext: self.onLeftClick)
            .addDisposableTo(disposeBag!)
        
        self.rightButton.rx.tap
            .subscribe(onNext: self.onRightClick)
            .addDisposableTo(disposeBag!)
        
        self.viewModel
            .currentVisibleCalendarDateObservable
            .subscribe(onNext: self.onCurrentCalendarDateChanged)
            .addDisposableTo(disposeBag!)
        
        self.view.isUserInteractionEnabled = false
        
        self.calendarView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        self.disposeBag = nil
        super.viewWillDisappear(animated)
    }
    
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
        self.monthLabel.attributedText = self.viewModel.getAttributedHeaderName(date: date)
        
        self.leftButton.alpha = date.month == self.viewModel.minValidDate.month ? 0.2 : 1.0
        self.rightButton.alpha =  date.month == self.viewModel.maxValidDate.month ? 0.2 : 1.0
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
        self.viewModel.shouldHide = true
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
    
    func calendar(_ calendar: JTAppleCalendarView,
                  willDisplayCell cell: JTAppleDayCellView,
                  date: Date, cellState: CellState)
    {
        (cell as? CalendarCellView)?.updateCell(
            cellState: cellState,
            startDate: self.viewModel.minValidDate,
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
            startDate: self.viewModel.minValidDate,
            date: date,
            selectedDate: date,
            categorySlots: self.viewModel.getCategoriesSlots(date: date))
    }
    
    func calendar(_ calendar: JTAppleCalendarView,
                  didScrollToDateSegmentWith visibleDates: DateSegmentInfo)
    {
        guard let startDate = visibleDates.monthDates.first else { return }
        self.viewModel.currentVisibleCalendarDate = startDate
    }
}
