# lib/tasks/users.rake
namespace :users do
  desc "Delete all users (for testing)"
  task delete_all: :environment do
    count = User.count
    User.destroy_all
    puts "Deleted #{count} users"
  end
  
  desc "Delete test users (emails starting with 'test')"
  task delete_test: :environment do
    test_users = User.where("email LIKE ?", "test%@columbia.edu")
    count = test_users.count
    test_users.destroy_all
    puts "Deleted #{count} test users"
  end
  
  desc "List all users"
  task list: :environment do
    puts "Current users:"
    User.all.each { |u| puts "ID: #{u.id}, Email: #{u.email}, UNI: #{u.uni}" }
  end
end
