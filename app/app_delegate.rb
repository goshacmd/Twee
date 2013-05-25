class AppDelegate
  def application(application, didFinishLaunchingWithOptions:launchOptions)
    @window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)

    @navigationController = UINavigationController.alloc.init
    @navigationController.pushViewController(TimelineController.controller, animated:false)

    @window.rootViewController = @navigationController
    @window.makeKeyAndVisible

    showAccountSelectorController unless account

    true
  end

  def showAccountSelectorController
    @accountSelectorController = AccountSelectorController.alloc.init
    @accountSelectorNavigationController = UINavigationController.alloc.init
    @accountSelectorNavigationController.pushViewController(@accountSelectorController, animated:false)

    TimelineController.controller.presentModalViewController(@accountSelectorNavigationController, animated:false)
  end

  def account
    @account ||= Account.find(App::Persistence['account_id'])
  end

  def reset_account
    App::Persistence['account_id'] = nil
  end
end
