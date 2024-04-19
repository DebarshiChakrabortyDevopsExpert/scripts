Name        = str(input('Enter your Name:'))
Age         = int(input('Enter your Age:'))
Married     = str(input('Are you Married Y or N ?'))
Gender      = str(input('What is your gender M or F ?'))

if Age > 18 and Married == 'Y' or 'y':
    print('Hello ',Name,' Welcome to the Quiz Game')
    if Gender == 'M' or 'm':
        husband = Name
        wife    = str(input('Enter your wifey Name:'))
    elif Gender == 'F' or 'f':
        wife    = Name
        husband = str(input('Enter your Hubbys Name:'))

    questions = ['color','food','country','animal','actor','movie','song','singer','series']

    print('Hello Mr ',husband,' lets start the game :)')
    print('============================================')
    husbownanwser = []
    for i in range(0,len(questions)):
        hubown = str(input('Enter your favorite '+''+questions[i]+':'))
        husbownanwser.append(hubown)

    husbandwifeanwser = []
    for i in range(0,len(questions)):
        hubwife = str(input('Enter '+wife+'favorite '+''+questions[i]+':'))
        husbandwifeanwser.append(hubwife)

    print('Hello Mrs ',wife,' lets start the game :)')
    print('============================================')
    wifeownanwser = []
    for i in range(0,len(questions)):
        wifeown = str(input('Enter your favorite '+''+questions[i]+':'))
        wifeownanwser.append(wifeown)

    wifehusbandanwser = []
    for i in range(0,len(questions)):
        wifehub = str(input('Enter '+husband+'favorite '+''+questions[i]+':'))
        wifehusbandanwser.append(wifehub)


    resultshusband = []
    for i in range(0,len(questions)):
        result = husbandwifeanwser[i] == wifeownanwser[i]
        resultshusband.append(result)

    resultswife = []
    for i in range(0,len(questions)):
        result = husbownanwser[i] == wifehusbandanwser[i]
        resultswife.append(result)
    
    if resultshusband.count(True) > resultswife.count(True):
        print(' The winner of the game is husband ')
    elif resultshusband.count(True) < resultswife.count(True):
        print(' The winner of the game is Wife ')
    else:
        print(' This is a draw match ')

else:
    print('Hello '+Name+' You are below 18 years not eligible to play the game')