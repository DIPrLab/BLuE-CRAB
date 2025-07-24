import json
import matplotlib.pyplot as plt
from datetime import datetime
import numpy as np

#making file choice
x = input("which file should be look at?")
y = input("file with known suspicious devices:")

#importing data into dictionaries
def openfile():
    with open(x, "r") as f:
        data = json.load(f)
    with open(y, "r") as f:
        datasus = json.load(f)
    #list of suspicious devices
    setsus = datasus[x]
    return data, setsus

#function to pick out desiered information(mac address, RSSI value, time)
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
#removing the time zone (EDT) which can't be read by the operater
        timestamp_str_clean = " ".join(timestamp_str.split()[:-2] + [timestamp_str.split()[-1]])
        timestamp = datetime.strptime(timestamp_str_clean, "%a %b %d %H:%M:%S %Y")


        time.append(timestamp)
    return mac, rssi, time

#function to make all detections into each unique mac address with RSSI and time stored as a list of lists
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
         

#filtering the suspicious devices
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
    




def main():
    macsus, rssisus, timesus, macsafe, rssisafe, timesafe = findsus()

    
    plt.figure(figsize=(12, 6))
    plt.xticks(rotation=45)

#showing the labels
    plt.plot(timesafe[0], rssisafe[0], color="blue", label=("Safe Device", len(macsafe)))
    plt.plot(timesus[0], rssisus[0], color="red", label=("Suspicious Device", len(macsus)))
    
#plot each safe device data
    for i in range(len(macsafe)):
        sorted_pairs = sorted(zip(timesafe[i], rssisafe[i]), key=lambda x: x[0])
        timesafe_paired, rssisafe_paired = zip(*sorted_pairs)
        plt.plot(timesafe_paired, rssisafe_paired, color="blue")

#plot each suspicious device data
    for i in range(len(macsus)):
        sorted_pairs = sorted(zip(timesus[i], rssisus[i]), key=lambda x: x[0])
        timesus_paired, rssisus_paired = zip(*sorted_pairs)
        plt.plot(timesus_paired, rssisus_paired, color="red")

    plt.legend()
    plt.title('RSSI Strength for file '+x)
    plt.xlabel('Time')
    plt.ylabel('RSSI')
    plt.show()
    
if __name__ == "__main__":
    main()

