import RxSwift
import RxCocoa
import UIKit
import CoreGraphics

class TimelineViewController : UITableViewController
{
    // MARK: Properties
    var date : Date
    {
        return viewModel.date
    }
    
    // MARK: Fields
    private let baseCellHeight = 40
    private let disposeBag = DisposeBag()
    private let viewModel : TimelineViewModel
    private let cellIdentifier = "timelineCell"
    private let isEditingVariable : Variable<Bool>
    
    private var currentlyEditingIndex = -1
    private lazy var footerCell : UITableViewCell = { return UITableViewCell(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 120)) }()
    
    init(date: Date, metricsService: MetricsService, persistencyService: PersistencyService, isEditingVariable: Variable<Bool>)
    {
        self.isEditingVariable = isEditingVariable
        self.viewModel = TimelineViewModel(date: date,
                                           metricsService: metricsService,
                                           persistencyService: persistencyService)
        
        super.init(style: .plain)
    }
    
    required init?(coder: NSCoder)
    {
        fatalError("NSCoder init is not supported for this ViewController")
    }
    
    // MARK: UIViewController lifecycle
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.tableView.separatorStyle = .none
        self.tableView.allowsSelection = false
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.showsHorizontalScrollIndicator = false
        self.tableView.register(UINib.init(nibName: "TimelineCell", bundle: Bundle.main), forCellReuseIdentifier: cellIdentifier)
        
        self.viewModel
            .timeSlotsObservable
            .subscribe(onNext: onNewTimeSlotAvailable)
            .addDisposableTo(disposeBag)
        
        self.viewModel
            .timeObservable
            .subscribe(onNext: onTimeTick)
            .addDisposableTo(disposeBag)
        
        self.isEditingVariable
            .asObservable()
            .subscribe(onNext: onIsEditing)
            .addDisposableTo(disposeBag)
    }
    
    // MARK: Methods
    func onCategoryChange(atIndex index: Int, category: Category)
    {
        guard viewModel.updateTimeSlot(atIndex: index, withCategory: category) else { return }
        isEditingVariable.value = false
    }
    
    private func onNewTimeSlotAvailable(timeSlots: [TimeSlot])
    {
        self.tableView.reloadData()
        
        let updateIndexPath = IndexPath(row: viewModel.timeSlots.count - 1, section: 0)
        let scrollIndexPath = IndexPath(row: viewModel.timeSlots.count, section: 0)
        
        self.tableView.reloadRows(at: [updateIndexPath], with: .top)
        self.tableView.scrollToRow(at: scrollIndexPath, at: .bottom, animated: true)
    }
    
    private func onIsEditing(isEditing: Bool)
    {
        self.tableView.isEditing = isEditing
        self.tableView.isScrollEnabled = !isEditing
        self.currentlyEditingIndex = isEditing ? self.currentlyEditingIndex : -1
        
        self.tableView.reloadSections(IndexSet(integer: 0), with: .fade)
    }
    
    private func onTimeTick(time: Int)
    {
        guard !tableView.isEditing else { return }
        
        let indexPath = IndexPath(row: viewModel.timeSlots.count - 1, section: 0)
        self.tableView.reloadRows(at: [indexPath], with: .fade)
    }
    
    private func onCategoryTapped(index: Int)
    {
        if tableView.isEditing
        {
            guard index == currentlyEditingIndex else { return }
            self.isEditingVariable.value = false
        }
        else
        {
            self.currentlyEditingIndex = index
            self.isEditingVariable.value = true
        }
    }
    
    // MARK: UITableViewDataSource methods
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle
    {
        return .none
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return viewModel.timeSlots.count + 1
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let index = indexPath.item
        
        if index == viewModel.timeSlots.count { return footerCell }
        
        let timeSlot = viewModel.timeSlots[index]
        let categoryIsBeingEdited = index == currentlyEditingIndex
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! TimelineCell;
        
        cell.bind(toTimeSlot: timeSlot, shouldFade: tableView.isEditing, index: index, isEditingCategory: categoryIsBeingEdited)
        
        if !cell.isSubscribedToClickObservable
        {
            cell.editClickObservable
                .subscribe(onNext: onCategoryTapped)
                .addDisposableTo(disposeBag)
            
            cell.onCategoryChange = onCategoryChange
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        let index = indexPath.item
        
        if index == viewModel.timeSlots.count { return 120 }
        
        let timeSlot = viewModel.timeSlots[index]
        let isRunning = timeSlot.endTime == nil
        let interval = Int(timeSlot.duration)
        let hours = (interval / 3600)
        let minutes = (interval / 60) % 60
        let height = baseCellHeight
            + Constants.minLineSize * (1 + (minutes / 15) + (hours * 4))
            + (isRunning ? 8 : 0)
        
        return CGFloat(height)
    }
}
