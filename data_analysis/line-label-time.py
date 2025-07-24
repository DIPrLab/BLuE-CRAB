import json
import matplotlib.pyplot as plt
from datetime import datetime
import numpy as np


x = input("which file should be look at?")
filename = "bledoubt_log_" + x + ".json"
def openfile():
    with open(filename, "r") as f:
        data = json.load(f)
    with open("gt_macs.json", "r") as f:
        datasus = json.load(f)
    setsus = datasus[filename]
    return data, setsus


def make_rssi():
    mac = []
    rssi = []
    time = []
    data, setsus = openfile()
    detection = data['detections']
        
    for entry in detection:
        mac.append(entry['mac'])
        rssi.append(entry['rssi'])

        timestamp_str = entry['t']
        timestamp_str_clean = " ".join(timestamp_str.split()[:-2] + [timestamp_str.split()[-1]])
        timestamp = datetime.strptime(timestamp_str_clean, "%a %b %d %H:%M:%S %Y")

        time.append(timestamp)
    return mac, rssi, time

def sort():
    mac, rssi, time = make_rssi()
    fmac = list(set(mac))
    arssi = []
    atime = []
    for i in fmac:
        r = []
        t = []
        for idx, e in enumerate(mac):
            if i == e:
                r.append(rssi[idx])
                t.append(time[idx])
        arssi.append(r)
        atime.append(t)

    return fmac, arssi, atime
         

def findsus():
    macsus = []
    rssisus = []
    timesus = []
    macsafe = []
    rssisafe = []
    timesafe = []
    data, setsus = openfile()
    fmac, arssi, atime = sort()
    for i in fmac:
        idx = fmac.index(i)
        if i in setsus:
            macsus.append(i)
            rssisus.append(arssi[idx])
            timesus.append(atime[idx])
        else:
            macsafe.append(i)
            rssisafe.append(arssi[idx])
            timesafe.append(atime[idx])

    return macsus, rssisus, timesus, macsafe, rssisafe, timesafe
    
#function to assess if each device is detected for a significant time 60sec(adjustable)
def findtime():
    labelsafe = []
    labelsus = []
    labelsafe_r = []
    labelsus_r = []
    labelsafe_t = []
    labelsus_t = []
    macsus, rssisus, timesus, macsafe, rssisafe, timesafe = findsus()

    for a in macsafe:
        idx = macsafe.index(a)
        if len(timesafe[idx]) > 60:
            labelsafe.append(a)
            labelsafe_r.append(rssisafe[idx])
            labelsafe_t.append(timesafe[idx])
        else:
            next
    for a in macsus:
        idx = macsus.index(a)
        if len(timesus[idx]) > 60:
            labelsus.append(a)
            labelsus_r.append(rssisus[idx])
            labelsus_t.append(timesus[idx])
        else:
            next
    print(labelsus, labelsafe)
    return(labelsus, labelsus_r, labelsus_t, labelsafe, labelsafe_r, labelsafe_t)
    

    



def main():
    macsus, rssisus, timesus, macsafe, rssisafe, timesafe = findsus()
    labelsus, labelsus_r, labelsus_t, labelsafe, labelsafe_r, labelsafe_t = findtime()
    
    plt.figure(figsize=(12, 6))
    plt.xticks(rotation=45)
    
    plt.plot(timesafe[0], rssisafe[0], color="blue", label="Safe Device")
    plt.plot(timesus[0], rssisus[0], color="red", label="Suspicious Device")
    

    for i in range(len(macsafe)):
        sorted_pairs = sorted(zip(timesafe[i], rssisafe[i]), key=lambda x: x[0])
        timesafe_paired, rssisafe_paired = zip(*sorted_pairs)
        plt.plot(timesafe_paired, rssisafe_paired, color="lightskyblue")
    
#the colors were changed to be a lighter verson of the original colors
    for i in range(len(macsus)):
        sorted_pairs = sorted(zip(timesus[i], rssisus[i]), key=lambda x: x[0])
        timesus_paired, rssisus_paired = zip(*sorted_pairs)

        plt.plot(timesus_paired, rssisus_paired, color="tomato")
    
# specially plot significant devices with bold color
    for i in range(len(labelsafe)):
        sorted_pairs = sorted(zip(labelsafe_t[i], labelsafe_r[i]), key=lambda x: x[0])
        timesafe_paired, rssisafe_paired = zip(*sorted_pairs)
        plt.plot(timesafe_paired, rssisafe_paired, color = "blue")
        plt.text(labelsafe_t[i][-1], labelsafe_r[i][-1], labelsafe[i], color="navy")


    for i in range(len(labelsus)):
        sorted_pairs = sorted(zip(labelsus_t[i], labelsus_r[i]), key=lambda x: x[0])
        timesafe_paired, rssisafe_paired = zip(*sorted_pairs)
        plt.plot(timesafe_paired, rssisafe_paired, color = "red")
        plt.text(labelsus_t[i][0], labelsus_r[i][0], labelsus[i], color="darkred")


    plt.legend()
    plt.title('RSSI Strength')
    plt.xlabel('Time')
    plt.ylabel('RSSI')
    plt.show()
    
if __name__ == "__main__":
    main()

