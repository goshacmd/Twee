class Twitter
  class << self
    def account_store
      @account_store ||= ACAccountStore.new
    end

    def account_type
      @account_type ||=
        account_store.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
    end

    def accounts
      @accounts ||=
        account_store.accountsWithAccountType(account_type).map { |acc| Account.new(acc) }
    end

    def find(id)
      account_store.accountWithIdentifier(id) if id
    end

    def request_access(&block)
      cb = block

      account_store.requestAccessToAccountsWithType(account_type, options:nil, completion:->(granted, error){
        @accounts = nil
        Dispatch::Queue.main.sync { cb.call(granted, error) }
      })
    end
  end
end
