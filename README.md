# ECG Pseudo Service

This project is part 2 of ECG Service Roadmap

## ECG Service Roadmap

The following projects should bring me closer to creating a service that simulates the transmission/reception of __ECG signals__. Applications can work in the background in two modes: as a client and as a server. That is, one/two/three phones are the source of the __ECG signal__ - these are servers, and there are one/two/three clients that receive and display or save these signals.
Connection type - __MQTT__. That is, all applications are physically __MQTT__ clients, and on the other hand: the server, in my understanding, publishes the generated signal, and the client receives and displays or saves it, or both.
It's quite difficult to write everything right at once. Therefore, the process is divided on some stages:
1. ✓ Attempt to use the service: project __ECG FB Service__ in repository https://github.com/mk590901/ECG-FB-Service
2. ✓ Service simulation - the current project. Creation of data structures that allow simulating the receipt and display of ECG signals from multiple clients. In this case, the __service__ is not implemented. Pure imitation.
3. From __service__ simulation to a real __service__. 3 = (1 & 2)
4. Development Pack/Unpack ECG Signal procedures
5. Add __MQTT__ client (like https://github.com/mk590901/mqtt_sink_agent)
6. 6 = (3 & 4 & 5)

## Application Features

> __Action__ button adds __ECG pseudo client__ to app. With the help of swape client can be deleted. There are two types of deletion:
* GUI image of client is deleted: swipe from left to right. In this case, the pseudo client continues to generate a signal and automatically returns to the list.
* Brutal pseudo client delete from the application: swipe from right to left.
>__Stop button__ deletes GUI images of clients.

> A significant change is related to the creation of a __widget__ for displaying the ECG signal. __Widget__ is created not in advance, before the signal display process startsbut after receiving the data, and uses the attributes of this data. 
 
## Movie

https://github.com/user-attachments/assets/66a736a1-7cc2-4909-b9bc-ed507d772361

