class AccountSelectorController < UIViewController
  def self.controller
    @controller ||= alloc.initWithNibName(nil, nundle:nil)
  end

  def viewDidLoad
    super

    self.title = 'Select a Twitter account'
    view.backgroundColor = UIColor.whiteColor

    @table = UITableView.alloc.initWithFrame(view.bounds, style:UITableViewStyleGrouped)
    @table.autoresizingMask = UIViewAutoresizingFlexibleHeight
    @table.dataSource = self
    @table.delegate = self

    view.addSubview(@table)

    refreshButton = UIBarButtonItem.alloc.initWithBarButtonSystemItem(
      UIBarButtonSystemItemRefresh, target:self, action:'reload_accounts'
    )
    navigationItem.rightBarButtonItem = refreshButton

    twitter_accounts
    try_pick_account
  end

  def reload_accounts
    @accounts = nil
    twitter_accounts
  end

  def twitter_accounts
    @accounts ||= begin
      account_store = App.delegate.account_store
      account_type = account_store.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)

      account_store.requestAccessToAccountsWithType(account_type, options:nil, completion:->(granted, error){
        cant_access_accounts unless granted
      })

      account_store.accountsWithAccountType(account_type)
    end
  end

  def cant_access_accounts
    App.alert("Twee couldn't access your Twitter accounts. Make sure it is allowed to access them by visiting Settings -> Privacy -> Twitter.")
  end

  def try_pick_account
    select_account(@accounts.first) if @accounts.size == 1
  end

  def select_account(account)
    App::Persistence['account_id'] = account.identifier

    TimelineController.controller.dismissModalViewControllerAnimated(true)
    TimelineController.controller.refresh
  end

  def tableView(tableView, numberOfRowsInSection:section)
    @accounts.count
  end

  def tableView(tableView, cellForRowAtIndexPath:indexPath)
    @reuse_id ||= 'TW_ACCT_CELL'

    cell = tableView.dequeueReusableCellWithIdentifier(@reuse_id)
    cell ||= UITableViewCell.alloc.initWithStyle(
      UITableViewCellStyleDefault, reuseIdentifier:@reuse_id
    )
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator

    cell.textLabel.text = "@#{@accounts[indexPath.row].username}"
    cell
  end

  def tableView(tableView, didSelectRowAtIndexPath:indexPath)
    tableView.deselectRowAtIndexPath(indexPath, animated:true)

    select_account(@accounts[indexPath.row])
  end
end
