import Nimble
import RxSwift
import XCTest
@testable import teferi

class OnboardingPageViewControllerTests : XCTestCase
{
    private var onBoardingPageViewController : OnboardingPageViewController!
    private var notificationService : MockNotificationService!
    
    override func setUp()
    {
        super.setUp()
        
        let storyboard = UIStoryboard(name: "Onboarding", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "OnboardingPager") as! OnboardingPageViewController
        
        self.notificationService = MockNotificationService()
        self.onBoardingPageViewController = controller.inject(MockTimeService(),
                                                              MockSettingsService(),
                                                              DefaultAppStateService(),
                                                              MainViewController(),
                                                              self.notificationService)
        
        self.onBoardingPageViewController.loadViewIfNeeded()
        UIApplication.shared.keyWindow!.rootViewController = onBoardingPageViewController
    }
    
    func testTheGoToNextPageMethodNavigatesBetweenPages()
    {
        let page = self.onBoardingPageViewController.viewControllers!.first!
        self.onBoardingPageViewController.goToNextPage()
        
        expect(self.onBoardingPageViewController.viewControllers!.first).toNot(equal(page))
    }
    
    func testTheFirstPageOftheViewControllerAllowsSwipingRight()
    {
        let page = self.onBoardingPageViewController.pages[0]
        
        let nextPage = self.onBoardingPageViewController
            .pageViewController(self.onBoardingPageViewController, viewControllerBefore: page)
        
        expect(nextPage).to(beNil())
    }
    
    func testTheThirdPageOftheViewControllerDoesNotAllowSwipingRight()
    {
        let page = self.onBoardingPageViewController.pages[2]
        
        let nextPage = self.onBoardingPageViewController
            .pageViewController(self.onBoardingPageViewController, viewControllerBefore: page)
        
        expect(nextPage).to(beNil())
    }
    
    func testTheThirdPageOftheViewControllerDoesNotAllowSwipingLeft()
    {
        let page = self.onBoardingPageViewController.pages[2]
        
        let previousPage = self.onBoardingPageViewController
                               .pageViewController(self.onBoardingPageViewController, viewControllerAfter: page)

        expect(previousPage).to(beNil())
    }
}
