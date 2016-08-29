import UIKit

class BaseViewController<ViewModelType : BaseViewModel> : UIViewController
{
    var viewModel : ViewModelType?
    
    func createViewModel() -> ViewModelType?
    {
        return nil;
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
     
        viewModel = createViewModel()
        viewModel!.start()
    }
}