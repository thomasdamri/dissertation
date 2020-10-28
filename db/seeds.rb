# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

u1 = User.first
u2 = User.where(username: 'zzz18as').first
u3 = User.where(username: 'zzz18bs').first
u4 = User.where(username: 'zzz18cs').first

c1 = Criterium.find(43)
c2 = Criterium.find(44)
c3 = Criterium.find(45)

# C1
AssessmentResult.create(criterium: c1, author: u1, target: u2, value: 8)
AssessmentResult.create(criterium: c1, author: u1, target: u3, value: 2)
AssessmentResult.create(criterium: c1, author: u1, target: u4, value: 5)

AssessmentResult.create(criterium: c1, author: u2, target: u1, value: 10)
AssessmentResult.create(criterium: c1, author: u2, target: u3, value: 1)
AssessmentResult.create(criterium: c1, author: u2, target: u4, value: 6)

AssessmentResult.create(criterium: c1, author: u3, target: u1, value: 10)
AssessmentResult.create(criterium: c1, author: u3, target: u2, value: 8)
AssessmentResult.create(criterium: c1, author: u3, target: u4, value: 5)

AssessmentResult.create(criterium: c1, author: u4, target: u1, value: 10)
AssessmentResult.create(criterium: c1, author: u4, target: u2, value: 7)
AssessmentResult.create(criterium: c1, author: u4, target: u3, value: 3)

# C2
AssessmentResult.create(criterium: c2, author: u1, target: u2, value: 9)
AssessmentResult.create(criterium: c2, author: u1, target: u3, value: 3)
AssessmentResult.create(criterium: c2, author: u1, target: u4, value: 6)

AssessmentResult.create(criterium: c2, author: u2, target: u1, value: 10)
AssessmentResult.create(criterium: c2, author: u2, target: u3, value: 2)
AssessmentResult.create(criterium: c2, author: u2, target: u4, value: 7)

AssessmentResult.create(criterium: c2, author: u3, target: u1, value: 8)
AssessmentResult.create(criterium: c2, author: u3, target: u2, value: 9)
AssessmentResult.create(criterium: c2, author: u3, target: u4, value: 5)

AssessmentResult.create(criterium: c2, author: u4, target: u1, value: 7)
AssessmentResult.create(criterium: c2, author: u4, target: u2, value: 8)
AssessmentResult.create(criterium: c2, author: u4, target: u3, value: 4)

# C3
AssessmentResult.create(criterium: c3, author: u1, target: u2, value: 7)
AssessmentResult.create(criterium: c3, author: u1, target: u3, value: 4)
AssessmentResult.create(criterium: c3, author: u1, target: u4, value: 7)

AssessmentResult.create(criterium: c3, author: u2, target: u1, value: 9)
AssessmentResult.create(criterium: c3, author: u2, target: u3, value: 3)
AssessmentResult.create(criterium: c3, author: u2, target: u4, value: 8)

AssessmentResult.create(criterium: c3, author: u3, target: u1, value: 9)
AssessmentResult.create(criterium: c3, author: u3, target: u2, value: 10)
AssessmentResult.create(criterium: c3, author: u3, target: u4, value: 6)

AssessmentResult.create(criterium: c3, author: u4, target: u1, value: 10)
AssessmentResult.create(criterium: c3, author: u4, target: u2, value: 8)
AssessmentResult.create(criterium: c3, author: u4, target: u3, value: 5)