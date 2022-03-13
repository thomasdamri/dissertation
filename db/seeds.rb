
#Create User accounts
u = User.create(email: 'p.mcminn@sheffield.ac.uk', staff: true, admin: true)
u.get_info_from_ldap
u.save

u1 = User.create(username: 'aca19td', email: 'tdamri1@sheffield.ac.uk', staff: true, admin: true)
u1.get_info_from_ldap
u1.save

u2 = User.create(email: 'ajparr1@sheffield.ac.uk', staff: false, admin: false)
u2.get_info_from_ldap
u2.save

u3 = User.create(email: 'rwsmith2@sheffield.ac.uk', staff: false, admin: false)
u3.get_info_from_ldap
u3.save

u4 = User.create(email: 'aranjan2@sheffield.ac.uk', staff: false, admin: false)
u4.get_info_from_ldap
u4.save

#Create module and assign staff member
m1 = UniModule.create(name: "The Intelligent Web", code: "COM3504", created_at: "Thu, 10 jan 2022 23:11:02 +0000 ", updated_at: "Thu, 15 Mar 2022 23:11:02 +0000 ", start_date: "15 jan 2022 ", end_date: "10 june 2022 ")
# m1.save


sm = StaffModule.create(user_id: u.id, uni_module_id: m1.id)
sm2 = StaffModule.create(user_id: u1.id, uni_module_id: m1.id)
# sm.save

#TEAM 1
t1 = Team.create(uni_module_id: m1.id, team_number: 1)
# puts(t1)
# t1.save

st1 = StudentTeam.create(user_id: u1.id, team_id: t1.id)
#st1.save
st2 = StudentTeam.create(user_id: u2.id, team_id: t1.id)
#st2.save
st3 = StudentTeam.create(user_id: u3.id, team_id: t1.id)
#st3.save
st4 = StudentTeam.create(user_id: u4.id, team_id: t1.id)
#st4.save
#puts(st4)
#Create tasks for team 1
#Team member 1
s1task1 = StudentTask.create(student_team_id: st1.id, task_difficulty: 0, task_start_date: "Thu, 20 jan 2022 13:12:02 +0000", task_target_date: "27 jan 2022", task_objective: "Images need to be transformed to base 64. Images are uploaded to the server and stored into a MongoDB database. The images can be uploaded from the file system or can be referenced using a URL. Even in the latter case, the image must be uploaded to the server because the risk is that if the image is changed online, then the annotations will no longer make sense")
#s1task1.save
s1task2 = StudentTask.create(student_team_id: st1.id, task_difficulty: 2, task_start_date: "Thu, 24 jan 2022 15:12:02 +0000", task_target_date: "30 jan 2022", task_objective: "I am provided with a starting point project that implements the drawing capability and provides a basic version of the chat interface. This will help you focus away from basic HTML/CSS issues. Use socket.io to send both the chat text and the graphical annotations to the participants in the room. The starting point project provides some hints (@todo) on where to send the data. This should help you understand how the provided code works.")
#s1task2.save
s1task3 = StudentTask.create(student_team_id: st1.id, task_difficulty: 1, task_start_date: "Thu, 30 jan 2022 17:12:02 +0000", task_target_date: "3 feb 2022", task_objective: "When uploading a new story, if the device is offline, the story must be cached into the IndexedDB together with all the metadata (title, text, date, etc.). When the device goes online again, the story must be uploaded to the server’s database via Axios.")
#s1task3.save
s1task4 = StudentTask.create(student_team_id: st1.id, task_difficulty: 0, task_start_date: "Thu, 5 feb 2022 11:12:02 +0000", task_target_date: "9 feb 2022", task_objective: "Allow the user to annotate the images with information retrieved from Google’s knowledge graph. For example, the Knowledge Graph Annotation could be used to provide information about a person in a picture or a location.")
#s1task4.save
s1task5 = StudentTask.create(student_team_id: st1.id, task_difficulty: 0, task_start_date: "Thu, 13 feb 2022 16:12:02 +0000", task_target_date: "16 feb 2022", task_objective: "The deadlines are fixed. You should therefore plan your work to aim at handing the report in at least a few days before the deadline – do not leave it until the deadline, just in case any minor thing goes wrong and you then find that you are late. ")
#s1task5.save
s1task6 = StudentTask.create(student_team_id: st1.id, task_difficulty: 2, task_start_date: "Thu, 15 feb 2022 18:12:02 +0000", task_target_date: "26 feb 2022", task_objective: "Having said that, please note that the assignment is open ended in some respects. Implementing a perfect solution would be far beyond the scope of this module. Make sure to keep the solution manageable in the time allocated to the module. Do not overdo it. Designing a beautiful website with lots of functionalities for an amazing user experience may be tempting but is pointless. The number of marks that will attract in terms of quality will not be worth the amount of time that will cost you. I suggest instead that you spend your time working on the quality of the core solution and its documentation.")
#s1task6.save
s1task7 = StudentTask.create(student_team_id: st1.id, task_difficulty: 1, task_start_date: "Thu, 15 feb 2022 11:12:02 +0000", task_target_date: "23 feb 2022", task_objective: "When clicking on a story, the story is opened. The story per se is unmodifiable but it will be possible to discuss about the findings in a chat with another person online (when the two users are in the same room at the same time) or simply using the chat to take notes (if you are in a room alone)")
#s1task7.save

#Team member 2
s2task1 = StudentTask.create(student_team_id: st2.id, task_difficulty: 1, task_start_date: "Thu, 19 jan 2022 14:12:02 +0000", task_target_date: "25 jan 2022", task_objective: "It is important for your solution to follow the patterns and material taught during the lectures. Solutions that adopt different approaches will attract low marks and in some cases zero marks. The goal of the assignment is to prove that you have learned from the module, rather than to prove you are able to write code that works.")
#s2task1.save
s2task2 = StudentTask.create(student_team_id: st2.id, task_difficulty: 2, task_start_date: "Thu, 24 jan 2022 03:12:02 +0000", task_target_date: "26 jan 2022", task_objective: "The external node modules must NOT be included in your submission so to avoid to submit very large zip files which will cause issues especially close to the deadline. Just make sure to create a complete package.json file so that we can install all the modules running npm install. Some css and js libraries can be provided with external links in HTML/EJS files (e.g. you do not need to include JQuery, just link it in your HTML/EJS files).")
#s2task2.save
s2task3 = StudentTask.create(student_team_id: st2.id, task_difficulty: 1, task_start_date: "Thu, 8 feb 2022 13:22:02 +0000", task_target_date: "14 feb 2022", task_objective: "Everything must be submitted electronically via Blackboard. Store your solution in a .ZIP file that when unzipped will generate the directory organisation as described above. As an emergency measure (and only in that case!), if any last minute issue should arise in handing in electronically, please send your solution by email to the lecturer (cc to demonstrators) in a self-contained.ZIP file.")
#s2task3.save
s2task4 = StudentTask.create(student_team_id: st2.id, task_difficulty: 1, task_start_date: "Thu, 12 feb 2022 15:22:02 +0000", task_target_date: "15 feb 2022", task_objective: "The whole story inclusive of image, text, title, etc. – this part will also be available in the server but they must be cached to allow working offline (see below)")
#s2task4.save

#Team member 2
s3task1 = StudentTask.create(student_team_id: st3.id, task_difficulty: 1, task_start_date: "Thu, 19 jan 2022 11:17:02 +0000", task_target_date: "25 jan 2022", task_objective: "Cloned the github")
#s3task1.save
s3task2 = StudentTask.create(student_team_id: st3.id, task_difficulty: 2, task_start_date: "Thu, 14 jan 2022 16:25:02 +0000", task_target_date: "15 jan 2022", task_objective: "Create comments for login page!")
#s3task2.save

#puts(s3task2)




=begin
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
=end
