import UIKit
import JTAppleCalendar
import RxSwift
let kCalendarViewController = "kCalendarViewController"

class CalendarViewController : UIViewController, JTAppleCalendarViewDelegate, JTAppleCalendarViewDataSource
{
    // MARK: Fields
    @IBOutlet weak private var calendarView: JTAppleCalendarView!
    @IBOutlet weak private var monthLabel: UILabel!
    @IBOutlet weak private var leftButton: UIButton!
    @IBOutlet weak private var rightButton: UIButton!
    
    private var disposeBag = DisposeBag()
    private var viewModel : CalendarViewModel!
    
    // MARK: Properties
    var isVisible = false
    
    func inject(settingsService: SettingsService,
                timeSlotService: TimeSlotService,
                selectedDateService: SelectedDateService)
    {
        self.viewModel = CalendarViewModel(settingsService: settingsService,
                                           timeSlotService: timeSlotService,
                                           selectedDateService: selectedDateService)
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
        self.calendarView.registerCellViewXib(file: "CalendarCell")
        self.calendarView.cellInset = CGPoint(x: 1.5, y: 2)
        
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
    
    func toggle()
    {
        if self.isVisible
        {
            self.hide()
        }
        else
        {
            self.show()
        }
    }
    
    func hide()
    {
        guard self.isVisible else { return }

        self.view.superview!.isUserInteractionEnabled = false
        
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       options: [ .curveEaseIn ],
                       animations: { self.view.alpha = 0 },
                       completion: { completed in
                        
                        self.view.isHidden = true
                        self.view.isUserInteractionEnabled = false
                        self.isVisible = false
        })
    }
    
    func show()
    {
        guard !self.isVisible else { return }
        
        self.view.isHidden = false
        self.view.superview!.isUserInteractionEnabled = true
        
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       options: [ .curveEaseIn ],
                       animations: { self.view.alpha = 1 },
                       completion: { completed in
                        
                        self.view.isUserInteractionEnabled = true
                        self.isVisible = true

                        
        })
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
    
    private func onCurrentlySelectedDateChanged(_ date: Date)
    {
        self.calendarView.selectDates([date])
        self.calendarView.reloadData()
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
        guard let calendarCell = cell as? CalendarCell else { return }
        
        self.update(cell: calendarCell, toDate: date, belongsToMonth: cellState.dateBelongsTo == .thisMonth)
    }
    
    func calendar(_ calendar: JTAppleCalendarView,
                  didSelectDate date: Date,
                  cell: JTAppleDayCellView?,
                  cellState: CellState)
    {
        self.viewModel.selectedDate = date
        calendar.reloadData()
        
        guard let calendarCell = cell as? CalendarCell else { return }
        
        self.update(cell: calendarCell, toDate: date, belongsToMonth: cellState.dateBelongsTo == .thisMonth)
    }
    
    func calendar(_ calendar: JTAppleCalendarView,
                  didScrollToDateSegmentWith visibleDates: DateSegmentInfo)
    {
        guard let startDate = visibleDates.monthDates.first else { return }
        self.viewModel.currentVisibleCalendarDate = startDate
    }
    
    private func update(cell: CalendarCell, toDate date: Date, belongsToMonth: Bool)
    {
        guard belongsToMonth else
        {
            cell.reset()
            return
        }
        
        let slots = self.viewModel.getCategoriesSlots(forDate: date)
        let isSelected = Calendar.current.isDate(date, inSameDayAs: self.viewModel.selectedDate)
        
        cell.bind(toDate: date, isSelected: isSelected, categorySlots: slots)
        
    }
}
