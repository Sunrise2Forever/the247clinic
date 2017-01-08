User.destroy_all

User.create!([{
  name:  "Admin User",
  email: "admin@247clinic.ca",
  password:              "MedeoKiller",
  password_confirmation: "MedeoKiller",
  admin:     true,
  activated: true,
  activated_at: Time.zone.now
},
{
  name:  "Dr Vance",
  email: "vance@247clinic.ca",
  password:              "MedeoKiller",
  password_confirmation: "MedeoKiller",
  user_type: 'doctor',
  activated: true,
  activated_at: Time.zone.now
}])

p "Created #{User.count} users"
