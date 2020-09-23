def covnertToDef57(fileName):
    reachedNets = False
    reading = open(fileName, "r+")
    writing = open(fileName[:-4] + '_new.def', 'w+')
    
    for line in reading:
        splitted_line = line.split()
        if(len(splitted_line) > 0):
            if(splitted_line[0] == 'NETS'):
                reachedNets = True
            if(reachedNets == True):
                if(len(splitted_line) > 0):
                    if(splitted_line[0] == '-'):
                        line1 = splitted_line[0] + " " + splitted_line[1] + '\n'
                        writing.write(line1)
                        
                        line2 = ""
                        for i in range(len(splitted_line)):
                            if(i > 1):
                                line2 += splitted_line[i] + " "
                                
                        writing.write(line2 + '\n')
                    else:
                        writing.write(line)  
                
            else:
                writing.write(line)
                
            