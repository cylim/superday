import RxSwift
import RxCocoa
import RxDataSources
import UIKit

class TimelineViewController : UITableViewController
{
    // MARK: Properties
    var date : NSDate
    {
        return viewModel.date
    }
    
    // MARK: Fields
    private let viewModel : TimelineViewModel
    private let baseCellHeight = 37
    private let cellIdentifier = "timelineCell"
    private let disposeBag = DisposeBag()
    private let dataSource = RxTableViewSectionedDataSource<SectionModel<String, TimeSlot>>()
    
    init(date: NSDate)
    {
        viewModel = TimelineViewModel(date: date, persistencyService: CoreDataPersistencyService.instance)
        super.init(style: .Plain)
    }
    
    required init?(coder: NSCoder)
    {
        viewModel = TimelineViewModel(date: NSDate(), persistencyService: CoreDataPersistencyService.instance)
        super.init(style: .Plain)
    }
    
    // MARK: UIViewController lifecycle
    override func viewDidLoad() 
    {
        super.viewDidLoad()

        tableView.separatorStyle = .None
        tableView.allowsSelection = false
        tableView.registerNib(UINib.init(nibName: "TimelineCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: cellIdentifier)
        
        viewModel
            .timeSlotsObservable
            .bindTo(tableView.rx_itemsWithCellIdentifier(cellIdentifier))(configureCell: configureCell)
            .addDisposableTo(disposeBag)
    }
    
    // MARK: Methods
    func addNewSlot(category: Category)
    {
        viewModel.addNewSlot(category)
    }
    
    private func configureCell(row: Int, timeSlot: TimeSlot, cell: TimelineCell)
    {
        cell.bindTimeSlot(timeSlot)
    }
    
    // MARK: UITableViewDataSource methods
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle
    {
        return .None
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        let interval = Int(viewModel.timeSlots[indexPath.item].duration)
        let hours = (interval / 3600)
        let minutes = (interval / 60) % 60
        let height = baseCellHeight + TimelineCell.minLineSize * (1 + (minutes / 15) + (hours * 4))
        
        return CGFloat(height)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! TimelineCell;
        let timeSlot = viewModel.timeSlots[indexPath.item]
        cell.bindTimeSlot(timeSlot)
        return cell
    }
}