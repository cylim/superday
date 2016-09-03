import UIKit

class TimelineViewController : UITableViewController
{
    private let cellIdentifier = "timelineCell"
    private let viewModel = TimelineViewModel()
    
    override func viewDidLoad()
    {
        tableView.separatorStyle = .None
        tableView.allowsSelection = false
        tableView.registerNib(UINib.init(nibName: "TimelineCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: cellIdentifier)
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return CGFloat(180)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {   
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! TimelineCell;
        let timeSlot = viewModel.timeSlots[indexPath.item]
        cell.bindTimeSlot(timeSlot)
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return viewModel.timeSlots.count
    }
}