# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

%w(user admin).each { |role| Role.find_or_create_by_name(role) }

User.delete_all
User.create(login: "insumy", email: "insumy@gmail.com", password: 111111, role: Role.find_by_name(:admin))
User.create(login: "user", email: "user@gmail.com", password: 111111, role: Role.find_by_name(:user))
