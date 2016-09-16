import RxSwift
import RxCocoa
import UIKit

class TimelineViewController : UITableViewController
{
    // MARK: Properties
    var date : Date
    {
        return viewModel.date as Date
    }
    
    // MARK: Fields
    fileprivate let viewModel : TimelineViewModel
    fileprivate let baseCellHeight = 37
    fileprivate let cellIdentifier = "timelineCell"
    fileprivate let disposeBag = DisposeBag()
    
    init(date: Date)
    {
        viewModel = TimelineViewModel(date: date, persistencyService: CoreDataPersistencyService.instance)
        super.init(style: .plain)
    }
    
    required init?(coder: NSCoder)
    {
        viewModel = TimelineViewModel(date: Date(), persistencyService: CoreDataPersistencyService.instance)
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
            .bindTo(tableView.rx.items(cellIdentifier: cellIdentifier))(configureCell)
            .addDisposableTo(disposeBag)
    }
    
    // MARK: Methods
    func addNewSlot(_ category: Category)
    {
        viewModel.addNewSlot(category)
    }
    
    fileprivate func configureCell(_ row: Int, timeSlot: TimeSlot, cell: TimelineCell)
    {
        cell.bindTimeSlot(timeSlot)
    }
    
    // MARK: UITableViewDataSource methods
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle
    {
        return .none
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        let interval = Int(viewModel.timeSlots[(indexPath as NSIndexPath).item].duration)
        let hours = (interval / 3600)
        let minutes = (interval / 60) % 60
        let height = baseCellHeight + TimelineCell.minLineSize * (1 + (minutes / 15) + (hours * 4))
        
        return CGFloat(height)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! TimelineCell;
        let timeSlot = viewModel.timeSlots[(indexPath as NSIndexPath).item]
        cell.bindTimeSlot(timeSlot)
        return cell
    }
}
