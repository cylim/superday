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
    private let viewModel : TimelineViewModel
    private let baseCellHeight = 37
    private let cellIdentifier = "timelineCell"
    private let disposeBag = DisposeBag()
    
    init(date: Date)
    {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        viewModel = TimelineViewModel(date: date, persistencyService: appDelegate.persistencyService)
        super.init(style: .plain)
    }
    
    required init?(coder: NSCoder)
    {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        viewModel = TimelineViewModel(date: Date(), persistencyService: appDelegate.persistencyService)
        super.init(style: .plain)
    }
    
    // MARK: UIViewController lifecycle
    override func viewDidLoad() 
    {
        super.viewDidLoad()
        
        tableView.dataSource = nil
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.register(UINib.init(nibName: "TimelineCell", bundle: Bundle.main), forCellReuseIdentifier: cellIdentifier)
        
        viewModel
            .timeSlotsObservable
            .bindTo(tableView.rx.items(cellIdentifier: cellIdentifier))(configureCell)
            .addDisposableTo(disposeBag)
        
        viewModel
            .timeObservable
            .subscribe(onNext: onTimeTick)
            .addDisposableTo(disposeBag)
    }
    
    // MARK: Methods
    func addNewSlot(withCategory category: Category)
    {
        viewModel.addNewSlot(withCategory: category)
    }
    
    private func onTimeTick(time: Int)
    {
        let indexPath = IndexPath(row: viewModel.timeSlots.count - 1, section: 0)
        self.tableView.reloadRows(at: [indexPath], with: .fade)
    }
    
    private func configureCell(_ row: Int, timeSlot: TimeSlot, cell: TimelineCell)
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
        let height = baseCellHeight + Constants.minLineSize * (1 + (minutes / 15) + (hours * 4))
        
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
