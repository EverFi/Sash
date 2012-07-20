process.env.NODE_ENV = 'development'
require('coffee-script')
require('./load_models')


org = new Organization({
  name: "everfi",
  org: "EverFi, Inc.",
  api_key: "awesomeapikey",
  contact: "badges@everfi.com"
})
org.setValue('password', 'pass')

badges = [
  {
    name: "Awesome Badge",
    description: "Some Awesome Badge\nThat is awesome.",
    criteria: "User has completed the awesomeness course",
    version: '0.1.0',
    image: "mario-badge.png",
    issuer_id: org.id
  },

  {
    name: "Financial Literacy for Ducks",
    description: "Badge for ducks completing the financial literacy course",
    criteria: "The Duck has completed the FinLit course",
    version: '0.1.0',
    image: "mario-badge-2.png",
    issuer_id: org.id
  },
  {
    name: "Digital Literacy",
    description: "Ignition certifications badge. User is a good digital citizen",
    criteria: "User has completed the Ignition course for digital literacy",
    version: '0.1.0',
    image: "mario-badge-3.png",
    issuer_id: org.id
  },
  {
    name: "Welcome to Ignition",
    description: "Welcome! You have successfully registered for Ignition!",
    criteria: "User has registered",
    version: '0.1.0',
    image: "mario-badge-4.png",
    issuer_id: org.id,
    tags: ['ignition']
  }
]

org.save(function(){
  badges.forEach(function(badge){
    var b = new Badge(badge)
    b.save(function(e, b){console.log(b)});
  })
})


return
