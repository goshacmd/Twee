class ComposeController < UIViewController
  def self.controller
    @controller ||= alloc.initWithNibName(nil, bundle:nil)
  end

  def viewWillAppear(animated)
    NSNotificationCenter.defaultCenter.addObserver(self, selector:'keyboardWillShow:', name:UIKeyboardWillShowNotification, object:nil)
    NSNotificationCenter.defaultCenter.addObserver(self, selector:'keyboardWillHide:', name:UIKeyboardWillHideNotification, object:nil)
  end

  def keyboardWillShow(notification)
    moveTextViewForKeyboard(notification, up:true)
  end

  def keyboardWillHide(notification)
    moveTextViewForKeyboard(notification, up:false)
  end

  def moveTextViewForKeyboard(notification, up:up)
    user_info = notification.userInfo

    keyboard_rect = user_info[UIKeyboardFrameEndUserInfoKey].CGRectValue
    keyboard_rect = view.convertRect(keyboard_rect, fromView:nil)

    if up
      view_rect = view.bounds
      new_view_rect = CGRect.new(
        [view_rect.origin.x, view_rect.origin.y],
        [view_rect.size.width, view_rect.size.height - keyboard_rect.size.height - 10]
      )
      fit_text_view_and_label_into(new_view_rect)
    else
      fit_text_view_and_label_into(view.bounds)
    end
  end

  def viewDidLoad
    super

    self.title = 'New Tweet'
    view.backgroundColor = UIColor.whiteColor

    @cancelButton = UIBarButtonItem.alloc.initWithBarButtonSystemItem(
      UIBarButtonSystemItemCancel, target:self, action:'cancel'
    )

    @postButton = UIBarButtonItem.alloc.initWithTitle(
      'Tweet', style:UIBarButtonItemStyleBordered, target:self, action:'post'
    )

    navigationItem.leftBarButtonItem = @cancelButton
    navigationItem.rightBarButtonItem = @postButton

    @composeField = UITextView.alloc.initWithFrame(CGRectZero)
    @composeField.font = UIFont.systemFontOfSize(20)
    @composeField.delegate = self

    view.addSubview(@composeField)

    @remainingLabel = UILabel.alloc.initWithFrame(CGRectZero)
    @remainingLabel.font = UIFont.systemFontOfSize(10)
    @remainingLabel.textColor = UIColor.grayColor
    update_remaining_chars

    view.addSubview(@remainingLabel)

    fit_text_view_and_label_into(view.bounds, true)

    @composeField.becomeFirstResponder
  end

  def fit_text_view_and_label_into(frame, initial = false)
    compose_height_sub = initial ? 65 : 15
    @composeField.frame = [frame.origin, [frame.size.width, frame.size.height - compose_height_sub]]
    @remainingLabel.frame = [
      [5, @composeField.frame.origin.y + @composeField.frame.size.height],
      [frame.size.width - 10, 15]
    ]
  end

  def cancel
    dismissModalViewControllerAnimated(true)
  end

  def post
    @postButton.enabled = false

    post_status do
      Dispatch::Queue.main.sync do
        @postButton.enabled = true
        @composeField.text = ''
        cancel
      end
    end
  end

  def post_status(&block)
    url = NSURL.URLWithString("http://api.twitter.com/1/statuses/update.json")
    params = { status: @composeField.text }
    req = TWRequest.alloc.initWithURL(url, parameters:params, requestMethod:TWRequestMethodPOST)
    req.account = App.delegate.account
    req.performRequestWithHandler ->(data, url_response, error){
      App.alert('An error occured while posting.') if error

      block.call if block
    }
  end

  def textView(textView, shouldChangeTextInRange:range, replacementText:text)
    textView.text.length - range.length + text.length <= 140
  end

  def textViewDidChange(textView)
    update_remaining_chars
  end

  def update_remaining_chars
    remaining = 140 - @composeField.text.length
    @remainingLabel.text = "#{remaining} character#{remaining == 1 ? '' : 's'} left"
  end
end
