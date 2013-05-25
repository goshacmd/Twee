class MentionsController < AbstractTimelineController
  def viewDidLoad
    super

    self.title = 'Mentions'
  end

  def initWithNibName(name, bundle:bundle)
    super
    tabBarItem.image = UIImage.imageNamed('At')
    tabBarItem.title = 'Mentions'
    self
  end

  def load_timeline(&block)
    account.mentions_timeline(count: '20') do |data, error|
      App.alert('An error occurrred') if error
      load_data(data) if data
      block.call if block
    end
  end
end
