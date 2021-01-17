print("Enter team name")
teamName = input()
print("Enter teamId")
teamId = input()
print("Enter sessionId")
sessionId = input()
print ("Enter Color")
R = input()
G = input()
B = input()
print("Enter player number")
players = int(input())
name = []
surname = []
id = []
username=[]
for player in range(players):
    print("New player:")
    print("Enter name, surname")
    name.append(input())
    surname.append(input())
    print("Enter id")
    id.append( input())
    print('Enter username')
    username.append(input())
print(f'JSON: "@teamId":{teamId},"playerIds":{id},"playerNames":{username},"color":[{R},{G},{B}],"teamName":"{teamName}"'.replace("\'","\""))
print("SQL: ")
print(f'INSERT INTO team VALUES(null,"{teamName}",{sessionId},"{R},{G},{B}",0);')
for player in range(players):
    print(f'INSERT INTO `user` VALUES("{id[player]}",null,"{name[player]}","{surname[player]}","{username[player]}");')
    print(f'INSERT INTO team_user VALUES({teamId},"{id[player]}");')
