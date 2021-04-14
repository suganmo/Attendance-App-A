# coding: utf-8

User.create!(name: "管理者",
             email: "admin@email.com",
             affiliation: "Admin",
             employee_number: 1,
             password: "password",
             password_confirmation: "password",
             admin: true,
             superior: false,)
             
User.create!(name: "上長A",
             email: "superior1@email.com",
             affiliation: "Superior1",
             employee_number: 2,
             password: "password",
             password_confirmation: "password",
             admin: false,
             superior: true,)

User.create!(name: "上長B",
              email: "superior2@email.com",
              affiliation: "Sperior2",
              employee_number: 3,
               password: "password",
              password_confirmation: "password",
              admin: false,
              superior: true,)
 
10.times do |n|
  name  = Faker::Name.name
  email = "sample-#{n+1}@email.com"
  employee_nunber = n +4
  password = "password"
  User.create!(name: name,
               email: email,
               affiliation: "Unknown",
               password: password,
               password_confirmation: password)
end