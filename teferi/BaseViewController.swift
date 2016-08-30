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
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        createBindings()
    }
    
    override func viewWillDisappear(animated: Bool) {
        clearBindings()
        super.viewWillDisappear(animated)
    }
    
    func createBindings()
    {
        
    }
    
    func clearBindings()
    {
        
    }
}