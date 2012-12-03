require 'rest_client'
require 'json'

LOGIN_NAME = ENV['GITHUB_USER']
LOGIN_PASSWORD = ENV['GITHUB_PASSWORD']
GITHUB_API_SITE = "https://api.github.com"

def call_api(url)
    url = "#{GITHUB_API_SITE}#{url}"
    result = RestClient::Request.new( :method => :get, :url => url, :user => LOGIN_NAME,  :password => LOGIN_PASSWORD, :headers => { :accept => :json, :content_type => :json }).execute
    result = JSON.parse(result)
end

def get_team_members(id)
    puts @indent + 'Github user id, full name, details'
    members = call_api "/teams/#{id}/members"
    members.each { |m|
        uid = m['login']
        user = call_api "/legacy/user/search/#{uid}"

        user = user['users'][0]
        puts @indent + "#{user['username']}, #{user['fullname']}, #{String(user['location']).gsub(',','-')}"
    }
end

@teams = []
@indent = '   '

def get_teams(org, filter=[])
    teams = call_api "/orgs/#{org}/teams"
    teams.each { |t|
        tid = t['id']
        if filter.include?("all") || filter.include?(t['name'])
            puts
            puts "Members in team: #{t['name']}"
            get_team_members tid
        end
    }
end

def get_teams_for_repo(org, repo)
    teams = call_api "/repos/#{org}/#{repo}/teams"

    puts
    puts "Teams for repo: #{org}/#{repo}"
    teams = teams.inject([]) { |array, t| array << t['name'] }
    teams.uniq.sort.each {|t|
        puts @indent + t
    }

    @teams += teams
    #get_teams org, teams
end

def get_repos_for_org(org)
    repos = call_api "/orgs/#{org}/repos"

    #puts "Repos for organization: #{org}"
    repos.each do |repo|
        name = repo['name']
        if block_given?
            yield org, name
        else
            puts name
        end
    end
end

def print_user(user)
    puts "#{user['username']}, #{user['fullname']}, #{user['location']}"
end

get_repos_for_org('sage') { |org, repo| get_teams_for_repo org, repo}

get_teams 'sage', @teams.uniq.sort
