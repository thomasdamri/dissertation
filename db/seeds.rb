
#Create User accounts
u = User.create(email: 'p.mcminn@sheffield.ac.uk', staff: true, admin: true)
u.get_info_from_ldap
u.save

u1 = User.create(username: 'aca19td', email: 'tdamri1@sheffield.ac.uk', staff: false, admin: false)
u1.get_info_from_ldap
u1.save

u2 = User.create(email: 'ajparr1@sheffield.ac.uk', staff: false, admin: false)
u2.get_info_from_ldap
u2.save

u3 = User.create(email: 'rwsmith2@sheffield.ac.uk', staff: false, admin: false)
u3.get_info_from_ldap
u3.save


#Create module and assign staff member
m1 = UniModule.create(name: "The Intelligent Web", code: "COM3504", created_at: "Thu, 10 jan 2022 23:11:02 +0000 ", updated_at: "Thu, 15 Mar 2022 23:11:02 +0000 ", start_date: Date.today - 30.days, end_date: Date.today + 20.days)
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


#Team member 1 

s1task1 = StudentTask.create(student_team_id: st1.id, task_difficulty: 0, task_start_date: DateTime.now - (27.days), task_target_date: Date.today- (25.days), task_complete_date: DateTime.now- (25.days), hours: 3,  task_objective: "Images need to be transformed to base 64. Images are uploaded to the server and stored into a MongoDB database.")
#s1task1.save
s1task2 = StudentTask.create(student_team_id: st1.id, task_difficulty: 2, task_start_date: DateTime.now - (26.days), task_target_date: Date.today- (23.days), task_complete_date: DateTime.now- (24.days), hours: 2, task_objective: "I am provided with a starting point project that implements the drawing capability and provides a basic version of the chat interface. This will help you focus away from basic HTML/CSS issues. Use socket.io to send both the chat text and the graphical.")
#s1task2.save
s1task3 = StudentTask.create(student_team_id: st1.id, task_difficulty: 1, task_start_date: DateTime.now- (18.days), task_target_date: Date.today- (12.days), task_complete_date: DateTime.now- (15.days), hours: 7, task_objective: "When uploading a new story, if the device is offline, the story must be cached into the IndexedDB together with all the metadata title, text, date, etc.. When the device goes online again, the story must be uploaded to the servers database via Axios.")
#s1task3.save
s1task4 = StudentTask.create(student_team_id: st1.id, task_difficulty: 0, task_start_date: DateTime.now- (14.days), task_target_date: Date.today- (13.days), task_complete_date: DateTime.now- (12.days), hours: 1, task_objective: "Allow the user to annotate the images with information retrieved from Googls knowledge graph. For example, the Knowledge Graph Annotation could be used to provide information about a person in a picture or a location.")
#s1task4.save
s1task5 = StudentTask.create(student_team_id: st1.id, task_difficulty: 0, task_start_date: DateTime.now- (14.days), task_target_date: Date.today- (8.days), task_complete_date: DateTime.now- (10.days), hours: 2, task_objective: "The deadlines are fixed. You should therefore plan your work to aim at handing the report in at least a few days before the deadline  do not leave it until the deadline, just in case any minor thing goes wrong and you then find that you are late. ")
#s1task5.save
s1task6 = StudentTask.create(student_team_id: st1.id, task_difficulty: 2, task_start_date: DateTime.now- (13.days), task_target_date: Date.today- (5.days), task_complete_date: DateTime.now- (6.days), hours: 5, task_objective: "Having said that, please note that the assignment is open ended in some respects. Implementing a perfect solution would be far beyond the scope of this module. Make sure to keep the solution manageable in the time allocated to the module.")
#s1task6.save
s1task7 = StudentTask.create(student_team_id: st1.id, task_difficulty: 1, task_start_date: DateTime.now- (6.days), task_target_date: Date.today , task_objective: "When clicking on a story, the story is opened. The story per se is unmodifiable but it will be possible to discuss about the findings in a chat with another person online when the two users are in the same room at the same time.")

s1task8 = StudentTask.create(student_team_id: st1.id, task_difficulty: 2, task_start_date: DateTime.now- (2.days), task_target_date: Date.today+ (2.days),  task_objective: "When clicking on a story, the story is opened. The story per se is unmodifiable but it will be possible to discuss about the findings in a chat with another person online when the two users are in the same room at the same time.")

s1task9 = StudentTask.create(student_team_id: st1.id, task_difficulty: 0, task_start_date: DateTime.now- (1.days), task_target_date: Date.today+ (5.days), task_objective: "When clicking on a story, the story is opened. The story per se is unmodifiable but it will be possible to discuss about the findings in a chat with another person online when the two users are in the same room at the same time.")
#s1task7.save

#Team member 2
s2task1 = StudentTask.create(student_team_id: st2.id, task_difficulty: 1, task_start_date: DateTime.now - (27.days), task_target_date: Date.today- (25.days), task_complete_date: DateTime.now- (25.days), hours: 3, task_objective: "It is important for your solution to follow the patterns and material taught during the lectures. Solutions that adopt different approaches will attract low marks and in some cases zero marks. The goal of the assignment is to prove that. ")
#s2task1.save
s2task2 = StudentTask.create(student_team_id: st2.id, task_difficulty: 2,  task_start_date: DateTime.now - (24.days), task_target_date: Date.today- (14.days), task_complete_date: DateTime.now- (12.days), hours: 2, task_objective: "The external node modules must NOT be included in your submission so to avoid to submit very large zip files which will cause issues especially close to the deadline. Just make sure to create a complete package.json file so that we can. ")
#s2task2.save
s2task3 = StudentTask.create(student_team_id: st2.id, task_difficulty: 1, task_start_date: DateTime.now - (12.days), task_target_date: Date.today- (5.days), task_complete_date: DateTime.now- (6.days), hours: 1, task_objective: "Everything must be submitted electronically via Blackboard. Store your solution in a .ZIP file that when unzipped will generate the directory organisation as described above. As an emergency measure and only in that case!")
#s2task3.save
s2task4 = StudentTask.create(student_team_id: st2.id, task_difficulty: 1, task_start_date: DateTime.now - (1.days), task_target_date: Date.today+ (12.days), task_objective: "The whole story inclusive of image, text, title, etc.  this part will also be available in the server but they must be cached to allow working offline see below")
#s2task4.save

#Team member 2
s3task1 = StudentTask.create(student_team_id: st3.id, task_difficulty: 1, task_start_date: DateTime.now - (1.days), task_target_date: Date.today+ (2.days), task_objective: "Cloned the github")
#s3task1.save
s3task2 = StudentTask.create(student_team_id: st3.id, task_difficulty: 2, task_start_date: DateTime.now - (0.days), task_target_date: Date.today+ (10.days), task_objective: "Create comments for login page!")
#s3task2.save

#puts(s3task2)

gradedAssessment = Assessment.create(name: "Assessment 1", uni_module_id: m1.id, date_opened: Date.today - (14.days), date_closed: Date.today - (7.days), created_at: DateTime.now - (17.days), updated_at: DateTime.now - (15.days), show_results: true)
q1 = Question.create(title: "How good are your team mates at contributing?", response_type: 1, weighting: 2, assessed: 1, single: 0, max_value: 4, min_value: 1, assessment_id: gradedAssessment.id)
AssessmentResult.create(question: q1, author: st1, target: st1, value: 4)
AssessmentResult.create(question: q1, author: st1, target: st2, value: 3)
AssessmentResult.create(question: q1, author: st1, target: st3, value: 3)
AssessmentResult.create(question: q1, author: st2, target: st1, value: 2)
AssessmentResult.create(question: q1, author: st2, target: st2, value: 3)
AssessmentResult.create(question: q1, author: st2, target: st3, value: 4)
AssessmentResult.create(question: q1, author: st3, target: st1, value: 4)
AssessmentResult.create(question: q1, author: st3, target: st2, value: 3)
AssessmentResult.create(question: q1, author: st3, target: st3, value: 2)
gradedAssessment.generate_weightings(t1)
TeamGrade.create(team: t1, assessment: gradedAssessment, grade: 80, created_at: DateTime.now, updated_at: DateTime.now)

openAssessment = Assessment.create(name: "Assessment 2", uni_module_id: m1.id, date_opened: Date.today - (5.days), date_closed: Date.today + (7.days), created_at: DateTime.now - (10.days), updated_at: DateTime.now - (5.days), show_results: false)
q2 = Question.create(title: "Rate team members on meeting contributions:", response_type: 1, weighting: 2, assessed: 1, single: 0, max_value: 5, min_value: 1, assessment_id: openAssessment.id)
q3 = Question.create(title: "Rate team members on punctuality:", response_type: 1, weighting: 3, assessed: 1, single: 0, max_value: 5, min_value: 1, assessment_id: openAssessment.id)

StudentChat.create(student_team_id: st1.id, chat_message: "Hi Guys, looks like we are working together for this one!", posted: DateTime.now - (25.days) - (6.hours))
StudentChat.create(student_team_id: st2.id, chat_message: "Nice, lets get this meeting started", posted: DateTime.now - (25.days) - (5.hours))
StudentChat.create(student_team_id: st1.id, chat_message: "I was thinking of making the github", posted: DateTime.now - (25.days) - (4.hours))
StudentChat.create(student_team_id: st2.id, chat_message: "Cool , link it and i will clone it", posted: DateTime.now - (25.days) - (3.hours))
StudentChat.create(student_team_id: st1.id, chat_message: "Hi guys, nice work this week!", posted: DateTime.now - (15.days) - (9.hours))
StudentChat.create(student_team_id: st2.id, chat_message: "Thanks, I've been working on the home page", posted: DateTime.now - (15.days) - (6.hours))
StudentChat.create(student_team_id: st1.id, chat_message: "Okay, check out my latest task, what do you think?", posted: DateTime.now - (15.days) - (5.hours))
StudentChat.create(student_team_id: st2.id, chat_message: "Very nice bro!", posted: DateTime.now - (15.days) - (4.hours))
StudentChat.create(student_team_id: st1.id, chat_message: "I've noticed our third team member hasn't said anything yet", posted: DateTime.now - (15.days) - (3.hours))
StudentChat.create(student_team_id: st2.id, chat_message: "Hmmmm weird stuff, might report that!", posted: DateTime.now - (15.days) - (2.hours))
StudentChat.create(student_team_id: st1.id, chat_message: "Good idea!", posted: DateTime.now - (15.days) - (1.hours))
StudentChat.create(student_team_id: st3.id, chat_message: "Sorry guys, i've been on holiday!", posted: DateTime.now - (10.days) - (6.hours))
StudentChat.create(student_team_id: st1.id, chat_message: "Fairs, check up on our tasks and chats to get updated!", posted: DateTime.now - (10.days) - (5.hours))
StudentChat.create(student_team_id: st3.id, chat_message: "Nice, looks like you guys have been doing good so far", posted: DateTime.now - (10.days) - (4.hours))
StudentChat.create(student_team_id: st2.id, chat_message: "Welcome bro, make sure you clone the github", posted: DateTime.now - (10.days) - (3.hours))
StudentChat.create(student_team_id: st3.id, chat_message: "Okiedokie!", posted: DateTime.now - (10.days) - (2.hours))
StudentChat.create(student_team_id: st1.id, chat_message: "Assessment 1 grades have been published, check them out", posted: DateTime.now - (5.hours))
StudentChat.create(student_team_id: st2.id, chat_message: "EPIC!", posted: DateTime.now - (4.hours))
StudentChat.create(student_team_id: st3.id, chat_message: "Nice! Gonna work on some tests tonight! I'll make the task!", posted: DateTime.now - (2.hours))