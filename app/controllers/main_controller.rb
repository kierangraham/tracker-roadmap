class MainController < ApplicationController
  before_filter :authenticate
  
  def index
    collect_releases
    
  end
  
  def workstream
    collect_releases
    
    releases_sorted_by_date = @releases.select{|x| x if x.deadline }.sort{|x, y| x.deadline <=> y.deadline }
    
    
    # Owners = Workstreams 
    # Gather owners and months for all releases
    @owners = @releases.collect{|x| x.owned_by}.uniq
    @months = (releases_sorted_by_date.first.deadline..releases_sorted_by_date.last.deadline).collect{|y| [y.month, y.strftime('%b, %Y')] }.uniq
    
    # EX: { 11 => { "Bob Smith" => [release, release], "Timmy Tots" => [release], "Jane Robbins" => [release, release, release] } }
    @releases_by_deadline_month = {}
    
    # Prepare set
    @months.each do |m| 
      releases_by_owner = {}
      @owners.each{|y| releases_by_owner[y] = [] }
      @releases_by_deadline_month[m[0]] = releases_by_owner
    end
    
    releases_sorted_by_date.each do |release| 
      @releases_by_deadline_month[release.deadline.month][release.owned_by] << release
    end
    
    @unscheduled_releases_by_owner = {}
    @owners.each do |owner| 
      @unscheduled_releases_by_owner[owner] = @releases.select{|x| x if !x.deadline && x.owned_by == owner }
    end
    
    @col_size = ( (958 - (@owners.size * 8)) / @owners.size).to_i
    
  end

protected

  def collect_releases
    PivotalTracker::Client.token = ENV["TRACKER_API_KEY"]
    PivotalTracker::Client.use_ssl = true
    
    @project = PivotalTracker::Project.find(ENV["TRACKER_PROJECT_ID"].to_i)
    @releases = []
    @iterations = params[:all] ? @project.iterations.all : [PivotalTracker::Iteration.current(@project)] + PivotalTracker::Iteration.backlog(@project)
    @iterations.each do |iteration|
      iteration.stories.each do |story|
        if story.story_type == "release"
          release = story
          release.estimated_finish = iteration.finish
          @releases << release
        end
      end
    end
  end
  
  def authenticate
    authenticate_or_request_with_http_basic do |username, password|
      username == ENV["USERNAME"] && password == ENV["PASSWORD"]
    end
  end
end
