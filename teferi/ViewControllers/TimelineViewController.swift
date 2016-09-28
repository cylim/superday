import RxSwift
import RxCocoa
import UIKit

class TimelineViewController : UITableViewController
{
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
 
    // MARK: Properties
    var date : Date
    {
        return viewModel.date
    }
    
    // MARK: Fields
    private let viewModel : TimelineViewModel
    private let baseCellHeight = 37
    private let cellIdentifier = "timelineCell"
    private let disposeBag = DisposeBag()
    private var currentlyEditingIndex = -1
    
    init(date: Date)
    {
        viewModel = TimelineViewModel(date: date, persistencyService: self.appDelegate.persistencyService)
        super.init(style: .plain)
    }
    
    required init?(coder: NSCoder)
    {
        viewModel = TimelineViewModel(date: Date(), persistencyService: self.appDelegate.persistencyService)
        super.init(style: .plain)
    }
    
    // MARK: UIViewController lifecycle
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.register(UINib.init(nibName: "TimelineCell", bundle: Bundle.main), forCellReuseIdentifier: cellIdentifier)
        
        viewModel
            .timeSlotsObservable
            .subscribe(onNext: onNewTimeSlotAvailable)
            .addDisposableTo(disposeBag)
        
        viewModel
            .timeObservable
            .subscribe(onNext: onTimeTick)
            .addDisposableTo(disposeBag)
        
        self.appDelegate
            .isEditingObservable
            .subscribe(onNext: onIsEditing)
            .addDisposableTo(disposeBag)
    }
    
    // MARK: Methods
    func addNewSlot(withCategory category: Category)
    {
        viewModel.addNewSlot(withCategory: category)
    }
    
    func onCategoryChange(index: Int, category: Category)
    {
        guard viewModel.updateTimeSlot(atIndex: index, withCategory: category) else { return }
        
        self.appDelegate.isEditing = false
    }
    
    private func onNewTimeSlotAvailable(_ timeSlots: [TimeSlot])
    {
        let indexPath = IndexPath(row: viewModel.timeSlots.count - 1, section: 0)
        self.tableView.reloadRows(at: [indexPath], with: .fade)
    }
    
    private func onIsEditing(_ isEditing: Bool)
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
            self.appDelegate.isEditing = false
        }
        else
        {
            self.currentlyEditingIndex = index
            self.appDelegate.isEditing = true
        }
    }
    
    // MARK: UITableViewDataSource methods
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle
    {
        return .none
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return viewModel.timeSlots.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let index = indexPath.item
        let timeSlot = viewModel.timeSlots[index]
        let categoryIsBeingEdited = index == currentlyEditingIndex
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! TimelineCell;
        
        cell.bind(withTimeSlot: timeSlot, shouldFade: tableView.isEditing, index: index, isEditingCategory: categoryIsBeingEdited)
        
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
        let interval = Int(viewModel.timeSlots[(indexPath as NSIndexPath).item].duration)
        let hours = (interval / 3600)
        let minutes = (interval / 60) % 60
        let height = baseCellHeight + Constants.minLineSize * (1 + (minutes / 15) + (hours * 4))
        
        return CGFloat(height)
    }
}
