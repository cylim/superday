//
//  CalendarViewController.swift
//  teferi
//
//  Created by Krzysztof Kryniecki on 11/28/16.
//  Copyright © 2016 Toggl. All rights reserved.
//

import UIKit
import JTAppleCalendar
import RxSwift
let kCalendarViewController = "kCalendarViewController"

class CalendarViewController: UIViewController
{
    // MARK: Fields
    @IBOutlet weak fileprivate var calendarView: JTAppleCalendarView!
    @IBOutlet weak private var monthLabel: UILabel!
    fileprivate let endDate = Date().getStart()
    fileprivate var testCalendar = Calendar(identifier: .gregorian)
    var startDate: Date = Date().getStart()
    fileprivate var viewModel: CalendardViewModel!
    var dateObservable: Observable<Date> { return self.viewModel.dateObservable }
    var shouldHideObservable: Observable<Bool> { return self.viewModel.shouldHideObservable }

    func inject(startDate: Date,
        currentDate: Date, timeSlotService: TimeSlotService)
    {
        self.viewModel = CalendardViewModel(timeSlotService: timeSlotService)
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

    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
    }

    private func setDate()
    {
        let month = testCalendar.dateComponents([.month], from: self.viewModel.selectedDate).month!
        let monthName = DateFormatter().monthSymbols[(month-1) % 12] //GetHumanDate(month: month)//
        let year = testCalendar.component(.year, from: self.startDate)
        self.monthLabel.text = "\(monthName) \(year)"
    }

    private func setCalendar()
    {
        self.calendarView.dataSource = self
        self.calendarView.delegate = self
        self.calendarView.registerCellViewXib(file: "CalendarCellView")
        self.calendarView.cellInset = CGPoint(x: 0, y: 0)
        self.calendarView.itemSize = 41.0
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    fileprivate func setupViewsOfCalendar(from visibleDates: DateSegmentInfo)
    {
        guard let startDate = visibleDates.monthDates.first else
        {
            return
        }
        let month = testCalendar.dateComponents([.month], from: startDate).month!
        let monthName = DateFormatter().monthSymbols[(month-1) % 12] //GetHumanDate(month: month)
        let year = testCalendar.component(.year, from: startDate)
        self.monthLabel.text = "\(monthName) \(year)"
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
extension CalendarViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool
    {
        if let view = touch.view, view.isDescendant(of: self.calendarView)
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
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy MM dd"

        let parameters = ConfigurationParameters(startDate: self.startDate,
                                                 endDate: self.endDate,
                                                 numberOfRows: 6,
                                                 calendar: testCalendar,
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
            timeSlots: self.viewModel.getTimeSlots(date: date))
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
            timeSlots: self.viewModel.getTimeSlots(date: date))
    }

    func calendar(_ calendar: JTAppleCalendarView,
                  didScrollToDateSegmentWith visibleDates: DateSegmentInfo)
    {
        self.setupViewsOfCalendar(from: visibleDates)
    }
}
