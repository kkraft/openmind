class Task < ActiveRecord::Base
  belongs_to :story
  has_many :task_estimates, :order => "as_of", :dependent => :destroy

  named_scope :pushed,
              :conditions => {:status => "pushed"}
  named_scope :not_pushed,
              :conditions => ["tasks.status <> ?", "pushed"]
  named_scope :qa, :conditions  => { :qa => true }
  named_scope :conditional_pushed,
              lambda { |param| return {} if param.nil? or param == "Y"
              {:conditions => ["tasks.status <> ?", "pushed"]}
              }
  named_scope :by_status,
              lambda { |param|
              {:conditions => {:status => param}}
              }

  @estimates = nil

  def fetch_estimate_by_day_number day_number, iteration=self.story.iteration
    fetch_estimate_by_date(iteration.calc_date(day_number))
  end

  def fetch_estimate_by_date the_date
    puts "fetch estimate for #{the_date}"
    populate_estimates_hash unless @estimates
    @estimates[the_date]
  end

  def debug
    populate_estimates_hash unless @estimates
    @estimates.keys.each do |k|
      puts "#{k}: #{@estimates[k].try(:id)}"
    end
  end

  def self.sort_by_status tasks
    tasks.sort_by do |s|
      case s.status
        when "Done" then
          1
        when "Blocked" then
          2
        when "In Progress" then
          3
        when "Not Started" then
          4
        else
          7
      end
    end
  end

  private

  def populate_estimates_hash
    puts "populate hash"
    @estimates = {}
    self.task_estimates.each do |e|
      puts "populating has #{e.as_of}"
      @estimates[e.as_of] = e
    end
  end
end